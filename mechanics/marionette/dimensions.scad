// (C) 2023 Dmytry Lavrov.
// Common dimensions for Marionette configuration

glass_w=316;
glass_h=316;
glass_t=3.9;

// margin around glass edge that will be unreachable
movement_margin=30;

mm_per_revolution=40;
winch_r=mm_per_revolution/(2*PI);

winch_clearance=4;

winch_offset=winch_r/sqrt(2) + winch_clearance;

upper_winch_r=winch_r;

winch_ratio=1.5;

lower_winch_r=winch_r/winch_ratio;

motor_hole_gap=31;
motor_hole_r=1.65;
motor_screw_head_r=3.5;
motor_screw_l=16;

motor_hole_depth=3.5;

motor_margin=3;
motor_w=42+2*motor_margin;

motor_bump_r=11.5;
motor_bump_h=2;

motor_shaft_l=22;

motor_shaft_r=2.5;
d_cutout_l=15;
d_cutout_depth=0.5;

cable_r=1.0;//0.5;

// too short:
//winch_l=40;//motor_shaft_l;
winch_l=50;//75;

plate_t=motor_screw_l-motor_hole_depth;



cable_tension=30;

he_bearing_or=11/2;
he_bearing_h=4;
he_bearing_ir=2;

tiny_bearing_or=7/2;
tiny_bearing_ir=3/2;
tiny_bearing_h=3;

steel_shaft_r=2;

idler_screw_r=3.8/2;
idler_screw_head_r=7.5/2;
idler_r=7;
idler_h=6;
idler_ir=2;
// radius where rope wraps
idler_rr=4.75;


diagonal_length=norm([glass_w-movement_margin*2, glass_h-movement_margin*2]);
winch_turns=diagonal_length/mm_per_revolution;
upper_cable_length=norm([glass_w-movement_margin, glass_h-movement_margin])+5*upper_winch_r+50;

echo("The winch will have", winch_turns, "turns");

echo("Upper cable length is", upper_cable_length);

module motor_shaft(expand=0){
    difference(){
        up(-2)cylinder(motor_shaft_l+4, r=motor_shaft_r+expand);
        box([-motor_shaft_r, motor_shaft_r+expand-d_cutout_depth, motor_shaft_l-d_cutout_l], [motor_shaft_r, motor_shaft_r+1, motor_shaft_l+1]);
    }
}
