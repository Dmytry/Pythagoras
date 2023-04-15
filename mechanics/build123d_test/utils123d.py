from build123d import *
from build123d import gp_Quaternion, gp_Trsf, TopTools_ListOfShape, BRepAlgoAPI_Cut
from build123d.topology import Shape

def join_with_fillet(a, b, r=1):
    result = a + b
    # return result
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
    s = Shape.cast(operation.Shape())

    return fillet(*s.edges(), radius=r, target=result)

def rotate_from_to(f, t):
    # if not isinstance(f, Vector):        
    #     f=Vector(f)
    # if not isinstance(t, Vector):
    #     t=Vector(t)
    transform = gp_Trsf()
    q = gp_Quaternion()
    q.SetRotation(Vector(f).wrapped, Vector(t).wrapped)
    transform.SetRotation(q)
    return Location(transform)

def cylinder_between(p0, p1, r):
    d=p1-p0
    return Pos(*p0)*rotate_from_to((0,0,1), d)*Cylinder(r, d.length, align=(Align.CENTER, Align.CENTER, Align.MIN))

if __name__ == '__main__':
    from cq_vscode import show
    a=join_with_fillet(Box(20,5,10), Cylinder(5,10))
    a=join_with_fillet(a, Pos(0,0,5)*Sphere(2))
    a=join_with_fillet(a, Box(2,20,5))
    #a=join_with_fillet(a, Sphere(4)@Pos(10,0,5), 2)
    #a=join_with_fillet(a, Torus(8,0.5), 0.5)
    b=join_with_fillet(Box(10,10,10), Rot(45, 45, 45)*Box(10,10,10), 0.5)
    show(a, Pos(30,0,0)*b)