# from build123d import *
# .venv/lib/python3.10/site-packages/build123d-0.1.dev560+g99bb3a5.dist-info
from alg123d import *

from cq_vscode import show
import math


print_dilation=0.15 # when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.2 # max 0.2
print_single_wall=0.5
eps=1E-3 # epsilon to use so preview is correct
screw_r=3/2+print_dilation_max

hole_spacing=14
margin=3
w=hole_spacing+margin*2

adjust=6

angle=22.5*math.pi/180

h_above_bed=40

probe_h=w*math.tan(angle)+1

probe_base_h=h_above_bed - probe_h + margin + adjust/2
t=3

# slight margin
magnet_r=2.6
magnet_t=1

wire_r=0.5

magnet_base_width=10

large=2000

rail_w=20

def counterbored(r_bolt, r_bolt_head):
    return Cylinder(radius=r_bolt, height=large) + Cylinder(
        radius=r_bolt_head, height=10000, align=(Align.CENTER, Align.CENTER, Align.MIN)
    )

def adjustable_hole(h, r):
    return Circle(r)@Pos(0,-h/2) + Circle(r)@Pos(0,h/2) + Rectangle(2*r, h)

vis_aux=AlgCompound()

def magnet_hole(wires=False):
    result=Cylinder(magnet_r, magnet_t-0.2, align=(Align.CENTER, Align.CENTER, Align.MIN))
    if wires :
        result+=Cylinder(wire_r, large)@Pos(magnet_r-wire_r)
        result+=Cylinder(wire_r, large)@Pos(-(magnet_r-wire_r))
        result+=Cylinder(wire_r, magnet_r*2)@(Pos(0,0,magnet_t-0.2)*Rot(0,90,0))

    return result

def make_probe_base():
    sketch=Rectangle(w, probe_base_h, align=(Align.CENTER, Align.MIN))
    hole=adjustable_hole(adjust, screw_r)
    sketch-=hole @ Pos(-hole_spacing/2, probe_base_h - margin - adjust/2)
    sketch-=hole @ Pos(+hole_spacing/2, probe_base_h - margin - adjust/2)
    result=extrude(sketch, t)
    result+=Box(t, probe_base_h, magnet_base_width, align=(Align.MIN, Align.MIN, Align.MIN))@Pos(w/2, 0, 0)
    bottom=Box(w, t, magnet_base_width, align=(Align.MIN, Align.MIN, Align.MIN))@Pos(-w/2, 0, 0)
    result+=bottom

    # holes for the magnets and wires
    magnet_pos=Pos(-w/2+magnet_r+1, 0, magnet_base_width/2)*Rot(-90,0,0)
    hole=magnet_hole(True)
    result-=hole@magnet_pos
    magnet_pos_2=Pos(-w/2+magnet_r*3+2, 0, magnet_base_width/2)*Rot(-90,0,0)
    result-=hole@magnet_pos_2

    return result

bottom=(Align.CENTER, Align.CENTER, Align.MIN)

def make_probe():    
    global vis_aux    
    probe_w=magnet_r*4 + 3
    h=magnet_r*2+2
    
    t=1
    screw_r=0.9
    
    sketch=make_face(Polyline([(0,0), (0, -t), (math.cos(angle)*probe_w, -t-math.sin(angle)*probe_w), (probe_w, -t), (probe_w, 0)], close=True))
    result=extrude(sketch, h)
    pos=Pos(0, -t, h/2)*Rot(0, 0, -angle*180/math.pi)*Rot(0,90,0)

    cap=ThreePointArc((-h/2, 0), (0, screw_r+1), (h/2, 0))
    cap+=Line((h/2, 0), (-h/2, 0))
    cap=extrude(make_face(cap), probe_w, dir=(0,0,1))

    #result+=Cylinder(cyl2_r, probe_w, align=(Align.CENTER, Align.MIN, Align.MIN), arc_size=180)@(pos * Rot(0,0,180))
    result+=cap@(pos * Rot(0,0,180))


    result-=Cylinder(screw_r, w*3, align=bottom)@(pos * Pos(0,0,3))

    vis_aux+=Cylinder(screw_r*0.5, probe_w+15, align=bottom)@(pos * Pos(0,0,3))

    hole=magnet_hole(False)

    result -= hole@Pos(magnet_r+1, h/2)*Rot(90,0,0)
    result -= hole@Pos(magnet_r*3+2, h/2)*Rot(90,0,0)

    result -= Cylinder(0.8, 1+magnet_r*4, align=bottom)@(Pos(1, 0.2-magnet_t,  h/2)*Rot(0,90,0))

    return result


def make_dock():
    global vis_aux  
    dock_l=65
    dock_h=55
    probe_l=37
    clearance=1.5
    probe_w=2*(magnet_r+1+clearance)

    screw_l=8
    screw_r=2.15
    screw_head_r=3.9
    rail_depth=5

    t=2

    probe_depth=5
    
    pts=[
        (0,0),
        (screw_l-rail_depth, 0),
        (dock_l+t, dock_h-probe_depth-t),
        (dock_l+t, dock_h),
        (dock_l-probe_l-t, dock_h),
        (0, 30)
    ]

    sketch=make_face(Polyline(pts, close=True))
    result=extrude(sketch, rail_w, dir=(0,0,1))

    pts2=[
        (0, 0),
        (screw_l-rail_depth, 0),
        (dock_l-probe_l-t, rail_w/2-probe_w/2-t),
        (dock_l+t, rail_w/2-probe_w/2-t),
        (dock_l+t, rail_w/2+probe_w/2+t),
        (dock_l-probe_l-t, rail_w/2+probe_w/2+t),
        (screw_l-rail_depth, rail_w),
        (0, rail_w)
    ]
    sketch2=make_face(Polyline(pts2, close=True))
    profile2=extrude(sketch2@Plane.XZ, dock_h*2, dir=(0,1,0))
    result&=profile2

    pts3=[
        (0,0),
        (0, -probe_l*math.tan(angle)-probe_depth+2),
        (probe_l, 2-probe_depth),
        (probe_l, 0)
    ]
    pts4=[
        (0,0),
        (0, -probe_l*math.tan(angle)-probe_depth),
        (probe_l, -probe_depth),
        (probe_l, 0)
    ]
    bottom=Wire.make_polygon(pts3, close=True)
    mid=Wire.make_polygon(pts4, close=True)
    loft=Solid.make_loft([bottom, mid.moved(Location((0,0,probe_w/2))), bottom.moved(Location((0,0,probe_w)))])

    
    result-=AlgCompound(loft)@Pos(dock_l-probe_l, dock_h, rail_w/2 - probe_w/2)

    result-=counterbored(screw_r, screw_head_r)@(Pos(screw_l-rail_depth, 5, rail_w/2)*Rot(0,90,0))
    result-=counterbored(screw_r, screw_head_r)@(Pos(screw_l-rail_depth, 25, rail_w/2)*Rot(0,90,0))
    return AlgCompound(result@Rot(0,-90,0))
    

pb=make_probe_base()
p=make_probe()
d=make_dock()
pb.export_stl("probe_base.stl")
p.export_stl("probe.stl")
d.export_stl("dock.stl")


show(pb, p@Pos(-w/2, -3, magnet_base_width/2-3.5),  vis_aux@Pos(-w/2, -3, magnet_base_width/2-3.5), 
    d@Pos(0,-80,0),
    axes=True, axes0=True)