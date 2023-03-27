from build123d import *

import math

from cq_vscode import show

import marionette_dims as dims


large=1000
tieoff_h=35

base_r=30

hotend_above_tieoff=15
hotend_h=tieoff_h+hotend_above_tieoff

tieoff_slope=1.5*(tieoff_h/dims.diagonal_length)

heatsink_hole_circle_r=9

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

n_holes=4
ccb=(Align.CENTER, Align.CENTER, Align.MIN)

cable_r=1

def symm(x):
    result=x
    for i in range(1, n_holes):
        result+=Rot(0,0,360*i/n_holes)*x
    return result

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


carriage.export_stl("marionette_carriage.stl")

show(carriage, tube_cut, colors=[None, 'red'])

