from build123d import *
from cq_vscode import show, show_object, set_port

import math
import numpy as np

set_port(3939)

def winch_path(phi_to_cable, max_phi, phi_count, decimate, spacing, expand_r, z_offset):
    #todo: anchor distance compensation, twist compensation

    d_phi=max_phi/phi_count

    r0=(phi_to_cable(d_phi)-phi_to_cable(0))/d_phi
    
    z_per_phi=spacing/(2*math.pi)
    r=r0
    cable=phi_to_cable(0)
    
    phi=0

    z=phi*z_per_phi

    last_point=(r, 0, z)

    result=[]
    tangents=[]

    decimate_cnt=0

    for i in range(1, phi_count+2):
        phi=i*max_phi/phi_count
        fade=min(phi/(2*math.pi), 1)
        #fade2=min((max_phi-phi)/(2*math.pi),1)
        #fade=min(fade1, fade2)

        z=phi*z_per_phi
        new_cable=phi_to_cable(phi)
        d_cable=new_cable-cable
        cable=new_cable

        cable_taken=r*math.sin(d_phi)
        cable_remaining=d_cable-cable_taken
        if cable_remaining<0 :
            print(f"can not convert to winch accurately at phi={phi}, cable={cable}, d_cable={d_cable}")
            cable_remaining=0
            cable_taken=d_cable
        r=r*math.cos(d_phi)+math.sqrt(d_cable**2 - cable_taken**2)

        new_point=(math.cos(phi)*(r+expand_r*fade), math.sin(phi)*(r+expand_r*fade), z+z_offset*fade)
        decimate_cnt=decimate_cnt-1
        if decimate_cnt<=0:
            result.append(last_point)
            tangents.append((Vector(*new_point)-Vector(*last_point)).normalized())
            decimate_cnt=decimate

        last_point=new_point

    return result, tangents


def ridge_fadeout(start_r, start_z, end_r, end_z, max_phi, count):
    last_point=(start_r, 0, start_z)
    decimate_cnt=0
    result=[]
    tangents=[]
    def a_to_pt(a):
        phi=max_phi*a
        z=start_z+(end_z-start_z)*a
        r=start_r+(end_r-start_r)*a
        return (math.cos(phi)*r, math.sin(phi)*r, z)
    
    for i in range(1, count+1):
        a=i/count
        new_pt=a_to_pt(a)
        result.append(new_pt)
        tangents.append((Vector(a_to_pt(a+1E-6))-Vector(*new_pt)).normalized())

    return result, tangents
        


x_offset=100
mm_per_revolution=40
mm_per_radian=mm_per_revolution/(2*math.pi)

def test_cable_fun(phi):
    #return phi*mm_per_radian
    phi=phi+math.pi
    return math.sqrt((phi*mm_per_radian)**2 + x_offset**2)


groove_pts=[(-1, 1), (1,1), (0,0), (1, -1), (-1, -1)]


rotations=10

max_phi=rotations*2*math.pi

points_per_spline=4
splines_per_rotation=4

points_per_rotation=points_per_spline*splines_per_rotation

desired_integrator_steps_per_rotation=300
steps_per_point=1+desired_integrator_steps_per_rotation//points_per_rotation

increment=math.pi*2/(steps_per_point*points_per_rotation)
decimate=steps_per_point

spacing=1

cable_length=400

#start_angle=math.pi

pts, tangents = winch_path(test_cable_fun, max_phi, steps_per_point*points_per_rotation*rotations, decimate, spacing, 0, 0)
ridge_pts, ridge_tangents = winch_path(test_cable_fun, max_phi, steps_per_point*points_per_rotation*rotations, decimate, spacing, spacing/2, -spacing/2)
top_circle_pt=pts[-1]

ridge_fade_pts, ridge_fade_tangents=ridge_fadeout(ridge_pts[-1][0], ridge_pts[-1][2], pts[-1][0], pts[-1][2], 2*math.pi, points_per_rotation)

ridge_pts=ridge_pts+ridge_fade_pts
ridge_tangents=ridge_tangents+ridge_fade_tangents

n=points_per_spline

with BuildPart() as blocks:
    base_circle=[Edge.make_circle(pts[0][0], start_angle=i*360/splines_per_rotation, end_angle=(i+1)*360/splines_per_rotation) for i in range(0, splines_per_rotation)]
    top_circle_pt=pts[-1]

    top_circle=[Edge.make_circle(top_circle_pt[0], plane=Plane.XY.offset(top_circle_pt[2]), start_angle=i*360/splines_per_rotation, end_angle=(i+1)*360/splines_per_rotation) for i in range(0, splines_per_rotation)]

    edges_groove=[Edge.make_spline(pts[i-1:i+n], tangents=tangents[i-1:i+n]) for i in range(1, len(pts), n)]
    edges_ridge=[Edge.make_spline(ridge_pts[i-1:i+n], tangents=ridge_tangents[i-1:i+n]) for i in range(1, len(ridge_pts), n)]
        
    faces_up=[Face.make_surface_from_curves(edges_groove[i], edges_ridge[i+splines_per_rotation]) for i in range(0, len(edges_ridge)-splines_per_rotation) ]
    faces_down=[Face.make_surface_from_curves(edges_ridge[i], edges_groove[i]) for i in range(0, len(edges_groove)) ]

    faces_bottom_fade=[Face.make_surface_from_curves(base_circle[i], edges_ridge[i]) for i in range(0, splines_per_rotation)]

    faces_top_fade=[Face.make_surface_from_curves(edges_ridge[i+len(edges_ridge)-splines_per_rotation], top_circle[i]) for i in range(0, splines_per_rotation)]

    bottom_flat_cap=Face.make_surface(base_circle)

    top_flat_cap=Face.make_surface(top_circle)

    #bottom_triangle_cap=Face.make_surface([faces_bottom_fade[-1].edges()[1], faces_up[0].edges()[3], faces_down[0].edges()[3]])

    test_shell=Shell.make_shell(faces_up+faces_down+faces_top_fade+faces_bottom_fade+[bottom_flat_cap, top_flat_cap])
    test_solid=Solid.make_solid(test_shell)
    Add(test_solid)
    Cylinder(2, 50, mode=Mode.ADD)
    Cylinder(1, 100, mode=Mode.SUBTRACT)
    #test_solid.fix()
    print(f'solid is valid: {test_solid.is_valid()}')

    

#show(faces_up, faces_down, faces_bottom_fade, bottom_flat_cap, top_flat_cap, faces_top_fade, colors=['red', 'green', 'blue', 'yellow', 'yellow', 'blue'])
#show(test_solid, colors=['red', 'green', 'blue'])
show(blocks)
