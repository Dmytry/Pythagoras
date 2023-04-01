from build123d import *

from cq_vscode import show, show_object, set_port
import math
import marionette_dims as dims


def mx(a):
    return a+mirror(a, about=Plane.YZ)

def my(a):
    return a+mirror(a, about=Plane.XZ)

def mxy(a):
    return mx(my(a))

pulley_hole_r=9

ccb=(Align.CENTER, Align.CENTER, Align.MIN)

motor_w=42

motor_screw_l=20
large=1000

belt_cut_w=8

belt_cut_h=2+dims.motor_bump_h

cut_dir_1=90
cut_dir_2=0

idler_r=10
idler_ir=2.5
idler_holder_t=4

idler_h=10

def rect(p1, p2):
    return Pos(*p1)*Rectangle(p2[0]-p1[0], p2[1]-p1[1], align=(Align.MIN, Align.MIN))


def counterbored(r_bolt, r_bolt_head):
    return Cylinder(radius=r_bolt, height=large) + Cylinder(
        radius=r_bolt_head, height=large, align=(Align.CENTER, Align.CENTER, Align.MIN)
    )

s=Rectangle(motor_w, motor_w, 2)#RectangleRounded(motor_w, motor_w, 2)
s+=rect((0, -motor_w/2), (motor_w/2+dims.rail_size, -dims.rail_size/2))

s=fillet(*s.vertices(), target=s, radius=1)

motor_hole_pos=Pos(dims.motor_hole_gap/2, dims.motor_hole_gap/2)

s-=mxy(motor_hole_pos*Circle(dims.motor_screw_r))

s-=Circle(dims.motor_bump_r+0.2)

show(s)

mb=extrude(s, amount=dims.rail_size, dir=(0,0,1))

mb-=mxy(motor_hole_pos*Pos(0,0,motor_screw_l - dims.motor_hole_depth)*Cylinder(dims.motor_screw_head_r, large, align=ccb))

rail_bolt_hole=Pos(0,0,dims.rail_mount_screw_l-dims.rail_depth)*counterbored(dims.rail_mount_screw_r, dims.rail_mount_screw_head_h)

bottom_face=Pos(motor_w/2,0,dims.rail_size/2)*Rot(0,-90,0)

mb-=bottom_face*rail_bolt_hole

cut_rect=Rectangle(pulley_hole_r*2, large, align=(Align.CENTER, Align.MIN))

s_belt=Rot(0,0,cut_dir_1)*cut_rect+Rot(0,0,cut_dir_2)*cut_rect + Circle(pulley_hole_r)

belt_cut=extrude(s_belt, amount=belt_cut_w, dir=(0,0,1))

mb-=Pos(0,0,belt_cut_h)*belt_cut

mb-=Pos(motor_w/2+dims.rail_size/2, -dims.rail_size/2, dims.rail_size/2)*Rot(90,0,0)*rail_bolt_hole


show_object(mb, 'Motor mount')

mb.export_stl('z_motor_mount_left.stl')
#mirror(mb, about=Plane.XZ).export_stl('z_motor_mount_right.stl')

# Idler mount

screw_h=dims.rail_mount_screw_l-dims.rail_depth + dims.rail_mount_screw_head_h

idler_sk=Rectangle(dims.rail_size, screw_h+idler_r+idler_ir+idler_holder_t, align=(Align.CENTER, Align.MIN))
idler_sk-=rect((-idler_h/2, screw_h), (idler_h/2, large))

idler_sk=fillet(*idler_sk.vertices(), target=idler_sk, radius=1)

idler=extrude(idler_sk, amount=dims.rail_size, dir=(0,0,1))

idler-=Pos(0, screw_h+idler_r, dims.rail_size/2)*Rot(0,90,0)*Cylinder(4.8/2, large)

idler-=Pos(0, 0, dims.rail_size/2)*Rot(-90,0,0)*rail_bolt_hole

show_object(Pos(50)*idler, 'Idler holder')

idler.export_stl('belt_idler_holder.stl')

