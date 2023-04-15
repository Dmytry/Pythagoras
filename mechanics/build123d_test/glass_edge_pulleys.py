from build123d import *
import build123d
import math
from utils123d import *
import marionette_dims as dims

from cq_vscode import show, show_object


def make_pulley(p):
    flange = 2
    pts = [(p.ir, 0), (p.r, 0), (p.rr, p.h / 2), (p.r, p.h), (p.ir, p.h)]
    s = Polyline(*pts, close=True)
    return Pos(0,0,-p.h/2)*revolve(Plane.XZ * make_face(s), axis=Axis.Z)


support_t=0.4

angle_deg=45
angle=angle_deg*math.pi/180.0

w = 30

idler = dims.idler

# grabbing thickness
t = 2

cl = 0.5

cable_h_over_glass = 30 - idler.rr  # approx 25

# TODO: calculate from dims
cable_offset_from_glass_edge = 13
in_cable_h_over_glass=7

top_axis_h = cable_h_over_glass - idler.rr

head_r = 3
nut_r = 3.3
nut_h = 2.3

grab_support = cable_h_over_glass

top_h = top_axis_h + idler.screw_r + t

bottom_h = -dims.glass_t - t - head_r - nut_r - t

large = 200


pulley_1_pos=Pos(-idler.rr, -cable_offset_from_glass_edge, in_cable_h_over_glass)*Rot(angle_deg, 0, 0)*Pos(0, idler.rr, 0)

contact_h=cable_h_over_glass-in_cable_h_over_glass-idler.rr+math.cos(angle)*idler.rr
contact_d=contact_h*math.tan(math.pi/2-angle)+idler.rr*math.sin(angle)
pulley_2_pos=Pos(0, contact_d-cable_offset_from_glass_edge, top_axis_h)*Rot(0,90,0)

def transform_point(loc, pt):
    return (loc*Pos(pt)).position

cut_bottom=top_axis_h-idler.r-cl

skxz_pts = [
    (-w / 2, -dims.glass_t - t),
    (-w / 2, t),
    (-t - idler.h / 2 - cl, top_h),
    (-idler.h / 2 - cl, top_h),
    (-idler.h / 2 - cl, cut_bottom),
    (idler.h / 2 + cl, cut_bottom),
    (idler.h / 2 + cl, top_h),
    (idler.h / 2 + cl + t, top_h),
    (w / 2, t),
    (w / 2, -dims.glass_t - t),
]

skxz = Polygon(*skxz_pts, align=None)

ymin = cl - (cable_offset_from_glass_edge - idler.h / 2)

grab_bottom = 2

supported_corner=(grab_bottom, -dims.glass_t)

skyz_pts = [    
    (grab_support, t),
    (pulley_2_pos.position.Y+idler.screw_r+t, top_h),
    (pulley_2_pos.position.Y-(idler.screw_r+t), top_h),
    (transform_point(pulley_1_pos, (0, idler.r+1, -idler.h/2-cl)).Y, transform_point(pulley_1_pos, (0, idler.r+1, -idler.h/2-cl)).Z),
    (transform_point(pulley_1_pos, (0, -idler.r, -idler.h/2-cl)).Y, transform_point(pulley_1_pos, (0, -idler.r, -idler.h/2-cl)).Z),
    (-nut_r-t, -dims.glass_t-t),
    (-nut_r-t, -dims.glass_t-t-head_r),
    (nut_r + t, -dims.glass_t-t-head_r),
    (nut_r + t, -dims.glass_t - t),
    (grab_bottom, -dims.glass_t - t),
    #(grab_bottom, -dims.glass_t),
    supported_corner,
    (0, -dims.glass_t),
    (0, 0),
    (grab_support, 0)
]

#normal of the face that we'll point downwards

dir_y=skyz_pts[1][1]-skyz_pts[0][1] 
dir_z=skyz_pts[0][0]-skyz_pts[1][0]

skyz = Polygon(*skyz_pts, align=None) # +Pos(0, -dims.glass_t-t-head_r)*(Circle(nut_r+t)&Rectangle(large, large, align=(Align.CENTER, Align.MAX)))

a=math.atan2(dir_z, dir_y)

if support_t>0:
    skyz-=Pos(supported_corner)*Rot(0,0,math.atan2(dir_z, dir_y)*180/math.pi)*Pos(dims.glass_t/math.sin(a))*Circle(1)
    skyz+=Pos(supported_corner)*Rot(0,0,math.atan2(dir_z, dir_y)*180/math.pi)*Pos(-1)*Rectangle(dims.glass_t/math.sin(a)+2, support_t, align=(Align.MIN, Align.CENTER))


skxy_pts = [
    (-w / 2, -large),
    (-w / 2, nut_r+t),
    (-w/2, grab_support),
    (w/2, grab_support),
    (w / 2, nut_r+t),
    (w / 2, -large),
]

skxy = Polygon(*skxy_pts, align=None)

# show_object(Plane.XZ * skxz, "Sketch_xz")
# show_object(Plane.YZ * skyz, "Sketch_yz")
# show_object(Plane.XY * skxy, "Sketch_xy")

part = (
    Pos(0,-large/2,0)*extrude(Plane.XZ * skxz, amount=large, dir=(0,1,0))
    & Pos(-large/2, 0, 0)*extrude(Plane.YZ * skyz, amount=large, dir=(1,0,0))
    & Pos(0,0,-large/2)*extrude(Plane.XY * skxy, amount=large, dir=(0,0,1))
)

m3_bolt_and_nut_hole=Cylinder(radius=1.65, height=large, align=(Align.CENTER, Align.CENTER, Align.MAX))
m3_bolt_and_nut_hole+=extrude(RegularPolygon(radius=nut_r, side_count=6), amount=10, dir=(0,0,1))

# part-=Pos(-w/2+nut_h, 0, -dims.glass_t - t - head_r)*rotate_from_to((0,0,1), (-1,0,0)) * m3_bolt_and_nut_hole


idler_cut_through=Cylinder(idler.screw_r, large)+Cylinder(idler.r+cl, idler.h)
idler_cut=Cylinder(idler.screw_r, idler.h+20)+Cylinder(idler.r+cl, idler.h)


# standoffs
part+=pulley_1_pos*Cylinder(idler.screw_r+0.5, idler.h/2+2, align=(Align.CENTER, Align.CENTER, Align.MAX))
part+=pulley_2_pos*Cylinder(idler.screw_r+0.5, idler.h+4)

# cutoffs
part-=pulley_1_pos*idler_cut
part-=pulley_2_pos*idler_cut_through
part-=pulley_2_pos*Pos(0,0,idler.h/2+cl+t)*Cylinder(idler.screw_head_r, large, align=(Align.CENTER, Align.CENTER, Align.MIN))

idler_shape=make_pulley(idler)

#show(part, Pos(0, -cable_offset_from_glass_edge + idler.rr, top_axis_h)*Rot(0,90,0)*idler_shape, Pos(-idler.rr, -cable_offset_from_glass_edge, in_cable_h_over_glass+idler.rr)*Rot(90,0,0)*idler_shape)


# Rotate the right face down
part_transform=rotate_from_to((0, dir_y, dir_z), (0,0,-1))*Pos(0, -skyz_pts[0][0], -skyz_pts[0][1])

part_rotated=part_transform*part

part_rotated.export_stl("glass_edge_pulleys_holder.stl")

show(part_rotated)

#show(part, pulley_2_pos*idler_shape, pulley_1_pos*idler_shape, colors=[None, 'red', 'red'])