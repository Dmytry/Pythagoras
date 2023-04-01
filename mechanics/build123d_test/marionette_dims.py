# pylint: skip-file
# (C) 2023 Dmytry Lavrov.
# Common dimensions for Marionette configuration, ported from openscad

import math

glass_w=316
glass_h=316
glass_t=3.9

# margin around glass edge that will be unreachable
movement_margin=30

mm_per_revolution=40
winch_r=mm_per_revolution/(2*math.pi)

winch_clearance=4

winch_offset=winch_r/math.sqrt(2) + winch_clearance

upper_winch_r=winch_r

winch_ratio=1.5

lower_winch_r=winch_r/winch_ratio

motor_hole_gap=31
motor_hole_r=1.65
motor_screw_r=1.65
motor_screw_head_r=3.5
motor_screw_l=16

motor_hole_depth=3.5

motor_margin=3
motor_w=42+2*motor_margin

motor_bump_r=11.5
motor_bump_h=2

motor_shaft_l=22

motor_shaft_r=2.5
d_cutout_l=15
d_cutout_depth=0.5

cable_r=0.5

# too short:
#winch_l=40#motor_shaft_l
winch_l=50#75

plate_t=motor_screw_l-motor_hole_depth

cable_tension=30

he_bearing_or=11/2
he_bearing_h=4
he_bearing_ir=2

tiny_bearing_or=7/2
tiny_bearing_ir=3/2
tiny_bearing_h=3

steel_shaft_r=2

# # legacy idler
# idler_screw_r=3.8/2
# idler_screw_head_r=7.5/2
# idler_r=7
# idler_h=6
# idler_ir=2
# # radius where rope wraps
# idler_rr=4.75


class idler:
    screw_r=3.8/2
    screw_head_r=7.5/2
    r=7
    h=6
    ir=2
    # radius where rope wraps
    rr=4.75

class small_idler:
    screw_r=3/2
    screw_head_r=6/2
    r=6
    h=4
    ir=2
    # radius where rope wraps
    rr=9.8/2

diagonal_length=math.hypot(glass_w-movement_margin*2, glass_h-movement_margin*2)
winch_turns=diagonal_length/mm_per_revolution
upper_cable_length=math.hypot(glass_w-movement_margin, glass_h-movement_margin) + 5*upper_winch_r + 50

rail_size=20
rail_mount_screw_r=2
rail_mount_screw_head_r=3.8
rail_mount_screw_head_h=4
# Bought a lot of m4x12 screws again.
rail_mount_screw_l=12
# Ran out of m4x12 screws!
#rail_mount_screw_l=10
rail_depth=6


rope_and_screw_hole_r=0.9

#echo("The winch will have", winch_turns, "turns")
#echo("Upper cable length is", upper_cable_length)
