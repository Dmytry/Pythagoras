from build123d import *
import build123d

from cq_vscode import show, show_object, set_port
import winch_generator
# Must use jnp to define cable functionsijl
import jax
import jax.numpy as jnp
import math
import marionette_dims as dims

set_port(3939)

cable_spacing=2
mm_per_revolution_winch=100
min_vert_distance=50
max_vert_distance=450
winch_turns=math.ceil((max_vert_distance-min_vert_distance)/mm_per_revolution_winch)+2
# How many mm does the platform move per radian of rotation of the winch
# Also the radius of plain winch
mm_per_radian=mm_per_revolution_winch/(2*jnp.pi)
pulley_to_pulley=405

large=1000

def angle_to_cable(phi):    
    return jnp.sqrt((phi*mm_per_radian+min_vert_distance)**2 + (pulley_to_pulley/2)**2)

d_at_0=jax.grad(angle_to_cable)(0.0)

def expanded_angle_to_cable(phi):
    return jnp.where(phi>2*jnp.pi, angle_to_cable(phi-2*jnp.pi), (phi-2*jnp.pi)*d_at_0)

ccb=(Align.CENTER, Align.CENTER, Align.MIN)

def accumulate_y(pts):
    pts_out=[]
    y=0
    for p in pts:
        y+=p[1]
        pts_out.append((p[0], y))
    return pts_out



class MagicWinch():
    def __init__(self):

        self.align_pin_offset=10
        self.align_pin_r=1
  
        winch_shape, bottom_r, top_r, height = winch_generator.generate_winch(angle_to_cable, winch_turns, cable_spacing)

        height=winch_turns*cable_spacing
        bottom_shoulder=3
        anchor_w=5
        anchor_h=1
        top_winch=6
        top_shoulder=3

        cl=0.5        

        #show_object(winch_shape)

        with BuildPart() as bp:
            Add(winch_shape)

        result=Pos(0, 0, bottom_shoulder) * bp.part

        # Slight expand for the 3D printer
        ir=dims.steel_shaft_r+0.15

        anchor_screw_r=dims.rope_and_screw_hole_r

        pts=accumulate_y([
            (ir, -cl),
            (ir+1, 0),
            (ir+1, cl),
            (bottom_r+bottom_shoulder, 0),
            (bottom_r, bottom_shoulder),
            (bottom_r, height-0.75*cable_spacing),
            (top_r+anchor_h, 0.5),
            (top_r+anchor_h, anchor_w),
            (top_r, anchor_h),
            (top_r, top_winch),
            (top_r+top_shoulder, top_shoulder),        
            (ir, 0)
            ])
        mid_anchor_h=(pts[6][1]+pts[7][1])/2
        s=Polyline(*pts, close=True)
        face=Plane.XZ * make_face(s)
        revolved_face=revolve(face, axis=Axis.Z)
        result+=revolved_face
        
        result-=Cylinder(radius=ir, height=large)
        
        # Hole for tie-off screw
        result-=Pos(0,0,mid_anchor_h) * Rot(0,90,0) * Cylinder(radius=0.8, height=1000)
        result-=Pos(0,0,mid_anchor_h) * Rot(90,0,0) * Cylinder(radius=0.8, height=1000)

        result-=Pos(self.align_pin_offset, 0, mid_anchor_h) * Cylinder(radius=self.align_pin_r, height=large, align=ccb)


        #result.fix()

        self.object=result
        self.height=pts[-1][1]
        self.radius=max(pts[-2][0], top_r+anchor_h+3)
        print(f'Top r:{self.radius} Total height: {self.height}')

winch=MagicWinch()
(Pos(0,0,winch.height)*Rot(180,0,0) * winch.object).export_stl(f"magic_winch_{pulley_to_pulley}.stl")

# TODO: hole for alignment pin
def winch_holder(r, h):

    
    cl=0.5
    t=dims.he_bearing_h
    bearing_holder_r=dims.he_bearing_or+4

    w=2*r+4*dims.rail_mount_screw_head_r+4

    total_h=h+2*(t+cl)    

    y = dims.rail_mount_screw_l + dims.rail_mount_screw_head_h + 2 - dims.rail_depth

    standoff=r+2

    base_rect = Rectangle(w, y, align=(Align.CENTER, Align.MIN))

    s = base_rect+Rectangle(2*bearing_holder_r, standoff, align=(Align.CENTER, Align.MIN))
    s += Pos(0, standoff) * Circle(bearing_holder_r)

    #show_object(s)

    bottom_holder = extrude(s, t)

    base_rect_cl=base_rect - Pos(0, standoff) * Circle(r)
    
    #show_object(bottom_holder)

    result = bottom_holder + Pos(0,0,total_h-t) * bottom_holder + extrude(base_rect_cl, total_h, dir=(0,0,1))
    

    result-=Pos(0,standoff) * Cylinder(dims.he_bearing_or, large)

    bolt_hole = Cylinder(radius=dims.rail_mount_screw_r, height=large) + Cylinder(
        radius=dims.rail_mount_screw_head_r,
        height=10000,
        align=(Align.CENTER, Align.CENTER, Align.MIN),
    )

    hole_pos=Pos(r+dims.rail_mount_screw_head_r, dims.rail_mount_screw_l + 2 - dims.rail_depth, total_h/2) * Rot(-90,0,0)

    bh=hole_pos * bolt_hole
    bh+=mirror(bh, about=Plane.YZ)
    bh2=bh+Pos(0,0,-dims.rail_size/2)*bh
    bh2+=Pos(0,0,dims.rail_size/2)*bh
    result-=bh2

    return Pos(0, -standoff, 0) * result
    
wh=winch_holder(float(winch.radius), float(winch.height))

(Rot(90,0,0) * wh).export_stl("magic_winch_holder.stl")

if __name__ == '__main__':
    
    show(Pos(0,0,4.5) * winch.object, wh)