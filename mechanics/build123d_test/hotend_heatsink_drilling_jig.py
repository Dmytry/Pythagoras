from build123d import *

from cq_vscode import show

import marionette_dims as dims

large=1000
# assumes m3 bolts
heatsink_r=25/2
margin=2
hole_circle_r=9

m3_tap_hole_r=2.5/2

def vh_expand(r):
    return r+0.2

t=3
h=15
drill_bit_align_h=10

n_holes=4

ccb=(Align.CENTER, Align.CENTER, Align.MIN)

c=Cylinder(radius=heatsink_r+t, height=h, align=ccb)
c-=Pos(0,0,drill_bit_align_h)*Cylinder(radius=vh_expand(heatsink_r), height=h, align=ccb)
c-=Cylinder(radius=6, height=large)
for i in range(0,n_holes):
    c-=Rot(0,0,i*360/n_holes)*Pos(hole_circle_r)*Cylinder(radius=vh_expand(m3_tap_hole_r), height=large)


c.export_stl("heatsink_tapping_jig.stl")

show(c)