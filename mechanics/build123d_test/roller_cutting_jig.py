#from alg123d import *
from build123d import *
from cq_vscode import show

large = 1000


rail_size = 20

screw_r = 3.8 / 2

bearing_or = 7 / 2
bearing_ir = 3 / 2
bearing_h = 3

roller_screw_r = bearing_ir

# Default thickness of things
t = 3
# Default clearance
cl = 1

# expansion for better fit
loose = 0.2

margin = 2
roller_or = bearing_or + t
side_t = roller_or + bearing_ir + margin + cl
roller_h = rail_size + side_t

x = rail_size / 2 + cl + roller_or
h = rail_size * 2
z = h - margin - screw_r


def make_cutter_jig():
    sketch1 = Rectangle(rail_size + 2 * side_t, rail_size + 2 * side_t)
    sketch1 -= Rectangle(rail_size + loose, rail_size + loose)

    box = extrude(sketch1, amount=rail_size * 2)

    roller = Cylinder(roller_or + cl * 2, roller_h + cl * 2)
    # Little pips to keep roller from rubbing on the sides
    roller -= Pos(0, 0, roller_h / 2 + cl) * Cylinder(roller_screw_r + 1, 1)
    roller -= Pos(0, 0, -(roller_h / 2 + cl)) * Cylinder(roller_screw_r + 1, 1)
    roller += Cylinder(roller_screw_r, large)

    box -= Pos(x, 0, z) * Rot(90, 0, 0) * roller
    box -= Pos(-x, 0, z) * Rot(90, 0, 0) * roller

    box -= Pos(0, 0, h / 2) * Rot(0, 90, 0) * Cylinder(screw_r, large)
    box -= Pos(0, 0, h / 2) * Rot(90, 0, 0) * Cylinder(screw_r, large)

    return box


def complete_profile(pts, h, eps=1e-6):
    for i in range(len(pts) - 1, -1, -1):
        # Avoid duplicating midpoint if it's too close to half h
        if pts[i][1] * 2 + eps < h:
            pts.append((pts[i][0], h - pts[i][1]))


def make_cutter_jig_roller():
    # A little looser fit than usual
    inner_r = bearing_or + 0.2
    outer_r = roller_or

    k = 0.5
    bore_r = 2
    pts = [
        (bore_r, bearing_h),
        (inner_r, bearing_h),
        (inner_r, k),
        (inner_r + k, 0),
        (outer_r, 0),
    ]
    complete_profile(pts, roller_h)
    s = Polyline(*pts, close=True)
    return revolve(Plane.XZ * make_face(s), axis=Axis.Z)


cutter_jig = make_cutter_jig()
roller = make_cutter_jig_roller()
cutter_jig.export_stl("cutter_jig.stl")
roller.export_stl("cutter_jig_roller.stl")

if __name__ == "__main__":
    show(
        cutter_jig,
        Pos(x, 0, z) * Rot(90, 0, 0) * Pos(0, 0, -roller_h / 2) * roller,
        Pos(-x, 0, z) * Rot(90, 0, 0) * Pos(0, 0, -roller_h / 2) * roller,
    )

combined = (
    cutter_jig
    + Pos(x, 0, z) * Rot(90, 0, 0) * Pos(0, 0, -roller_h / 2) * roller
    + Pos(-x, 0, z) * Rot(90, 0, 0) * Pos(0, 0, -roller_h / 2) * roller
)

# combined.export_svg('cutter_jig2.svg',
#             (-100, -100, 50),
#             (0, 0, 1),
#             svg_opts={
#                 "pixel_scale": 20,
#                 "show_axes": False,
#                 "show_hidden": True,
#             }
#         )
