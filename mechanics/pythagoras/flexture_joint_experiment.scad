// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;
print_dilation=0.15;// when printing the shape gets dilated typically by 0.15mm
print_dilation_max=0.3;// max 0.3
tight_fit=0.2;
thickness=1;


q=0.01;

function half_profile(x)=q/(x+q);
function profile_unorm(x)=half_profile(x)+half_profile(1.0-x);
function profile(x)=(profile_unorm(x)-profile_unorm(0.5))/(profile_unorm(0)-profile_unorm(0.5));

module flex(l, w, t, h_=-1){// length, width, thickness
    h=h_>0?h_:w;
    steps=360;
    //translate([0,0,-h/2])
    
    linear_extrude(height=h, convexity=6){
        polygon(points=[
            for (i = [0 : steps]) [i*l/steps, t + profile(i/steps)*w*sqrt(0.5)/2 ],
            for (i = [steps : -1 : 0]) [i*l/steps, -t - profile(i/steps)*w*sqrt(0.5)/2 ]
        ],
            paths=[[
            for(i=[0:steps*2+1]) i,
                0
            ]]);
    }
}

module up(z){
    translate([0,0,z])children();
}
r=15;
h=20;
clearance=0.5;
union(){
    t=0.5;
    k=1.15;
    difference(){
        box([-2*r, -r*k/sqrt(2), 0], [2*r, r*k/sqrt(2), h]);
        up(-1)cylinder(h+2, r=r);
    }
    rotate(a=45, v=[0,0,1])translate([-r,0,0])flex(r*2, t*10, t, h/4-clearance/2);
    rotate(a=-45, v=[0,0,1])translate([-r,0,h/4+clearance/2])flex(r*2, t*10, t, h/2-clearance);
    rotate(a=45, v=[0,0,1])translate([-r,0,h*3/4+clearance])flex(r*2, t*10, t, h/4-clearance);
    
}