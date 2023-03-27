from build123d import *
from build123d import gp_Quaternion, gp_Trsf, TopTools_ListOfShape, BRepAlgoAPI_Cut
from build123d.topology import Shape

from cq_vscode import show, show_object, set_port
import math
import marionette_dims as dims

set_port(3939)


def complete_profile(pts, h, eps=1e-6):
    for i in range(len(pts) - 1, -1, -1):
        # Avoid duplicating midpoint if it's too close to half h
        if pts[i][1] * 2 + eps < h:
            pts.append((pts[i][0], h - pts[i][1]))


# Visualization purposes
def make_pulley(p):
    flange = 2
    pts = [(p.ir, 0), (p.r, 0), (p.rr, p.h / 2), (p.r, p.h), (p.ir, p.h)]
    s = Polyline(*pts, close=True)
    return revolve(Plane.XZ * make_face(s), axis=Axis.Z)


def join_with_fillet(a, b, r=1):
    result = a + b
    # return result
    arg = TopTools_ListOfShape()
    for obj in result.edges():
        arg.Append(obj.wrapped)
    tool = TopTools_ListOfShape()
    for obj in a.edges():
        tool.Append(obj.wrapped)
    for obj in b.edges():
        tool.Append(obj.wrapped)

    operation = BRepAlgoAPI_Cut()
    operation.SetArguments(arg)
    operation.SetTools(tool)
    operation.SetRunParallel(True)
    operation.Build()
    s = Shape.cast(operation.Shape())

    return fillet(*s.edges(), radius=r, target=result)


def counterbored(r_bolt, r_bolt_head):
    return Cylinder(radius=r_bolt, height=large) + Cylinder(
        radius=r_bolt_head, height=10000, align=(Align.CENTER, Align.CENTER, Align.MIN)
    )


ccb = (Align.CENTER, Align.CENTER, Align.MIN)

large = 1e4


idler = dims.small_idler


t = 2
fillet_r = 2

# screw_standoff = 3
# screw_standoff = 0


pulley_standoff = 0.5
cbd = dims.rail_mount_screw_head_h
h1 = dims.rail_mount_screw_l + 2 - dims.rail_depth
h = h1 + cbd - pulley_standoff
# Width between screws
w = dims.rail_size

# y = screw_standoff + idler.rr - idler.h / 2 - pulley_standoff
y = 0


def make_pulley_holder(v_pulley_screw_r=idler.screw_r):
    sketch1 = Pos(0, y) * RectangleRounded(
        w + dims.rail_size, dims.rail_size + y, align=(Align.CENTER, Align.MAX), radius=1
    )

    pulley_block = extrude(sketch1, amount=h)
    # Box(dims.rail_size*3, dims.rail_size, h, align=ccb)

    # Fillet(*pulley_block.edges(Select.LAST).filter_by(Axis.Z), radius=2)
    #
    # ShapeList.filter_by

    pulley_1_pos = Pos(
        w / 2 + dims.rail_size / 2 - (idler.screw_r + t),
        pulley_standoff + idler.h / 2 - idler.rr,
    )

    pulley_block = join_with_fillet(
        pulley_block,
        pulley_1_pos * Cylinder(radius=idler.screw_r + t, height=h, align=ccb),
        fillet_r,
    )

    pulley_mirror_pos = Pos(
        -pulley_1_pos.position.X, pulley_1_pos.position.Y, pulley_1_pos.position.Z
    )

    pulley_block = join_with_fillet(
        pulley_block,
        pulley_mirror_pos * Cylinder(radius=idler.screw_r + t, height=h, align=ccb),
        fillet_r,
    )

    pulley_block += (
        pulley_1_pos * Cylinder(radius=idler.screw_r + 1, height=h + pulley_standoff, align=ccb)
    )
    pulley_block += (
        pulley_mirror_pos * Cylinder(radius=idler.screw_r + 1, height=h + pulley_standoff, align=ccb)
    )

    pulley_2_pos = Pos(0, y, h - idler.rr + idler.h / 2) * Rot(-90)

    pulley_block += (
        pulley_2_pos * Cylinder(
            radius=v_pulley_screw_r + 1,
            height=pulley_standoff,
            align=(Align.CENTER, Align.CENTER, Align.MIN),
        )
    )

    pulley_block -= pulley_1_pos * Cylinder(radius=idler.screw_r, height=large)
    pulley_block -= pulley_mirror_pos * Cylinder(radius=idler.screw_r, height=large)

    bolt_hole = Cylinder(radius=dims.rail_mount_screw_r, height=large) + Cylinder(
        radius=dims.rail_mount_screw_head_r,
        height=10000,
        align=(Align.CENTER, Align.CENTER, Align.MIN),
    )

    

    pulley_block -= pulley_2_pos * Cylinder(radius=v_pulley_screw_r - 0.1, height=large)
    pulley_block -= Pos(w / 2, -dims.rail_size / 2, h1) * bolt_hole
    pulley_block -= Pos(-w / 2, -dims.rail_size / 2, h1) * bolt_hole
    return pulley_block


multi_cable_pulley_rr = dims.tiny_bearing_or + 2


def make_multi_cable_pulley(cable_spacing=2):
    # Make it a little looser
    inner_r = dims.tiny_bearing_or+0.15
    bearing_h = dims.tiny_bearing_h
    outer_r = multi_cable_pulley_rr
    flange = 2
    flange_h = 2
    k = 0.5
    bearing_step = 0.25
    pts = [
        (inner_r - bearing_step, bearing_h + bearing_step),
        (inner_r, bearing_h),
        (inner_r, k),
        (inner_r + k, 0),
        (outer_r + flange, 0),
        (outer_r, flange_h),
    ]
    y = flange_h
    for i in range(0, 5):
        pts.append((outer_r + cable_spacing / 2, y + cable_spacing / 2))
        pts.append((outer_r, y + cable_spacing))
        y += cable_spacing
    y += flange_h

    pts.append((outer_r + flange, y))
    pts.append((inner_r + k, y))
    pts.append((inner_r, y - k))
    pts.append((inner_r, y - bearing_h))
    pts.append((inner_r - bearing_step, y - bearing_h - bearing_step))

    s = Polyline(*pts, close=True)
    return revolve(Plane.XZ * make_face(s), axis=Axis.Z)


def make_multi_cable_pulley_holder():
    v_pulley_screw_r = idler.screw_r

    # Width between screws
    w = dims.rail_size

    sketch1 = Pos(0, y) * Rectangle(
        w + dims.rail_size, dims.rail_size + y, align=(Align.CENTER, Align.MAX)
    )

    pulley_block = extrude(sketch1, amount=h)
    pulley_block = pulley_block.fillet(radius=1, edge_list=pulley_block.edges().filter_by(Axis.Z))

    pulley_1_pos = Pos(
        w / 2 + dims.rail_size / 2 - (idler.screw_r + t),
        pulley_standoff + idler.h / 2 - idler.rr,
    )

    pulley_block = join_with_fillet(
        pulley_block,
        pulley_1_pos * Cylinder(radius=idler.screw_r + t, height=h, align=ccb),
        fillet_r,
    )

    pulley_mirror_pos = Pos(
        -pulley_1_pos.position.X, pulley_1_pos.position.Y, pulley_1_pos.position.Z
    )

    pulley_block = join_with_fillet(
        pulley_block,
        pulley_mirror_pos * Cylinder(radius=idler.screw_r + t, height=h, align=ccb),
        fillet_r,
    )

    pulley_block += (
        pulley_1_pos * Cylinder(radius=idler.screw_r + 1, height=h + pulley_standoff, align=ccb)
    )
    pulley_block += (
        pulley_mirror_pos * Cylinder(radius=idler.screw_r + 1, height=h + pulley_standoff, align=ccb)
    )

    pulley_block -= pulley_1_pos * Cylinder(radius=idler.screw_r, height=large)
    pulley_block -= pulley_mirror_pos * Cylinder(radius=idler.screw_r, height=large)

    bolt_hole = Cylinder(radius=dims.rail_mount_screw_r, height=large) + Cylinder(
        radius=dims.rail_mount_screw_head_r,
        height=10000,
        align=(Align.CENTER, Align.CENTER, Align.MIN),
    )

    pulley_2_pos = Pos(0, y, h - multi_cable_pulley_rr + idler.h / 2) * Rot(-90)

    cyl2 = pulley_2_pos*Cylinder(
            radius=v_pulley_screw_r + t,
            height=dims.rail_size + y,
            align=(Align.CENTER, Align.CENTER, Align.MAX),
        )


    # pulley_block = join_with_fillet(pulley_block, cyl2, fillet_r)

    pulley_block += (
        pulley_2_pos * Cylinder(
            radius=v_pulley_screw_r + 1,
            height=pulley_standoff,
            align=(Align.CENTER, Align.CENTER, Align.MIN),
        )
    )

    pulley_block -= pulley_2_pos * Cylinder(radius=v_pulley_screw_r - 0.1, height=large)
    pulley_block -= Pos(w / 2, -dims.rail_size / 2, h1) * bolt_hole
    pulley_block -= Pos(-w / 2, -dims.rail_size / 2, h1) * bolt_hole
    return pulley_block

set_port(3939)
pulley_block = make_pulley_holder()
pulley_block.export_stl("pulley_block.stl")

big_pulley = make_multi_cable_pulley()
big_pulley.export_stl("big_pulley.stl")

big_pulley = make_multi_cable_pulley(1)
big_pulley.export_stl("big_pulley_short.stl")

big_pulley = make_multi_cable_pulley(1.5)
big_pulley.export_stl("big_pulley_med.stl")

big_pulley_block = make_multi_cable_pulley_holder()
big_pulley_block.export_stl("big_pulley_block.stl")


pulley_2_pos = Pos(
    0, y + pulley_standoff, h - multi_cable_pulley_rr + idler.h / 2
) * Rot(-90)

pulley_1_pos = Pos(
    w / 2 + dims.rail_size / 2 - (idler.screw_r + t),
    pulley_standoff + idler.h / 2 - idler.rr,
    h + pulley_standoff,
)


# Jig for cutting 2020 extrusions
def extrusion_clamper(sz=dims.rail_size):
    screw_tight = dims.rail_mount_screw_r
    screw_loose = screw_tight + 0.2
    t = 4

    cl = 2

    b = Box(sz + 2 * t, sz + 2 * t, sz)

    box_rot = Pos(0, 0, -cl / 2) * Rot(90, 0, 0) * Rot(0, 0, 45)

    box2 = split(box_rot * b, bisect_by=Plane.XY)

    w = sz * math.sqrt(0.5) + screw_loose + 1

    h = 5

    # box2+=Pos(w,0,0) * Cylinder(5, h, align=ccb)
    # box2+=Pos(-w,0,0) * Cylinder(5, h, align=ccb)
    box2 += Box(2 * (w + screw_loose + 3), sz, h, align=ccb)

    cyls = Cylinder(screw_loose, large, align=ccb) + Pos(0, 0, h)*Cylinder(
        dims.rail_mount_screw_head_r, large, align=ccb
    ) 

    box2 -= Pos(w, 0, 0) * cyls
    #    cyls2=Cylinder(screw_loose, large, align=ccb) + Pos(0,0,h) * Cylinder(dims.rail_mount_screw_head_r, large, align=ccb)
    box2 -= Pos(-w, 0, 0) * cyls

    nut = extrude(RegularPolygon(7.9 / 2, 6), large)
    box2 -= Pos(-w, 0, h - 2) * nut

    box2 -= box_rot * Box(sz, sz, 2 * sz)

    return box2


def rotate_from_to(f, t):
    transform = gp_Trsf()
    q = gp_Quaternion()
    q.SetRotation(Vector(f).wrapped, Vector(t).wrapped)
    transform.SetRotation(q)
    return Location(transform)

def corner_joint():

    almin=(Align.MIN, Align.MIN, Align.MIN)

    r = Rot(0, 0, 90) * Rot(90, 0, 0)

    expand=0.15

    rail_size=dims.rail_size+expand

    def symm(a):
        return a + r * a + r * r * a

    sz = rail_size * 3
    t = 3
    # b=Pos(-t, -t, -t) * Box(sz+2*t, sz+2*t, sz+2*t, align=Align.MIN)
    b = Pos(-t, -t, -t) * Box(sz + 2 * t, t, sz + 2 * t, align=(Align.MIN, Align.MIN, Align.MIN) )
    b += Pos(-t, rail_size, -t) * Box(sz + 2 * t, t, sz + 2 * t, align=(Align.MIN, Align.MIN, Align.MIN))

    b = split(b, bisect_by=Plane(origin=(rail_size + t, 0, sz + t), z_dir=(-1, 0, -1)))

    b = symm(b)

    # b=split(b, Plane(origin=(sz, dims.rail_size+t, dims.rail_size+t), z_dir=(-1,-1,-1)))

    b += symm(
        Pos(-t, -t, -t) * Box(
            rail_size + 2 * t,
            rail_size + 2 * t,
            sz + 2 * t,
            align=(Align.MIN, Align.MIN, Align.MIN),
        )
    )

    holes = Part()
    hole_r = 2

    hole = Cylinder(
        radius=hole_r, height=large, align=(Align.CENTER, Align.CENTER, Align.CENTER)
    )

    for i in range(1, 4):
        holes += Pos(
            (i + 0.5) * rail_size, 0.5 * rail_size, 0.5 * rail_size
        ) * hole
        holes += (
            Pos((i + 0.5) * rail_size, 0.5 * rail_size, 0.5 * rail_size)
            * Rot(-90, 0, 0)
        ) * hole

    step=1
    cut = Pos(rail_size-0.1) * Box(large, rail_size+expand, rail_size, align=(Align.MIN, Align.MIN, Align.MIN)) + holes
    cut += Pos(step, step, step) * Box(large, rail_size-step, rail_size-step, align=(Align.MIN, Align.MIN, Align.MIN)) + holes
    cut += Pos(sz / 2, 0, sz / 2) * Rot(90, 0, 0) * Cylinder(hole_r, large)

    b -= symm(cut)

    b = split(b, bisect_by=Plane(origin=(rail_size - t, 0, 0), z_dir=(1, 1, 1)))

    return b




def make_side_joint():
    t=3
    expand=0.15
    rail_size=dims.rail_size
    grab=rail_size*1.5+5
    h=rail_size+10

    inner_r=2

    fixing_screw_r=1

    extra_h=5 # as built
    spacing=1
    rim=extra_h-spacing
    
    inner_tol=5

    support_or=idler.rr+extra_h-spacing

    pts = [
        (inner_r, 0),
        (idler.rr+extra_h-spacing, 0),
        (idler.rr, extra_h-spacing),
        (idler.rr+spacing, extra_h),
        (idler.rr, extra_h+spacing),
        (idler.rr+rim, extra_h+rim+spacing),
        (inner_r, extra_h+rim+spacing)
    ]
    s = Polyline(*pts, close=True)
    cable_wrap_post= revolve(Plane.XZ * make_face(s), axis=Axis.Z)

    b=Box(dims.rail_size+t, dims.rail_size+t, grab+h, align=ccb)    
    b+=Pos(0,rail_size/2,0) * Cylinder(support_or, h+grab, align=(Align.CENTER, Align.CENTER, Align.MIN))
    b+=Pos(0, rail_size/2, h+grab) * cable_wrap_post

    b-=Box(dims.rail_size+expand, dims.rail_size+expand, grab+inner_tol, align=ccb)

    b-=Pos(0,rail_size/2, grab+inner_tol+1) * Cylinder(inner_r, large, align=ccb)

    b-=Pos(rail_size/4,-rail_size/4, grab+inner_tol+1) * Cylinder(fixing_screw_r, large, align=ccb) 
    b-=Pos(-rail_size/4,-rail_size/4, grab+inner_tol+1) * Cylinder(fixing_screw_r, large, align=ccb) 

    rail_mount_cyl=Cylinder(dims.rail_mount_screw_r, large)

    for i in range(0,2):
        b-=(Pos(0, 0, (i+0.5)*dims.rail_size)*Rot(0,90,0)) * rail_mount_cyl
        b-=Pos(0, 0, (i+0.5)*dims.rail_size) * Rot(90,0,0) * Cylinder(dims.rail_mount_screw_r, large, align=ccb)    

    return b

def make_bottom_pulley_holder(v_pulley_screw_r=idler.screw_r):
    pulley_block = Part()

    cl = 2
    t = 2

    idler_offset=cl + idler.r

    sketch1 = Pos(0, -dims.rail_size) * Rectangle(
        w + dims.rail_size,
        dims.rail_size + idler_offset + idler.screw_head_r + t,
        align=(Align.CENTER, Align.MIN),
    )

    sketch1 -= Rectangle(idler.h + 1, large, align=(Align.CENTER, Align.MIN))

    pulley_block += extrude(sketch1, amount=h)
    pulley_block = fillet(*pulley_block.edges().filter_by(Axis.Z), radius=1, target=pulley_block)

    bolt_hole = counterbored(dims.rail_mount_screw_r, dims.rail_mount_screw_head_r) 

    bolt_hole_2 = counterbored(idler.screw_r, idler.screw_head_r) 

    pulley_block -= Pos(w / 2, -dims.rail_size / 2, h1) * bolt_hole
    pulley_block -= Pos(-w / 2, -dims.rail_size / 2, h1) * bolt_hole


    pulley_block -= (
        Pos(idler.h / 2 + 3, idler_offset, h / 2) * Rot(0, 90, 0)
    ) * bolt_hole_2

    return pulley_block



def make_angled_pulley_holder(v_pulley_screw_r=idler.screw_r):
    pulley_block = Part()

    cl = 1
    t = 4

    max_angle=60*math.pi/180

    idler_offset=(cl + idler.r)/math.cos(max_angle)

    bottom_offset=dims.rail_size/2#dims.rail_size/2+dims.rail_mount_screw_head_r+2

    w=max((dims.rail_mount_screw_head_r+2)*2, 2*t + idler.h+2*cl)

    sketch1 = Pos(0, -bottom_offset) * Rectangle(
        2*t + idler.h+2,
        bottom_offset + cl + idler.r + idler.screw_head_r + 2*t,
        align=(Align.CENTER, Align.MIN),
    )

    sketch1+=Pos(0, -dims.rail_size/2) * Circle(dims.rail_size/2)

    sketch1 -= Rectangle(idler.h + cl, large, align=(Align.CENTER, Align.MIN))

    pulley_block += extrude(sketch1, amount=h)
    pulley_block = pulley_block.fillet(radius=1, edge_list=pulley_block.edges().filter_by(Axis.Z))

    bolt_hole = counterbored(dims.rail_mount_screw_r, dims.rail_mount_screw_head_r) 

    bolt_hole_2 = counterbored(idler.screw_r, idler.screw_head_r) 

    pulley_block -= Pos(0, -dims.rail_size / 2, h1) * bolt_hole 

    pip=Cylinder(idler.screw_r+1, 1)

    pulley_block+=(
        Pos(idler.h / 2+cl, idler_offset, h / 2) * Rot(0, 90, 0)
    ) * pip

    pulley_block -= (
        Pos(idler.h / 2 + 3, idler_offset, h / 2) * Rot(0, 90, 0)
    ) * bolt_hole_2

    return pulley_block

extrusion_clamper_obj = extrusion_clamper()
( Rot(90, 0, 0) * extrusion_clamper_obj).export_stl("extrusion_clamper.stl")

corner_joint_obj = corner_joint()

(rotate_from_to((1, 1, 1), (0, 0, 1)) * corner_joint_obj).export_stl("corner_joint.stl")

bottom_pulley_holder = make_bottom_pulley_holder()
bottom_pulley_holder.export_stl("bottom_ph.stl")

angled_pulley_holder = make_angled_pulley_holder()
angled_pulley_holder.export_stl("angled_ph.stl")

def arrange(*objs: Shape):
    #locations=[]
    result=[]
    x=0
    for obj in objs:
       x+=obj.bounding_box().max.X+5
       result.append(Pos(x) * obj)

    return result


#cj2=make_cutter_jig_2()

#show(*arrange(pulley_block, big_pulley, big_pulley_block,  ))
side_joint=make_side_joint()
side_joint.export_stl('side_joint.stl')

if __name__ == '__main__':
    from z_poc_winch_alg123d import winch, wh
    show(
        pulley_block,
        (Pos(60, 0, 0) * pulley_2_pos) * big_pulley,
        Pos(60, 0, 0) * big_pulley_block,
        (Pos(60, 0, 0) * pulley_1_pos) * make_pulley(idler),
        Pos(120, 0, 0) * bottom_pulley_holder,
        Pos(-60, 0, 0) * extrusion_clamper(),
        (Pos(0, 120, 0) * rotate_from_to((1, 1, 1), (0, 0, 1))) * corner_joint_obj,
        Pos(180, 0, 4.5) * winch.object, Pos(180, 0) * wh,
        Pos(220, 0, 4.5) * angled_pulley_holder,
        Pos(0, -60, 0) * side_joint
    )


# show(test)
