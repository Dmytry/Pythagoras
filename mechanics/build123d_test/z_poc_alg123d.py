# from build123d import *

# .venv/lib/python3.10/site-packages/build123d-0.1.dev560+g99bb3a5.dist-info
from alg123d import *
from build123d import gp_Quaternion

from cq_vscode import show, show_object, set_port
import math
import marionette_dims as dims

set_port(3939)


# Visualization purposes
def make_pulley(p):
    flange = 2
    pts = [(p.ir, 0), (p.r, 0), (p.rr, p.h / 2), (p.r, p.h), (p.ir, p.h)]
    s = Polyline(pts, close=True)
    return revolve(make_face(s) @ Plane.XZ, axis=Axis.Z)


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

    return fillet(result, s.edges(), r)


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
    pulley_block = AlgCompound()

    sketch1 = Rectangle(
        w + dims.rail_size, dims.rail_size + y, align=(Align.CENTER, Align.MAX)
    ) @ Pos(0, y)

    pulley_block += extrude(sketch1, amount=h)
    pulley_block = fillet(
        pulley_block, pulley_block.edges().filter_by(Axis.Z), radius=1
    )

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
        Cylinder(radius=idler.screw_r + t, height=h, align=ccb) @ pulley_1_pos,
        fillet_r,
    )

    pulley_mirror_pos = Pos(
        -pulley_1_pos.position.X, pulley_1_pos.position.Y, pulley_1_pos.position.Z
    )

    pulley_block = join_with_fillet(
        pulley_block,
        Cylinder(radius=idler.screw_r + t, height=h, align=ccb) @ pulley_mirror_pos,
        fillet_r,
    )

    pulley_block += (
        Cylinder(radius=idler.screw_r + 1, height=h + pulley_standoff, align=ccb)
        @ pulley_1_pos
    )
    pulley_block += (
        Cylinder(radius=idler.screw_r + 1, height=h + pulley_standoff, align=ccb)
        @ pulley_mirror_pos
    )

    pulley_2_pos = Pos(0, y, h - idler.rr + idler.h / 2) * Rot(-90)

    pulley_block += (
        Cylinder(
            radius=v_pulley_screw_r + 1,
            height=pulley_standoff,
            align=(Align.CENTER, Align.CENTER, Align.MIN),
        )
        @ pulley_2_pos
    )

    pulley_block -= Cylinder(radius=idler.screw_r, height=large) @ pulley_1_pos
    pulley_block -= Cylinder(radius=idler.screw_r, height=large) @ pulley_mirror_pos

    bolt_hole = Cylinder(radius=dims.rail_mount_screw_r, height=large) + Cylinder(
        radius=dims.rail_mount_screw_head_r,
        height=10000,
        align=(Align.CENTER, Align.CENTER, Align.MIN),
    )

    

    pulley_block -= Cylinder(radius=v_pulley_screw_r - 0.1, height=large) @ pulley_2_pos
    pulley_block -= bolt_hole @ Pos(w / 2, -dims.rail_size / 2, h1)
    pulley_block -= bolt_hole @ Pos(-w / 2, -dims.rail_size / 2, h1)
    return pulley_block


multi_cable_pulley_rr = dims.tiny_bearing_or + 2


def make_multi_cable_pulley(cable_spacing=2):
    inner_r = dims.tiny_bearing_or
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

    s = Polyline(pts, close=True)
    return revolve(make_face(s) @ Plane.XZ, axis=Axis.Z)


def make_multi_cable_pulley_holder():
    v_pulley_screw_r = idler.screw_r

    pulley_block = AlgCompound()

    # Width between screws
    w = dims.rail_size

    sketch1 = Rectangle(
        w + dims.rail_size, dims.rail_size + y, align=(Align.CENTER, Align.MAX)
    ) @ Pos(0, y)

    pulley_block += extrude(sketch1, amount=h)
    pulley_block = fillet(
        pulley_block, pulley_block.edges().filter_by(Axis.Z), radius=1
    )

    pulley_1_pos = Pos(
        w / 2 + dims.rail_size / 2 - (idler.screw_r + t),
        pulley_standoff + idler.h / 2 - idler.rr,
    )

    pulley_block = join_with_fillet(
        pulley_block,
        Cylinder(radius=idler.screw_r + t, height=h, align=ccb) @ pulley_1_pos,
        fillet_r,
    )

    pulley_mirror_pos = Pos(
        -pulley_1_pos.position.X, pulley_1_pos.position.Y, pulley_1_pos.position.Z
    )

    pulley_block = join_with_fillet(
        pulley_block,
        Cylinder(radius=idler.screw_r + t, height=h, align=ccb) @ pulley_mirror_pos,
        fillet_r,
    )

    pulley_block += (
        Cylinder(radius=idler.screw_r + 1, height=h + pulley_standoff, align=ccb)
        @ pulley_1_pos
    )
    pulley_block += (
        Cylinder(radius=idler.screw_r + 1, height=h + pulley_standoff, align=ccb)
        @ pulley_mirror_pos
    )

    pulley_block -= Cylinder(radius=idler.screw_r, height=large) @ pulley_1_pos
    pulley_block -= Cylinder(radius=idler.screw_r, height=large) @ pulley_mirror_pos

    bolt_hole = Cylinder(radius=dims.rail_mount_screw_r, height=large) + Cylinder(
        radius=dims.rail_mount_screw_head_r,
        height=10000,
        align=(Align.CENTER, Align.CENTER, Align.MIN),
    )

    pulley_2_pos = Pos(0, y, h - multi_cable_pulley_rr + idler.h / 2) * Rot(-90)

    cyl2 = (
        Cylinder(
            radius=v_pulley_screw_r + t,
            height=dims.rail_size + y,
            align=(Align.CENTER, Align.CENTER, Align.MAX),
        )
        @ pulley_2_pos
    )

    # pulley_block = join_with_fillet(pulley_block, cyl2, fillet_r)

    pulley_block += (
        Cylinder(
            radius=v_pulley_screw_r + 1,
            height=pulley_standoff,
            align=(Align.CENTER, Align.CENTER, Align.MIN),
        )
        @ pulley_2_pos
    )

    pulley_block -= Cylinder(radius=v_pulley_screw_r - 0.1, height=large) @ pulley_2_pos
    pulley_block -= bolt_hole @ Pos(w / 2, -dims.rail_size / 2, h1)
    pulley_block -= bolt_hole @ Pos(-w / 2, -dims.rail_size / 2, h1)
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

    box2 = split(b @ box_rot, by=Plane.XY)

    w = sz * math.sqrt(0.5) + screw_loose + 1

    h = 5

    # box2+=Cylinder(5, h, align=ccb)@Pos(w,0,0)
    # box2+=Cylinder(5, h, align=ccb)@Pos(-w,0,0)
    box2 += Box(2 * (w + screw_loose + 3), sz, h, align=ccb)

    cyls = Cylinder(screw_loose, large, align=ccb) + Cylinder(
        dims.rail_mount_screw_head_r, large, align=ccb
    ) @ Pos(0, 0, h)

    box2 -= cyls @ Pos(w, 0, 0)
    #    cyls2=Cylinder(screw_loose, large, align=ccb) + Cylinder(dims.rail_mount_screw_head_r, large, align=ccb)@Pos(0,0,h)
    box2 -= cyls @ Pos(-w, 0, 0)

    nut = extrude(RegularPolygon(7.9 / 2, 6), large)
    box2 -= nut @ Pos(-w, 0, h - 2)

    box2 -= Box(sz, sz, 2 * sz) @ box_rot

    return box2


def rotate_from_to(f, t):
    transform = gp_Trsf()
    q = gp_Quaternion()
    q.SetRotation(Vector(f).wrapped, Vector(t).wrapped)
    transform.SetRotation(q)
    return Location(transform)

def corner_joint():
    r = Rot(0, 0, 90) * Rot(90, 0, 0)

    expand=0.15

    rail_size=dims.rail_size+expand

    def symm(a):
        return a + (a @ r) + a @ (r * r)

    sz = rail_size * 3
    t = 3
    # b=Box(sz+2*t, sz+2*t, sz+2*t, align=Align.MIN)@Pos(-t, -t, -t)
    b = Box(sz + 2 * t, t, sz + 2 * t, align=Align.MIN) @ Pos(-t, -t, -t)
    b += Box(sz + 2 * t, t, sz + 2 * t, align=Align.MIN) @ Pos(-t, rail_size, -t)

    b = split(b, Plane(origin=(rail_size + t, 0, sz + t), z_dir=(-1, 0, -1)))

    b = symm(b)

    # b=split(b, Plane(origin=(sz, dims.rail_size+t, dims.rail_size+t), z_dir=(-1,-1,-1)))

    b += symm(
        AlgCompound(
            Box(
                rail_size + 2 * t,
                rail_size + 2 * t,
                sz + 2 * t,
                align=Align.MIN,
            )
            @ Pos(-t, -t, -t)
        )
    )

    holes = AlgCompound()
    hole_r = 2

    hole = Cylinder(
        radius=hole_r, height=large, align=(Align.CENTER, Align.CENTER, Align.CENTER)
    )

    for i in range(1, 4):
        holes += hole @ Pos(
            (i + 0.5) * rail_size, 0.5 * rail_size, 0.5 * rail_size
        )
        holes += hole @ (
            Pos((i + 0.5) * rail_size, 0.5 * rail_size, 0.5 * rail_size)
            * Rot(-90, 0, 0)
        )

    step=1
    cut = Box(large, rail_size+expand, rail_size, align=Align.MIN) @ Pos(rail_size-0.1) + holes
    cut += Box(large, rail_size-step, rail_size-step, align=Align.MIN) @ Pos(step, step, step) + holes
    cut += Cylinder(hole_r, large) @ (Pos(sz / 2, 0, sz / 2) * Rot(90, 0, 0))

    b -= symm(cut)

    b = split(b, Plane(origin=(rail_size - t, 0, 0), z_dir=(1, 1, 1)))

    return b


def make_side_joint():
    t=3
    expand=0.15
    rail_size=dims.rail_size+expand

    grab=rail_size*1.5+5
    h=rail_size+10

    b=Box(dims.rail_size+t, dims.rail_size+t, grab+h, align=ccb)
    b-=Box(dims.rail_size+expand, dims.rail_size+expand, grab, align=ccb)

    return b

def make_bottom_pulley_holder(v_pulley_screw_r=idler.screw_r):
    pulley_block = AlgCompound()

    cl = 2
    t = 2

    idler_offset=cl + idler.r

    sketch1 = Rectangle(
        w + dims.rail_size,
        dims.rail_size + idler_offset + idler.screw_head_r + t,
        align=(Align.CENTER, Align.MIN),
    ) @ Pos(0, -dims.rail_size)

    sketch1 -= Rectangle(idler.h + 1, large, align=(Align.CENTER, Align.MIN))

    pulley_block += extrude(sketch1, amount=h)
    pulley_block = fillet(
        pulley_block, pulley_block.edges().filter_by(Axis.Z), radius=1
    )

    bolt_hole = counterbored(dims.rail_mount_screw_r, dims.rail_mount_screw_head_r) 

    bolt_hole_2 = counterbored(idler.screw_r, idler.screw_head_r) 

    pulley_block -= bolt_hole @ Pos(w / 2, -dims.rail_size / 2, h1)
    pulley_block -= bolt_hole @ Pos(-w / 2, -dims.rail_size / 2, h1)


    pulley_block -= bolt_hole_2 @ (
        Pos(idler.h / 2 + 3, idler_offset, h / 2) * Rot(0, 90, 0)
    )

    return pulley_block



def make_angled_pulley_holder(v_pulley_screw_r=idler.screw_r):
    pulley_block = AlgCompound()

    cl = 1
    t = 4

    max_angle=60*math.pi/180

    idler_offset=(cl + idler.r)/math.cos(max_angle)

    bottom_offset=dims.rail_size/2#dims.rail_size/2+dims.rail_mount_screw_head_r+2

    w=max((dims.rail_mount_screw_head_r+2)*2, 2*t + idler.h+2*cl)

    sketch1 = Rectangle(
        2*t + idler.h+2,
        bottom_offset + cl + idler.r + idler.screw_head_r + 2*t,
        align=(Align.CENTER, Align.MIN),
    ) @ Pos(0, -bottom_offset)

    sketch1+=Circle(dims.rail_size/2)@Pos(0, -dims.rail_size/2)

    sketch1 -= Rectangle(idler.h + cl, large, align=(Align.CENTER, Align.MIN))

    pulley_block += extrude(sketch1, amount=h)
    pulley_block = fillet(
        pulley_block, pulley_block.edges().filter_by(Axis.Z), radius=1
    )

    bolt_hole = counterbored(dims.rail_mount_screw_r, dims.rail_mount_screw_head_r) 

    bolt_hole_2 = counterbored(idler.screw_r, idler.screw_head_r) 

    pulley_block -= bolt_hole @ Pos(0, -dims.rail_size / 2, h1)

    pip=Cylinder(idler.screw_r+1, 1)

    pulley_block+=pip@(
        Pos(idler.h / 2+cl, idler_offset, h / 2) * Rot(0, 90, 0)
    )

    pulley_block -= bolt_hole_2 @ (
        Pos(idler.h / 2 + 3, idler_offset, h / 2) * Rot(0, 90, 0)
    )

    return pulley_block

extrusion_clamper_obj = extrusion_clamper()
(extrusion_clamper_obj @ Rot(90, 0, 0)).export_stl("extrusion_clamper.stl")

corner_joint_obj = corner_joint()

(corner_joint_obj @ rotate_from_to((1, 1, 1), (0, 0, 1))).export_stl("corner_joint.stl")

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
       result.append(obj @ Pos(x))

    return result


#cj2=make_cutter_jig_2()

#show(*arrange(pulley_block, big_pulley, big_pulley_block,  ))
side_joint=make_side_joint()
side_joint.export_stl('side_joint.stl')

if __name__ == '__main__':
    from z_poc_winch_alg123d import winch, wh
    show(
        pulley_block,
        big_pulley @ (Pos(60, 0, 0) * pulley_2_pos),
        big_pulley_block @ Pos(60, 0, 0),
        make_pulley(idler) @ (Pos(60, 0, 0) * pulley_1_pos),
        bottom_pulley_holder @ Pos(120, 0, 0),
        extrusion_clamper() @ Pos(-60, 0, 0),
        corner_joint_obj @ (Pos(0, 120, 0) * rotate_from_to((1, 1, 1), (0, 0, 1))),
        winch.object @ Pos(180, 0, 4.5), (AlgCompound(wh) @ Pos(180, 0)),
        angled_pulley_holder @ Pos(220, 0, 4.5),
        side_joint@Pos(0, -60, 0)
    )


# show(test)
