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


s=RectangleRounded(motor_w, motor_w, 2)

motor_hole_pos=Pos(dims.motor_hole_gap/2, dims.motor_hole_gap/2)

s-=mxy(motor_hole_pos*Circle(dims.motor_screw_r))

s-=Circle(dims.motor_bump_r)

mb=extrude(s, amount=dims.rail_size, dir=(0,0,1))

mb-=mxy(motor_hole_pos*Pos(0,0,motor_screw_l - dims.motor_hole_depth)*Cylinder(dims.motor_screw_head_r, large, align=ccb))

show(mb)


