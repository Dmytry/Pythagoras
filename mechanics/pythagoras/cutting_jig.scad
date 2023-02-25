// (C) 2023 Dmytry Lavrov.
// note: don't use
use <../common/common.scad>

$fa=3;
$fs=0.2;

blade_w=40;
blade_hole=36;
blade_t=0.3;
blade_h=10;

lengths=[200, 107.939, 100, 98.7, 96];
extras=["x2", "x8", "x1", "x4", "x1"];
max_len=max(lengths);

t=2;
wide_t=4;

large=max_len*10;
r=2;


difference(){
    step_w=blade_hole/(len(lengths)+1);
    union(){
        box([-wide_t, -blade_w/2-t, 0], [wide_t, blade_w/2+t, t+blade_h]);
        box([0, -blade_w/2-t, 0], [max_len+t, blade_w/2+t, t+r]);        
        
        for(i=[1:len(lengths)]){
            y=-blade_hole/2 + i*step_w;
            x=lengths[i-1];
            box([x, y-step_w/2, 0], [x+t, y+step_w/2, t+2*r]);
        }
    }
    box([-wide_t-1, -blade_hole/2, t], [wide_t+1, blade_hole/2, blade_h]);
    box([-blade_t/2, -blade_w/2, t-0.2], [blade_t/2, blade_w/2, t+blade_h+1]); 
 
    for(i=[1:len(lengths)]){
        y=-blade_hole/2 + i*step_w;
        l=lengths[i-1];
        translate([lengths[i-1], y, t+r]){
            rotate([0,-90,0])cylinder(large, r=r);
            translate([t,0,-0.5])linear_extrude(10)text(str(l, extras[i-1]), valign="center", size=5);
        }
    }
    
    // special text for the longest one
    y=-blade_hole/2;
    l=lengths[0];
    translate([l, y, t+r]){        
        translate([0,0,-0.5])linear_extrude(10)text(str(lengths[0], extras[0]), valign="center", halign="right", size=5);
    }
}
