// (C) 2023 Dmytry Lavrov.
use <../common/common.scad>

$fa=3;
$fs=0.2;
large=1000;

difference(){
    cylinder(14,r=6, $fn=6);
    cylinder(10, r=3.6/2);
    up(10)cylinder(5, r=5.5/2);
}