#from alg123d import *
from build123d import *
from cq_vscode import show, show_object

bearing_or=16/2
bearing_ir=5/2
bearing_h=5

large=80

# Default thickness of things
t = 3
# Default clearance
cl = 0.5

# expansion for better fit
loose = 0.2

bearing_hole=Cylinder(radius=bearing_or+cl, height=bearing_h+cl*2)
bearing_hole+=Cylinder(radius=bearing_ir, height=large)
bearing_hole+=Box((bearing_or+cl)*2, large, bearing_h+cl*2, align=(Align.CENTER, Align.MIN, Align.CENTER))


#show_object(bearing_hole, name="bearing_hole")

def make_bending_tool():
    l=60
    w=15
    t=5
    hole_spacing=13
    s=RectangleRounded(l, w, radius=13/2, align=(Align.MIN, Align.CENTER))    
    s-=Pos(w/2)*Circle(2)
    s-=Pos(w/2+hole_spacing)*Circle(2)
    return extrude(s, amount=t)

bt=make_bending_tool()
bt.export_stl("bending_tool.stl")

show(bt)