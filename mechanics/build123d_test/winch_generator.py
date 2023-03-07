from build123d import *
from cq_vscode import show, show_object, set_port

import math
import numpy as np

set_port(3939)

def winch_path(phi_to_cable, max_cable, start_phi, d_phi, decimate, spacing, anchor_dist, anchor_z, bore, shrink):
    #todo: anchor distance compensation

    
    r0=(phi_to_cable(d_phi+start_phi)-phi_to_cable(start_phi))/d_phi
    
    z_per_phi=spacing/(2*math.pi)
    r=r0
    cable=phi_to_cable(start_phi)
    
    phi=0

    z=phi*z_per_phi

    last_point=(r, 0, z)

    result=[]
    tangents=[]
    r_z=[(bore, z)]
    
    
    #last_out_phi=-1E10
    decimate_cnt=0

    last_out_z_phi=0

    while(cable<max_cable):
        phi=phi+d_phi

        z=phi*z_per_phi
        new_cable=phi_to_cable(phi+start_phi)
        d_cable=new_cable-cable
        cable=new_cable

        cable_taken=r*math.sin(d_phi)
        cable_remaining=d_cable-cable_taken
        if cable_remaining<0 :
            print(f"can not convert to winch accurately at phi={phi}, cable={cable}, d_cable={d_cable}")
            cable_remaining=0
            cable_taken=d_cable
        r=r*math.cos(d_phi)+math.sqrt(d_cable**2 - cable_taken**2)

        new_point=(math.cos(phi)*r, math.sin(phi)*r, z)
        decimate_cnt=decimate_cnt-1
        if decimate_cnt<0:
            result.append(last_point)
            tangents.append((Vector(*new_point)-Vector(*last_point)).normalized())
            decimate_cnt=decimate

        last_point=new_point

        if phi-last_out_z_phi>math.pi and r-shrink > bore:
            r_z.append((r-shrink, z))
            last_out_z_phi=phi

    # if last_out_phi<phi:
    #     result.append((math.cos(phi)*r, math.sin(phi)*r, z))
    # if last_out_z_phi<phi:
    #     r_z.append((r-shrink, z))

    r_z.append((1, z))
    return result, tangents, r_z


x_offset=100
mm_per_revolution=40
mm_per_radian=mm_per_revolution/(2*math.pi)

def test_cable_fun(phi):
    #return phi*mm_per_radian
    return math.sqrt((phi*mm_per_radian)**2 + x_offset**2)


groove_pts=[(-1, 1), (1,1), (0,0), (1, -1), (-1, -1)]

pts, tangents, r_z = winch_path(test_cable_fun, 400, math.pi*2, math.pi/360, 59, 1, 100, 0, 1, 0.1)

n=4
with BuildPart() as blocks:

    with BuildLine() as spiral:
        #s=Spline(pts)
        #s=Spline(pts[:4])
        #s2=Spline(pts[3:8])
        #s=Polyline(*pts[:10])
        #s2=Spline(pts[9:20])
        for i in range(1, len(pts)-1, n):
            ts=Spline(pts[i-1:i+n], tangents=tangents[i-1:i+n])
    # , z_dir=(0,1,0), x_dir=(1,0,0))
    with BuildSketch(Plane(origin=spiral.wires().first @ 0, z_dir=(0,1,0), x_dir=(1,0,0))) as p:
        with BuildLine() as l:
            Polyline(*groove_pts, close=True)
            Scale(by=0.3)
        MakeFace()
    rotated_s=spiral.wires().first.rotate(axis=Axis.Z, angle=90)
    #flat_spiral=rotated_s.project_to_shape(Face.make_rect(1000,1000,Plane.XY), direction=(0,0,1))
    Sweep(binormal=rotated_s)
    #Sweep(is_frenet=True)

    with BuildSketch(Plane.XZ) as filler:
        with BuildLine() as l2:
            Polyline(*r_z, close=True)
        MakeFace()
    rv=Revolve(axis=Axis.Z, mode=Mode.ADD)

show(blocks, spiral, colors=[None, 'red', 'green'])
