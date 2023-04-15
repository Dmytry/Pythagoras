from build123d import *
import build123d
import math
from cq_vscode import show

l=13
hole_r=1
hole_h=8
t=2
h=hole_h+hole_r+t

hole_spacing=6.5

base_w=6
base_hole_r=1.5


b=Box(l, t, h, align=(Align.CENTER, Align.MIN, Align.MIN))

b+=Box(l, t+base_w, t, align=(Align.CENTER, Align.MIN, Align.MIN))

b-=Pos(-hole_spacing/2, 0, hole_h)*Rot(90,0,0)*Cylinder(hole_r, 100)
b-=Pos(hole_spacing/2, 0, hole_h)*Rot(90,0,0)*Cylinder(hole_r, 100)

b-=Pos(-hole_spacing/2, t+base_w/2)*Cylinder(base_hole_r, 100)
b-=Pos(hole_spacing/2, t+base_w/2)*Cylinder(base_hole_r, 100)

b=Rot(0,90,0)*b


belt_w=6
belt_clamp=Box(belt_w+1+4*hole_r+4, 10, 5, align=(Align.CENTER, Align.CENTER, Align.MIN))
belt_clamp-=Pos(belt_w/2+0.5+hole_r)*Cylinder(1.5, 100)
belt_clamp-=Pos(-(belt_w/2+0.5+hole_r))*Cylinder(1.5, 100)

show(b, Pos(30,0,0)*belt_clamp)

b.export_stl("microswitch_holder.stl")

belt_clamp.export_stl("belt_clamp.stl")