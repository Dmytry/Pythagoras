from alg123d import *

from cq_vscode import show, show_object, set_port
import math
import marionette_dims as dims

def join_with_fillet(a, b, r=1):
    result=a+b

    arg = TopTools_ListOfShape()
    for obj in result.edges():
        arg.Append(obj.wrapped)

    tool = TopTools_ListOfShape()
    for obj in a.edges():
        tool.Append(obj.wrapped)
    for obj in b.edges():
        tool.Append(obj.wrapped)

    operation = BRepAlgoAPI_Cut()

    operation.SetArguments(arg)
    operation.SetTools(tool)

    operation.SetRunParallel(True)
    operation.Build()
    s=Shape.cast(operation.Shape())

    return fillet(result, s.edges(), r)

a=join_with_fillet(Box(20,5,10), Cylinder(5,10))
a=join_with_fillet(a, Sphere(2)@Pos(0,0,5))
a=join_with_fillet(a, Box(2,20,5))
#a=join_with_fillet(a, Sphere(4)@Pos(10,0,5), 2)
#a=join_with_fillet(a, Torus(8,0.5), 0.5)

b=join_with_fillet(Box(10,10,10), Box(10,10,10)@Rot(45, 45, 45), 0.5)

show(b)