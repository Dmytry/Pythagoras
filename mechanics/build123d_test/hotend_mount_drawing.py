from build123d import *
import build123d
import math
from utils123d import *

from cq_vscode import show

def m(x):
    return x+mirror(x, about=Plane.YZ)

def r(x):
    return x+Rot(0,0,120)*x+Rot(0,0,-120)*x


r1=10.0
r2=10.0
h=10.0
cr=0.25

a=60*math.pi/180

obj=cylinder_between(Vector(0.0, r2, h), Vector(math.sin(a)*r1, math.cos(a)*r1, 0.0), cr)
obj=r(m(obj))

ring=Cylinder(r1+1, 1)-Cylinder(r1-1, 10)

obj+=ring

obj+=Pos(0,0,h)*ring

show(obj)