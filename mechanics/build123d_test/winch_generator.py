from build123d import *

import math
import numpy as np
import matplotlib.pyplot as plt

import jax
from jax import grad
import jax.numpy as jnp
from jax import jit

x_offset=100
mm_per_revolution=40
mm_per_radian=mm_per_revolution/(2*math.pi)

def test_cable_fun(phi):
    #return phi*mm_per_radian
    phi=phi+jnp.pi
    return jnp.sqrt((phi*mm_per_radian)**2 + x_offset**2)

# Numerical: bad
def diff(fn, a, d=1E-7):
    return (fn(a+d)-fn(a))/d

def diff2(fn, x, d=1E-3):
    a=fn(x)
    b=fn(x+d)
    c=fn(x+2*d)
    return (b-a)/d, (a+c-2*b)/(d*d)

# TODO: proper 3d version
def gen_spiral_function(a_to_cable):
    g=jit(grad(a_to_cable))
    gg=jit(grad(g))
    def fun(a):
        x=g(a)
        y=gg(a)
        sa=jnp.sin(a)
        ca=jnp.cos(a)
        return ca*x - sa*y, sa*x + ca * y
    return fun

def calculate_spiral(a_to_cable, max_a, a_count):
    g=jit(grad(a_to_cable))
    gg=jit(grad(g))
    result=[]
    x=None  
    da=max_a/a_count
    for i in range(0, a_count+1):
        a=i*max_a/a_count
        dc_per_da=g(a)
        ddc_per_da2=gg(a)
        sa=jnp.sin(a)
        ca=jnp.cos(a)
        y=ddc_per_da2
        #x=dc_per_da if x is None else x+y*da
        x=dc_per_da
        #result.append( (ca*dc_per_da - sa*ddc_per_da2, sa*dc_per_da + ca * ddc_per_da2) )
        result.append( (ca*x - sa*y, sa*x + ca * y) )

    return result

def validate_spiral(spiral, a_to_cable, max_a):
    cable_sum=0
    summed=[]
    actual=[]
    angle_dev=[]
    old_tangent=0
    turns_added=0
    for i in range(1, len(spiral)):
        a=i*max_a/(len(spiral)-1)
        p=spiral[i-1]
        p2=spiral[i]
        d=(p2[0]-p[0], p2[1]-p[1])
        dist=math.sqrt(d[0]**2 + d[1]**2)
        cable_sum+=dist
        tangent_angle=math.atan2(-d[0], d[1])
        if old_tangent-tangent_angle > math.pi:
            turns_added+=1
        elif old_tangent-tangent_angle < -math.pi:
            turns_added-=1
        old_tangent=tangent_angle
        tangent_angle+=turns_added*math.pi*2

        angle_dev.append(tangent_angle-a)

        computed_cable_length = cable_sum - (p[0]*d[0]/dist + p[1]*d[1]/dist)
        desired_cable_length = a_to_cable(a)
        # Integration constant
        if i==1:
            cable_sum+=desired_cable_length-computed_cable_length
            computed_cable_length = cable_sum - (p[0]*d[0]/dist + p[1]*d[1]/dist)        
        summed.append(computed_cable_length)
        actual.append(desired_cable_length)
    return summed, actual, angle_dev


def spiral_test():
    max_a=2*math.pi
    s=calculate_spiral(test_cable_fun, max_a, 1000)
    summed, actual, angle_dev=validate_spiral(s, test_cable_fun, max_a)
    fig = plt.figure()
    ax = fig.add_subplot()
    #plt.plot(*zip(*s))
    plt.plot(actual, color='green', linewidth=4)
    plt.plot(summed, color='red')
    #plt.plot(angle_dev, color='blue')

    #ax.set_aspect('equal', adjustable='box')
    plt.grid()
    plt.show()
    #exit(0)

# extremely simple, extremely stupid numerical solver for t position on the curve
class SpiralSolver:
    max_iter=128
    def __init__(self, spiral_fun, default_step=math.pi/6, tol=1E-7):
        self.t=0.0
        self.tol=tol
        self.prev_a=0.0
        self.spiral_fun=spiral_fun
        self.default_step=default_step

    def find_t(self, a):
        s=math.sin(a)
        c=math.cos(a)
        step=self.default_step
        # the function whose square is being minimized
        def o(t):
            pt=self.spiral_fun(t)
            return pt[1]*c-pt[0]*s
        t=self.t
        prev_ot=None
        for i in range(0, SpiralSolver.max_iter):
            ot=o(t)
            err=abs(ot)
            if err<self.tol:
                self.t=t
                return t
            if ot>0 :
                t-=step
            else :
                t+=step

            if prev_ot is not None:
                if (prev_ot>0)!=(ot>0):
                    step/=2
                else:# two steps in the same direction, raise step
                    step=min(step*1.2, self.default_step)
            prev_ot=ot
            if step<self.tol:
                self.t=t
                return t
        self.t=t
        return t

def winch_path(spiral_fun, max_a, a_count, spacing, expand_r, z_offset):
    solver=SpiralSolver(spiral_fun)

    da=max_a/a_count
    #dspiral=jit(jax.jacfwd(spiral_fun))
    pt0=spiral_fun(0.0)
    
    z_per_a=spacing/(2*math.pi)   

    t_offset=solver.find_t(0) 
    zstart=-t_offset*z_per_a

    result=[]
    tangents=[]

    def point_calc(t):
        #fade=jnp.min(jnp.array(((t-t_offset)/jnp.pi, 1.0)))
        # no longer do fades
        fade=1
        #z=a*z_per_a
        z=t*z_per_a+zstart
        pt=spiral_fun(t)
        #dpt=dspiral(t)
        x=jnp.cos(t)
        y=jnp.sin(t)
        return (pt[0]+x*expand_r*fade, pt[1]+y*expand_r*fade, z+z_offset*fade)
    
    point_tangent=jit(jax.jacfwd(point_calc))

    for i in range(0, a_count+1):
        a=i*da
        t=solver.find_t(a)
        point=point_calc(t)
        pt=point_tangent(t)
        result.append(point)
        tangents.append(Vector(*pt).normalized())

    return result, tangents

def ridge_fadeout(start_r, start_z, end_r, end_z, max_phi, count, start_i=1):
    last_point=(start_r, 0, start_z)
    decimate_cnt=0
    result=[]
    tangents=[]
    def a_to_pt(a):
        phi=max_phi*a
        z=start_z+(end_z-start_z)*a
        r=start_r+(end_r-start_r)*a
        return (jnp.cos(phi)*r, jnp.sin(phi)*r, z)
    
    a_to_dpt=jit(jax.jacfwd(a_to_pt))
    #pt_dpt=jit(jax.value_and_grad(a_to_pt))

    for i in range(start_i, count+start_i):
        a=i/count
        new_pt=a_to_pt(a)
        dp=a_to_dpt(a)
        result.append(new_pt)
        tangents.append(Vector(*dp).normalized())

    return result, tangents


def generate_winch(f, rotations, cable_spacing=1, points_per_spline=16, splines_per_rotation=1):
    max_phi=rotations*2*math.pi
    spiral_function=gen_spiral_function(f)

    points_per_rotation=points_per_spline*splines_per_rotation
    pts, tangents=winch_path(spiral_function, max_phi, points_per_rotation*rotations, cable_spacing, 0, 0)
    ridge_pts, ridge_tangents=winch_path(spiral_function, max_phi, points_per_rotation*rotations, cable_spacing, cable_spacing/2, -cable_spacing/2)
    # fix up so everything fuses perfectly
    pts[0]=(pts[0][0], 0, 0)
    pts[-1]=(pts[-1][0], 0, pts[-1][2])

    bottom_circle_r=pts[0][0]

    bottom_circle_z=ridge_pts[0][2]

    top_circle_pt=pts[-1]
    top_circle_r=top_circle_pt[0]

    ridge_fade_pts, ridge_fade_tangents=ridge_fadeout(ridge_pts[-1][0], ridge_pts[-1][2], top_circle_r, pts[-1][2], 2*math.pi, points_per_rotation)

    ridge_pts=ridge_pts+ridge_fade_pts
    ridge_tangents=ridge_tangents+ridge_fade_tangents

    #ridge_pts[0]=pts[0]

    bottom_fade_pts, bottom_fade_tangents=ridge_fadeout(bottom_circle_r, bottom_circle_z, pts[0][0], pts[0][2], 2*math.pi, points_per_rotation, 0)

    bottom_ridge_fade_pts, bottom_ridge_fade_tangents=ridge_fadeout(bottom_circle_r, bottom_circle_z, ridge_pts[0][0], ridge_pts[0][2], 2*math.pi, points_per_rotation, 0)

    pts=bottom_fade_pts+pts
    tangents=bottom_fade_tangents+tangents
    ridge_pts=bottom_ridge_fade_pts+ridge_pts
    ridge_tangents=bottom_ridge_fade_tangents+ridge_tangents

    n=points_per_spline

    base_circle=[Edge.make_circle(bottom_circle_r, plane=Plane.XY.offset(ridge_pts[0][2]), start_angle=i*360/splines_per_rotation, end_angle=(i+1)*360/splines_per_rotation) for i in range(0, splines_per_rotation)]
    
    top_circle=[Edge.make_circle(top_circle_r, plane=Plane.XY.offset(top_circle_pt[2]), start_angle=i*360/splines_per_rotation, end_angle=(i+1)*360/splines_per_rotation) for i in range(0, splines_per_rotation)]

    edges_groove=[Edge.make_spline(pts[i-1:i+n], tangents=tangents[i-1:i+n]) for i in range(1, len(pts), n)]
    edges_ridge=[Edge.make_spline(ridge_pts[i-1:i+n], tangents=ridge_tangents[i-1:i+n]) for i in range(1, len(ridge_pts), n)]
    faces_up=[Face.make_surface_from_curves(edges_groove[i], edges_ridge[i+splines_per_rotation]) for i in range(0, len(edges_ridge)-splines_per_rotation) ]
    faces_down=[Face.make_surface_from_curves(edges_ridge[i], edges_groove[i]) for i in range(0, len(edges_groove)) ]
    faces_bottom_fade=[Face.make_surface_from_curves(base_circle[i], edges_ridge[i]) for i in range(0, splines_per_rotation)]
    faces_top_fade=[Face.make_surface_from_curves(edges_ridge[i+len(edges_ridge)-splines_per_rotation], top_circle[i]) for i in range(0, splines_per_rotation)]

    #e1=faces_down[0].edges()[3]
    
    #bottom_triangle_cap=[faces_down[0].edges()[3], faces_bottom_fade[0].edges()[3], Edge.make_line() ]

    bottom_flat_cap=Face.make_surface(base_circle)
    top_flat_cap=Face.make_surface(top_circle)

    result_shell=Shell.make_shell(faces_up+faces_down+faces_top_fade+faces_bottom_fade+[bottom_flat_cap, top_flat_cap])
    result_solid=Solid.make_solid(result_shell)

    if result_solid.wrapped.IsNull():
        print(f'Got null solid')
    valid=result_solid.is_valid()
    print(f'Generated winch solid is valid: {valid}')

    if __name__ == '__main__':
        from cq_vscode import show
        show(faces_up, faces_down, faces_bottom_fade, bottom_flat_cap, top_flat_cap, faces_top_fade, colors=['red', 'green', 'blue', 'yellow', 'yellow', 'blue'])
        valid=result_solid.is_valid()
        print(f'Solid is valid: {valid}')

    return result_solid, bottom_circle_r, top_circle_r, top_circle_pt[2]

if __name__ == '__main__':
    generate_winch(test_cable_fun, 5)