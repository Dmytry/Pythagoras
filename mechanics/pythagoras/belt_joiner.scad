// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;

belt_w=6.3;
belt_h=2.6;
t=1.5;
l=20;
s=0.75;
x=belt_w/2 + t;
y=belt_h/2 + t;
module v_mirror(h=arm_h){
    children();
    up(h)mirror([0,0,1])children();
}
difference(){
    box([-x,-y,0], [x, y, l]);    
    box([-belt_w/2, -belt_h/2, -1], [belt_w/2, belt_h/2, l+1]);    
    v_mirror(l){
        hull(){
            box([-belt_w/2-s, -belt_h/2-s, -1], [belt_w/2+s, belt_h/2+s, 0]);
            box([-belt_w/2, -belt_h/2, 0], [belt_w/2, belt_h/2, s*3]);
        }
    }
}