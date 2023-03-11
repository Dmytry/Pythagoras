from build123d import *
from cq_vscode import show, show_object, set_port
import winch_generator
# Must use jnp to define cable functionsijl
import jax.numpy as jnp
import math
import marionette_dims as dims

set_port(3939)

cable_spacing=1
mm_per_revolution_winch=80
min_vert_distance=50
max_vert_distance=200
winch_turns=math.ceil((max_vert_distance-min_vert_distance)/mm_per_revolution_winch)+2
# How many mm does the platform move per radian of rotation of the winch
# Also the radius of plain winch
mm_per_radian=mm_per_revolution_winch/(2*jnp.pi)
pulley_to_pulley=200

def angle_to_cable(phi):    
    return jnp.sqrt((phi*mm_per_radian+min_vert_distance)**2 + (pulley_to_pulley/2)**2)


ccb=(Align.CENTER, Align.CENTER, Align.MIN)


with BuildPart() as winch:  
    winch_shape, bottom_r, top_r, height = winch_generator.generate_winch(angle_to_cable, winch_turns, cable_spacing)
    w=Add(winch_shape)
    tf=w.faces().sort_by(Axis.Z)[-1]
    z=tf.center(CenterOf.MASS).Z
    print(tf.center(CenterOf.MASS))

    with BuildPart(Plane.YX):
        Cylinder(radius=bottom_r, height=5, align=ccb)

    with Locations((0,0,height-cable_spacing/2)):
        Cylinder(radius=mm_per_radian, height=winch_turns*2, align=ccb)
    Hole(radius=dims.steel_shaft_r)

show(winch)
#show(test)