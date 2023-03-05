import cadquery as cq
from cq_vscode import show, show_object, set_port
import math
import numpy as np

set_port(3939)

def winch_path(phi_to_cable, max_cable, start_phi, d_phi, d_out, spacing, anchor_dist, anchor_z):
    #todo: anchor distance compensation

    r0=(phi_to_cable(d_phi)-phi_to_cable(0))/d_phi
    z_per_phi=spacing/(2*math.pi)
    r=0#r0
    phi=start_phi
    cable=phi_to_cable(start_phi)
    z=0
    result=[]
    d_to_anchor=math.sqrt(anchor_dist**2 +(anchor_z-z)**2)
    phi_since_out=1E10
    while(cable<max_cable):
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

        
        phi=phi+d_phi
        phi_since_out=phi_since_out+d_phi
        if phi_since_out>d_out:
            result.append((math.cos(phi)*r, math.sin(phi)*r, z))
            phi_since_out=0
    if phi_since_out>0:
        result.append((math.cos(phi)*r, math.sin(phi)*r, z))
    return result


x_offset=100
mm_per_revolution=40
mm_per_radian=mm_per_revolution/(2*math.pi)

def test_cable_fun(phi):
    #return phi*mm_per_radian
    return math.sqrt((phi*mm_per_radian)**2 + x_offset**2)


pts=winch_path(test_cable_fun, 400, 2, 0.01, math.pi/10, 1, 100, 0)
wire=cq.Workplane('XY').spline(pts, makeWire=True).val()

helix = cq.Workplane(obj=wire)

groove=np.array([(-1, 1), [1,1], [0,0], [1, -1], [-1, -1]])*0.5

result = (
    cq.Workplane('XZ')
    .center(pts[0][0], pts[0][2])
    .polyline(groove).close()
    .sweep(helix, isFrenet=True)
)

show(helix, result, colors=['red', 'blue'])
#show(helix)