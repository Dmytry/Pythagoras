from build123d import *

from cq_vscode import show

import marionette_dims as dims

large=1000

ptfe_r=2
drill_r=1

def vh_expand(r):
    return r+0.2

r=10
h=10

n_holes=4

ccb=(Align.CENTER, Align.CENTER, Align.MIN)

c=Cylinder(radius=r, height=h, align=ccb)
c-=Cylinder(radius=vh_expand(ptfe_r), height=large)
for i in range(0,2):
    c-=Rot(0,0,i*90)*Pos(0,0,h/2)*Rot(90,0,0)*Cylinder(radius=drill_r, height=large)


c.export_stl("bowden_drilling_jig.stl")

show(c)