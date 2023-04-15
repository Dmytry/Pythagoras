from build123d import *
import build123d

import math

from cq_vscode import show

import marionette_dims as dims


print(f'Build123d version: {build123d.__version__}')

large=1000
tieoff_h=35

base_r=30

hotend_above_tieoff=15
hotend_h=tieoff_h+hotend_above_tieoff

tieoff_slope=1.5*(tieoff_h/dims.diagonal_length)

heatsink_hole_circle_r=9

heatsink_r=25/2

feed_r=6

hotend_base_to_tip=69

screw_r=1.5
screw_l=30
screw_head_r=3.5
heatsink_screw_depth=8

overhang_roof=0.4


margin=1

heatsink_mount_circle_r=heatsink_hole_circle_r+screw_r+margin
heatsink_mount_circle_h=tieoff_h - tieoff_slope*heatsink_hole_circle_r

screw_placement_h=tieoff_h+hotend_above_tieoff+heatsink_screw_depth-screw_l

pts=[(0, 0), (base_r, 0), (heatsink_mount_circle_r, heatsink_mount_circle_h), 
     (heatsink_hole_circle_r-screw_r-margin, heatsink_mount_circle_h), (2, tieoff_h), (0, tieoff_h)]

s = Polyline(*pts, close=True)

carriage=revolve(Plane.XZ * make_face(s), axis=Axis.Z)
carriage_outer=carriage

n_holes=4
ccb=(Align.CENTER, Align.CENTER, Align.MIN)

cable_r=1

def symm(x):
    result=x
    for i in range(1, n_holes):
        result+=Rot(0,0,360*i/n_holes)*x
    return result

def rot_repeat(n):
    return (Rot(0,0,i*360/n) for i in range(0,n))


hole=Cylinder(screw_head_r, screw_placement_h, align=ccb) + Pos(0,0,screw_placement_h+overhang_roof)*Cylinder(screw_r, large, align=ccb)


cone_angle=math.atan2(pts[1][0]-pts[2][0], pts[2][1]-pts[1][1])

carriage-=symm(Pos(heatsink_hole_circle_r)*hole)



torus_r1=heatsink_mount_circle_r

def filled_torus(r1, r2):
    return Torus(r1, r2)+Cylinder(r1, 2*r2)

carriage-=symm(Rot(0,0,33)*Pos(torus_r1+0.1, 0, tieoff_h)*Rot(90,0,0)*Torus(torus_r1, cable_r))

tube_r=2.5

cut_r=0.5*(hotend_h-tube_r)

tube_cut=Rot(0,0,45)*Pos(cut_r, 0, hotend_h)*Rot(90,0,0)*filled_torus(cut_r, tube_r)
carriage-=tube_cut


print(f'Cone angle: {cone_angle*180/math.pi}')

tieoff_hole=Pos(0,0,10)*Rot(0, 90-cone_angle*180/math.pi,0)*Cylinder(1.35, large, align=ccb)

carriage-=Rot(0,0,45)*symm(tieoff_hole)



#carrier_l=60

carrier_l=25
# hole spacing:

hole_margin=4

carrier_bolt_spacing_x=(carrier_l-hole_margin*2)
carrier_bolt_spacing_y=2*(heatsink_r-hole_margin)

carrier_bolt_positions=[Pos(carrier_l/2+(j-0.5)*carrier_bolt_spacing_x, (i-0.5)*carrier_bolt_spacing_y) for i in range(0,2) for j in range(0,2)]

print(f'Spacing: long ways {carrier_bolt_spacing_x}, short ways: {carrier_bolt_spacing_y}')

def hotend_carrier():
    t=4

    side_t=3
    result=Box(carrier_l, (heatsink_r+side_t)*2, t, align=(Align.MIN, Align.CENTER, Align.MIN))

    axis_offset=t+heatsink_r
    mount_plate_s=Rectangle(axis_offset, (heatsink_r+side_t)*2, align=(Align.MIN, Align.CENTER))
    
    mount_plate_s+=Pos(axis_offset)*Circle(heatsink_r+side_t)

    for p in rot_repeat(8):
        mount_plate_s-=Pos(axis_offset)*p*Pos(heatsink_hole_circle_r)*Circle(screw_r)

    hole_r=max(feed_r, heatsink_hole_circle_r-screw_r-2)

    mount_plate_s-=Pos(axis_offset)*Circle(hole_r)

    #mount_plate_s-=Pos(axis_offset)*rot_repeat(8)*Pos(heatsink_hole_circle_r)*Circle(screw_r)

    result+=extrude(Plane.ZY*mount_plate_s, amount=t, dir=(-1,0,0))

    side=Polygon((-t, 0), (carrier_l, 0), (carrier_l, t), (0, axis_offset), (-t, axis_offset), align=None)

    bar_t=4*math.hypot(carrier_l, axis_offset)/carrier_l
    side-=Polygon((0, t), (carrier_l-(carrier_l/axis_offset)*bar_t, t), (0, axis_offset-bar_t), align=None)

    side=extrude(Plane.XZ * side, amount=side_t, dir=(0,1,0))

    result+=Pos(0,-(heatsink_r+side_t),0)*side

    result+=Pos(0,heatsink_r,0)*side

    m3_bolt_and_nut_hole=Cylinder(radius=1.6, height=large, align=(Align.CENTER, Align.CENTER, Align.MAX))
    m3_bolt_and_nut_hole+=extrude(RegularPolygon(radius=3.1, side_count=6), amount=10, dir=(0,0,1))

    nut_h=t-2

    #result-=Pos(spacing, heatsink_r-spacing, nut_h)*m3_bolt_and_nut_hole

    #bolts=GridLocations(l-2*spacing, heatsink_r, 3, 2, align=(Align.MIN, Align.CENTER))*Pos(spacing, 0, nut_h)*m3_bolt_and_nut_hole

    
    # for i in range(0,2):
    #     for j in range(0, 2):
    #         result-=Pos(carrier_l/2+(j-0.5)*carrier_bolt_spacing_x, (i-0.5)*carrier_bolt_spacing_y, nut_h)*m3_bolt_and_nut_hole
    for p in carrier_bolt_positions:
        result-=Pos(0,0, nut_h)*p*m3_bolt_and_nut_hole


    #result-=GridLocations(10, 10, 2, 2)*m3_bolt_and_nut_hole

    return result

carrier=hotend_carrier()

cut2=None

def mirror_pts(pts):
    return pts+[(a[0], -a[1]) for a in pts[::-1]]

def adjustable_hole(r, h):
    return Pos(-h / 2) * Circle(r) + Pos(h / 2) * Circle(r) + Rectangle(h, 2 * r)

def make_connector():

    l=hotend_base_to_tip-heatsink_mount_circle_r
    global cut2
    angle=12
    t=4
    side_t=3

    adjust=4

    grab_t=20
    grab_back=15

    hole_r=1.65

    top_sketch_pts=[(-t,heatsink_r+side_t), (carrier_l+adjust, heatsink_r+side_t), (hotend_base_to_tip, 0)]

    top_sketch=Polygon(*mirror_pts(top_sketch_pts), align=None)

    
    plate=extrude(top_sketch, amount=t, dir=(0,0,-1))    
    

    #result+=Pos(l)*Box(grab_back, (heatsink_r+side_t)*2, grab_t, align=(Align.MAX, Align.CENTER, Align.MAX))

    side_poly=Polygon((-t,0), (-t, -t), (l-grab_back, -grab_t), (l, 0), align=None)


    body=extrude(top_sketch, amount=large, dir=(0,0,-1))
    body&=Pos(0, -large/2, 0)*extrude(Plane.XZ * side_poly, amount=large, dir=(0,1,0))

    result=body
  

    #result+=Pos(0,-heatsink_r-side_t,0)*side
    #result+=Pos(0,heatsink_r,0)*side

    cut2=Pos(hotend_base_to_tip, 0, heatsink_r)*Rot(0,angle,0)*Pos(0,0,-tieoff_h-heatsink_r)*carriage_outer

    result-=cut2

    result=offset(result, -side_t, openings=(result.faces().sort_by(Axis.Z).first, result.faces().sort_by(Axis.Z).last), mode=Mode.SUBTRACT)

    result+=Pos(-t)*Box(carrier_l+t+adjust, (heatsink_r+side_t)*2, t, align=(Align.MIN, Align.CENTER, Align.MAX))

    #result-=list(carrier_bolt_positions)*Cylinder(radius=1.65, height=large)
    hole=Pos(0,0,-large/2)*extrude(adjustable_hole(r=hole_r, h=adjust), amount=large, dir=(0,0,1))

    # for p in carrier_bolt_positions:
    #     result-=p*hole

    result-=carrier_bolt_positions*hole

    alpha=angle+cone_angle*180/math.pi - 90

    result-=Pos(45)*Rot(0, alpha,0)*Cylinder(hole_r, 100)

    result-=Pos(35)*Rot(0, alpha,0)*Cylinder(hole_r, 100)
    result-=Pos(25)*Rot(0, alpha,0)*Cylinder(hole_r, 100)


    return result
    

connector=make_connector()

show(carrier, Pos(0,150,0)*connector, Pos(150,0,0)*carriage, Pos(1,150,0)*cut2)

carriage.export_stl("marionette_carriage.stl")


# instead of separate connector, the definite version should have it single-piece-d with the carriage

(Rot(180,0,0)*connector).export_stl("marionette_hotend_connector.stl")



carrier.export_stl("hotend_carrier.stl")


