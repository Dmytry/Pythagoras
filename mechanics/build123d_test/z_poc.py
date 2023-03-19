from build123d import *
#from alg123d import *

from cq_vscode import show, show_object, set_port
import math
import marionette_dims as dims

set_port(3939)

ccb=(Align.CENTER, Align.CENTER, Align.MIN)

with BuildPart(Location((0,30,0))) as pulley_block:
    screw_standoff=3
    pulley_standoff=0.5
    cbd=2
    h1=dims.rail_mount_screw_l - dims.rail_depth+2
    h=h1+cbd
    y=screw_standoff+dims.idler_rr-dims.idler_h/2

    with BuildSketch():
            Rectangle(dims.rail_size*3, dims.rail_size+y, align=(Align.MIN, Align.MIN))
    Extrude(amount=h)

    #Box(dims.rail_size*3, dims.rail_size, h, align=ccb)   
    
    #Fillet(*pulley_block.edges(Select.LAST).filter_by(Axis.Z), radius=2) 
    with Locations((dims.rail_size*3/2, dims.rail_size/2)):
        with Locations((dims.rail_size, dims.rail_size/2+screw_standoff+pulley_standoff)):
            Cylinder(radius=dims.idler_r, height=h, align=ccb)
            Fillet(*pulley_block.edges(Select.LAST).filter_by(Axis.Z), radius=2)
            Hole(radius=dims.idler_screw_r)

        
        with Locations(Location((-10, y+dims.rail_size/2, h-dims.idler_rr), (90,0,0))):
            Cylinder(4, 10, align=ccb)
            #Cylinder(dims.idler_ir+0.5, pulley_standoff, align=ccb)
            #Fillet(*pulley_block.edges(Select.LAST).filter_by(Axis.Y), radius=2)
            Hole(radius=dims.idler_screw_r)

        with Locations((dims.rail_size,0,h),(-20,0,h)):
            CounterBoreHole(radius=dims.rail_mount_screw_r, counter_bore_radius=dims.rail_mount_screw_head_r, depth=h, counter_bore_depth=cbd)



show(pulley_block)
#show(test)