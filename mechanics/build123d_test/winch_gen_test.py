from build123d import *
from cq_vscode import show, show_object, set_port
import winch_generator
# Must use jnp to define cable functionsijl
import jax.numpy as jnp

set_port(3939)

def sine_winch(x):
    return jnp.sin(x/6)*2+x*3

def quadratic_winch(x):    
    x/=(2*jnp.pi)
    x+=1
    return x**2

with BuildPart() as blocks:
    w, _, _, _=winch_generator.generate_winch(winch_generator.test_cable_fun, 20)
    Add(w)
    with Locations((20,0,0)):
        Add(winch_generator.generate_winch(sine_winch, 20)[0])
    with Locations((40,0,0)):
        Add(winch_generator.generate_winch(quadratic_winch, 20)[0])
    
show(blocks)
