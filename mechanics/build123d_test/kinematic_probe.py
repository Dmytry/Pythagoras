# from build123d import *
# .venv/lib/python3.10/site-packages/build123d-0.1.dev560+g99bb3a5.dist-info
#from alg123d import *
from build123d import *

from cq_vscode import show, show_object
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
t=4

# slight margin
magnet_r=2.6
magnet_t=1

wire_r=0.7

wire_hole_r=0.9

wall=0.4

magnet_base_width=10

large=2000

rail_w=20

probe_r=10

probe_contact_r=(probe_r+magnet_r)/2

hole_spacing=20

probe_mount_hole_r=1

def counterbored(r_bolt, r_bolt_head):
    return Cylinder(radius=r_bolt, height=large) + Cylinder(
        radius=r_bolt_head, height=10000, align=(Align.CENTER, Align.CENTER, Align.MIN)
    )

def adjustable_hole(h, r):
    return Pos(0,-h/2) * Circle(r) + Pos(0,h/2) * Circle(r) + Rectangle(2*r, h)

vis_red=Part()
vis_green=Part()

ccb=(Align.CENTER, Align.CENTER, Align.MIN)

def magnet_hole(wires=False):
    result=Cylinder(magnet_r, magnet_t-0.2, align=(Align.CENTER, Align.CENTER, Align.MIN))
    if wires :
        result+=Pos(magnet_r-wire_r) * Cylinder(wire_r, large)
        result+=Pos(-(magnet_r-wire_r)) * Cylinder(wire_r, large)
        result+=Pos(0,0,magnet_t-0.2) * Rot(0, 90,0)*Cylinder(wire_r, magnet_r*2)

    return result

def symm(x):
        return x + Rot(0,0,120)*x + Rot(0,0,-120)*x


class WireSupport:
    def __init__(self, w=3, h=4, ws=2.5):
        s=Polyline((w/2+wire_hole_r+wall, h), (w/2+wire_hole_r+wall, 0), (-w/2-wire_hole_r-wall, 0), close=True)

        self.positive=Rot(90,0,0)*Pos(0,0,-ws/2)*extrude(make_face(s), ws, dir=(0,0,1))

        show_object(self.positive)


        self.negative=Pos(-w/2,0,0)*Cylinder(wire_hole_r, large)
        self.negative+=Pos(w/2,0,0)*Cylinder(wire_hole_r, large)


def make_probe_base():
    global vis_red, vis_green
    s=Circle(radius=probe_r)
    grab_r=3
    s+=Rectangle(hole_spacing, grab_r*2)
    l=Locations((hole_spacing/2,0,0), (-hole_spacing/2,0,0) )
    for p in l:
        s+=p*Circle(grab_r)
    for p in l:
        s-=p*Circle(probe_mount_hole_r)
    
    stagger=wire_r*1.5

    shift=1

    r=probe_contact_r

    wire_support=WireSupport()

    # wire_holes=Pos(-shift,-r-stagger)*Circle(wire_hole_r)
    # wire_holes+=Pos(-wire_r*4,-r-stagger)*Circle(wire_hole_r)

    # wire_holes+=Pos(shift,-r+stagger)*Circle(wire_hole_r)
    # wire_holes+=Pos(wire_r*4,-r+stagger)*Circle(wire_hole_r)

    
    #s-=symm(wire_holes)



    wire_donut=Torus((wire_r*4-shift)/2, wire_r*0.75)

    donut_shift=(wire_r*4+shift)/2

    result=extrude(s, t)


    def place_conns(x):
        return symm(Pos(shift, -probe_contact_r-stagger)*x+
                    Pos(-shift, -probe_contact_r+stagger)*mirror(x, about=Plane.YZ) )

    result+=place_conns(Pos(0,0,t)*wire_support.positive)

    ridge_r=(wire_r*4-shift)/2-wire_r
    ridge_l=2.5
    ridge_h=0.5

    ridge=Rot(90,0,0)*(Box(ridge_r*2, ridge_h*2, ridge_l)+Pos(0,ridge_h,0)*Cylinder(ridge_r, ridge_l))

    #result+=symm(Pos(-donut_shift,-r-stagger, t)*ridge)
    #result+=symm(Pos(donut_shift,-r+stagger, t)*ridge)

    #vis_red+=symm(Pos(-donut_shift,-r-stagger, t-0.25+ridge_h)*Rot(90,0,0)*wire_donut)
    #vis_red+=symm(Pos(donut_shift,-r+stagger, t-0.25+ridge_h)*Rot(90,0,0)*wire_donut)
    vis_green+=symm(Pos(0, -r, t+3)*Rot(90,0,0)*Cylinder(wire_r*0.75, 5))

    #show_object(s)

    result-=place_conns(Pos(0,0,t)*wire_support.negative)
    

    result-=Pos(0, 0, t-magnet_t)*Cylinder(magnet_r, large, align=ccb)
    vis_red+=Pos(0, 0, t-magnet_t)*Cylinder(magnet_r, magnet_t, align=ccb)

    #result-=Cylinder(probe_r-2, 1.5, align=ccb)

    return result

bottom=(Align.CENTER, Align.CENTER, Align.MIN)

def make_probe():    
    s=Circle(radius=probe_r)
    
    r=probe_contact_r

    #wire_holes=Pos(0,-r-wire_r*2)*Circle(wire_hole_r)
    #wire_holes+=Pos(0,-r+wire_r*2)*Circle(wire_hole_r)
    wire_holes=Pos(0,-magnet_r-wire_r-0.5)*Circle(wire_hole_r)
    wire_holes+=Pos(0,-probe_r+wire_r+0.5)*Circle(wire_hole_r)

    s-=symm(wire_holes)

    wire_donut=Torus(wire_r*1.5, wire_r*0.75)

    #vis_red+=symm(Pos(-wire_r*2.5,-r-stagger, t-0.25)*Rot(90,0,0)*wire_donut)
    #vis_red+=symm(Pos(wire_r*2.5,-r+stagger, t-0.25)*Rot(90,0,0)*wire_donut)
    #vis_green+=symm(Pos(0, -r, t+wire_r)*Rot(90,0,0)*Cylinder(wire_r*0.75, 5))

    #show_object(s)
    result=extrude(s, t)

    result-=Pos(0, 0, t-magnet_t)*Cylinder(magnet_r, large, align=ccb)

    result-=Pos(0,magnet_r+0.2,t/2)*Rot(-90,0,0)*Cylinder(0.9, large, align=ccb)

    return result

dock_l=65
dock_h=55

def make_dock():
    global vis_aux  
    
    probe_l=30
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

    sketch=make_face(Polyline(*pts, close=True))
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
    sketch2=make_face(Polyline(*pts2, close=True))
    profile2=extrude(Plane.XZ * sketch2, dock_h*2, dir=(0,1,0))
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

    
    result -= Pos(dock_l-probe_l, dock_h, rail_w/2 - probe_w/2) * loft

    result-=Pos(screw_l-rail_depth, 5, rail_w/2) * Rot(0,90,0) * counterbored(screw_r, screw_head_r)
    result-=Pos(screw_l-rail_depth, 25, rail_w/2) * Rot(0,90,0) * counterbored(screw_r, screw_head_r)
    return Rot(0,-90,0) * result
    

pb=make_probe_base()

p=make_probe()
# d=make_dock()
pb.export_stl("kin_probe_base.stl")
p.export_stl("kin_probe.stl")
# d.export_stl("kin_dock.stl")

show(vis_red, vis_green, pb, Pos(0,50,0)*p, colors=['red', 'green', None, None],
    axes=True, axes0=True)
