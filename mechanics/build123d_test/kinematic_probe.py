# from build123d import *
# .venv/lib/python3.10/site-packages/build123d-0.1.dev560+g99bb3a5.dist-info
# from alg123d import *
from build123d import *

from cq_vscode import show, show_object
import math


print_dilation = 0.15  # when printing the shape gets dilated typically by 0.15mm
print_dilation_max = 0.2  # max 0.2
print_single_wall = 0.5
eps = 1e-3  # epsilon to use so preview is correct
screw_r = 3 / 2 + print_dilation_max

hole_spacing = 14
margin = 3
w = hole_spacing + margin * 2

adjust = 6

h_above_bed = 40

probe_t = 4

# slight margin
magnet_r = 2.6
magnet_t = 1

wire_r = 0.7

wire_hole_r = 0.7

wall = 0.4

magnet_base_width = 10

large = 2000

rail_w = 20

probe_r = 10

probe_contact_r = (probe_r + magnet_r) / 2


probe_screw_l=5

probe_base_h = h_above_bed - probe_r-probe_screw_l


dock_rail_to_probe=50

dock_clearance=1
probe_hold_margin=3


dock_h = 65

dock_standoff=10

def counterbored(r_bolt, r_bolt_head):
    return Cylinder(radius=r_bolt, height=large) + Cylinder(
        radius=r_bolt_head, height=10000, align=(Align.CENTER, Align.CENTER, Align.MIN)
    )


def adjustable_hole(h, r):
    return Pos(0, -h / 2) * Circle(r) + Pos(0, h / 2) * Circle(r) + Rectangle(2 * r, h)


vis_red = Part()
vis_green = Part()

ccb = (Align.CENTER, Align.CENTER, Align.MIN)


def magnet_hole(wires=False):
    result = Cylinder(
        magnet_r, magnet_t - 0.2, align=(Align.CENTER, Align.CENTER, Align.MIN)
    )
    if wires:
        result += Pos(magnet_r - wire_r) * Cylinder(wire_r, large)
        result += Pos(-(magnet_r - wire_r)) * Cylinder(wire_r, large)
        result += (
            Pos(0, 0, magnet_t - 0.2) * Rot(0, 90, 0) * Cylinder(wire_r, magnet_r * 2)
        )

    return result


def symm(x):
    return x + Rot(0, 0, 120) * x + Rot(0, 0, -120) * x


def make_mount():
    sketch = Rectangle(w, probe_base_h, align=(Align.CENTER, Align.MIN))
    hole = adjustable_hole(adjust, screw_r)
    sketch -= Pos(-hole_spacing / 2, probe_base_h - margin - adjust / 2) * hole
    sketch -= Pos(+hole_spacing / 2, probe_base_h - margin - adjust / 2) * hole
    result = extrude(sketch, probe_t)
    # result+=Box(t, probe_base_h, magnet_base_width, align=(Align.MIN, Align.MIN, Align.MIN))@Pos(w/2, 0, 0)
    # result+=Pos(-w/2, 0, 0) * Box(t, probe_base_h, magnet_base_width, align=(Align.MAX, Align.MIN, Align.MIN))
    return result


class WireSupport:
    def __init__(self, w=4, h=4, ws=2.5):
        s = Polyline(
            (w / 2 + wire_hole_r + wall, h),
            (w / 2 + wire_hole_r + wall, 0),
            (-w / 2 - wire_hole_r - wall, 0),
            close=True,
        )

        self.positive = (
            Rot(90, 0, 0)
            * Pos(0, 0, -ws / 2)
            * extrude(make_face(s), ws, dir=(0, 0, 1))
        )

        show_object(self.positive)

        self.negative = Pos(-w / 2, 0, 0) * Cylinder(wire_hole_r, large)
        self.negative += Pos(w / 2, 0, 0) * Cylinder(wire_hole_r, large)


bottom = (Align.CENTER, Align.CENTER, Align.MIN)

def make_probe_base():
    vh = 4

    angle = 50
    angle_rad = angle * math.pi / 180
    slope = math.tan(angle_rad)

    tip_w = 0.2

    s = Polygon((-vh * slope, vh), (0, 0), (vh * slope, vh), align=None)

    tri = extrude(Plane.XZ * s, amount=probe_r, dir=(0, -1, 0))
    tri += Pos(0, 0, vh) * Cylinder(probe_r, large, align=ccb)

    s = Circle(radius=probe_r)

    # wire_holes=Pos(0,-magnet_r-wire_r-0.5)*Circle(wire_hole_r)
    # wire_holes+=Pos(0,-probe_r+wire_r+0.5)*Circle(wire_hole_r)

    stagger = wire_r * 1.1

    # wire_holes=Pos(0, -probe_contact_r-stagger, t)*Rot(0,angle,0)*Pos(-wire_hole_r)*Cylinder(wire_hole_r, large)
    # wire_holes+=Pos(0, -probe_contact_r+stagger, t)*Rot(0,-angle,0)*Pos(wire_hole_r)*Cylinder(wire_hole_r, large)

    wire_holes = (
        Pos(0, -probe_contact_r - stagger, probe_t)
        * Pos(-wire_hole_r)
        * Cylinder(wire_hole_r, large)
    )
    wire_holes += (
        Pos(0, -probe_contact_r + stagger, probe_t)
        * Pos(wire_hole_r)
        * Cylinder(wire_hole_r, large)
    )

    wire_holes += Pos(5, -probe_contact_r - stagger, 0) * Cylinder(wire_hole_r, large)
    wire_holes += Pos(-5, -probe_contact_r + stagger, 0) * Cylinder(wire_hole_r, large)

    result = extrude(s, probe_t + vh + 2)

    result += Rot(0, 0, 180) * make_mount()

    result -= symm(wire_holes)

    result -= Pos(0, 0, probe_t) * symm(tri)

    result -= Pos(0, 0, probe_t - magnet_t) * Cylinder(magnet_r, large, align=ccb)

    return result


def make_probe():
    vh = 5

    angle = 30
    angle_rad = angle * math.pi / 180
    slope = math.tan(angle_rad)

    tip_w = 0.2

    s = Polygon(
        (-vh * slope, 0), (-tip_w, vh), (tip_w, vh), (vh * slope, 0), align=None
    )

    tri = extrude(Plane.XZ * s, amount=probe_r, dir=(0, -1, 0))
    tri = Cylinder(probe_r+probe_hold_margin, probe_t, align=ccb) + Pos(0, 0, probe_t) * tri

    s = Circle(radius=probe_r)

    r = probe_contact_r

    wire_holes = Pos(0, -magnet_r - wire_r - 0.5) * Circle(wire_hole_r)
    wire_holes += Pos(0, -probe_r + wire_r + 0.5) * Circle(wire_hole_r)

    

    wire_donut = Torus(wire_r * 1.5, wire_r * 0.75)

    # vis_red+=symm(Pos(-wire_r*2.5,-r-stagger, t-0.25)*Rot(90,0,0)*wire_donut)
    # vis_red+=symm(Pos(wire_r*2.5,-r+stagger, t-0.25)*Rot(90,0,0)*wire_donut)
    # vis_green+=symm(Pos(0, -r, t+wire_r)*Rot(90,0,0)*Cylinder(wire_r*0.75, 5))

    # show_object(s)
    result = extrude(s, probe_t + vh + 2)

    result+=Cylinder(probe_r+probe_hold_margin, probe_t, align=ccb)
    result-=symm(extrude(wire_holes, amount=large, dir=(0,0,1)))

    result -= Pos(0, 0, probe_t + vh - magnet_t) * Cylinder(magnet_r, large, align=ccb)

    for i in range(30, 91, 30):
        for j in range(0, 360, 120):
            result -= (
                Rot(0, 0, i + j)
                * Pos(0, 0, probe_t / 2)
                * Rot(90, 0, 0)
                * Cylinder(0.9, large, align=ccb)
            )

    result &= symm(tri)

    return result



def make_dock():    
    global vis_aux

    t = 2

    probe_outer_r=probe_r+probe_hold_margin

    dock_inner_r=probe_outer_r+dock_clearance
    dock_outer_r=dock_inner_r+t

    dock_l = dock_rail_to_probe+probe_outer_r+dock_clearance

    angle=22.5

    probe_l = 30
    clearance = 1.5
    probe_w = 2 * (magnet_r + 1 + clearance)

    screw_l = 8
    screw_r = 2.15
    screw_head_r = 3.9
    rail_depth = 5

    

    probe_depth = 5

    pts = [
        (0, 0),
        (dock_standoff, 0),
        (dock_rail_to_probe, dock_h - dock_outer_r),
        (dock_rail_to_probe+dock_outer_r, dock_h),
        (dock_rail_to_probe-dock_outer_r, dock_h),
        (dock_standoff, 30),
        (0, 30)
    ]

    ptsh = [
        (dock_standoff, 30),
        (dock_rail_to_probe-dock_outer_r, dock_h),
        (dock_rail_to_probe+dock_outer_r, dock_h) ,
        (dock_rail_to_probe, dock_h - dock_outer_r)  ,
        (dock_standoff, 0) 
    ]

    sketch = make_face(Polyline(*pts, close=True))

    c=Circle(radius=probe_r+probe_hold_margin+dock_clearance+t)&Rectangle(large, large, align=(Align.CENTER, Align.MAX))

        
    c_h=Pos(dock_rail_to_probe, dock_h)*c + make_face(Polyline(*ptsh, close=True))


    hull=make_hull(*c_h.edges())
    # fix winding order
    hull=mirror(hull, about=Plane.XY)

    sketch+=hull

    result = extrude(sketch, rail_w, dir=(0, 0, 1))

    

    pts2 = [
        (0, 0),
        (screw_l - rail_depth, 0),
        (dock_l - probe_l - t, rail_w / 2 - probe_w / 2 - t),
        (dock_l + t, rail_w / 2 - probe_w / 2 - t),
        (dock_l + t, rail_w / 2 + probe_w / 2 + t),
        (dock_l - probe_l - t, rail_w / 2 + probe_w / 2 + t),
        (screw_l - rail_depth, rail_w),
        (0, rail_w),
    ]
    sketch2 = make_face(Polyline(*pts2, close=True))
    profile2 = extrude(Plane.XZ * sketch2, dock_h * 2, dir=(0, 1, 0))
    result &= profile2

    #show_object(result)

    # OCCP does not want to fillet it, even though it is not that complex of a shape
    #result=fillet(*result.edges(), radius=0.5)

    

    hole_h=probe_t+dock_clearance*2
    probe_body_hole=Cylinder(probe_r+dock_clearance, large) + Cylinder(probe_r+probe_hold_margin+dock_clearance, hole_h, align=ccb)

    cut_w=10
    probe_body_hole+=Box(cut_w, large, large, align=ccb)

    result-=Pos(dock_rail_to_probe, dock_h, rail_w/2-hole_h/2)*probe_body_hole


    result -= (
        Pos(screw_l - rail_depth, 5, rail_w / 2)
        * Rot(0, 90, 0)
        * counterbored(screw_r, screw_head_r)
    )
    result -= (
        Pos(screw_l - rail_depth, 25, rail_w / 2)
        * Rot(0, 90, 0)
        * counterbored(screw_r, screw_head_r)
    )

    
    return Rot(0, -90, 0) * result
    #return result


pb = make_probe_base()

p = make_probe()

pb.export_stl("kin_probe_base.stl")
pb.export_step("kin_probe_base.stp")
p.export_stl("kin_probe.stl")
p.export_step("kin_probe.stp")

d=make_dock()
d.export_stl("kin_dock.stl")
d.export_step("kin_dock.stp")

show(pb, Pos(0, 50, 0) * p, Pos(50,0,0)*d, axes=True, axes0=True)
