// Created in 2017 by Ryan A. Colyer.
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/
//
// https://www.thingiverse.com/thing:2391851


include <plot_function.scad>


Demo(0);

// 1 -- Gravity well
function Func1(x, y) =
  let ( z = 50 - 50/sqrt(x*x+y*y) )
  z < 1 ? 1 : z;

// 2 -- A bowl
function PolarFunc2(r, a) = let(z = 23-sqrt(23*23-r*r)) (z < 2 ? 2 : z);

// 3 -- A rose
function PolarFunc3(r, a) = (15+5*sin(r*10))*exp(-pow(r*cos(a)*cos(r*8)+r*sin(a)*sin(r*35),2)/300) + 1;

// 4 -- A simple chalice
function AxialFunc1(z, ang) = 5*(cos(log(z/5+1)*360) + 2);
function AxialFunc2(z, ang) = AxialFunc1(z, ang) - 2;

// 5 --
// Plane wave
function Func4(x, y) = 2.5*(1+cos(y*36))+2;
// Two-slit interference
slit_pos = 10;
function Func5(x, y) = 1.25*(1+cos(sqrt(y*y+(x-slit_pos)*(x-slit_pos))*36)) +
  1.25*(1+cos(sqrt(y*y+(x+slit_pos)*(x+slit_pos))*36))+2;

// One-slit
function Func6(x, y) = 2.5*(1+cos(sqrt(y*y+(x-slit_pos)*(x-slit_pos))*36))+2;

module DemoNumber(n) {
  SelectFrom(n-1) {

    // 1 -- Gravity well
    translate([10, 0, 0])
      PlotFunction(1, [-10, 0.2, 0], [-10, 0.2, 10]);

    // 2 -- A bowl
    difference() {
      PlotPolarFunction(2, 20, 0.8);
      translate([0, 0, -2]) PlotPolarFunction(2, 20.1, 0.8);
    }

    // 3 -- A rose
    PlotPolarFunction(3, 22, 0.4);

    // 4 -- A simple chalice
		difference() {
			PlotAxialFunction(1, [0, 0.4, 50], 180);
			PlotAxialFunction(2, [2, 0.4, 51], 180);
		}

    // 5 -- Two-slit interference
    union() {
      PlotFunction(4, [-25, 0.4, 25], [-25, 0.4, 0]);
      difference() {
        translate([-25, -1, 0]) cube([50, 2, 16]);
        translate([slit_pos, 0, 16/2]) cube([2, 3, 16+2], center=true);
        translate([-slit_pos, 0, 16/2]) cube([2, 3, 16+2], center=true);
      }
      PlotFunction(5, [-25, 0.4, 25], [0, 0.4, 30]);
    }

    // 6 -- One-slit wave
    union() {
      PlotFunction(4, [-25, 0.4, 25], [-25, 0.4, 0]);
      difference() {
        translate([-25, -1, 0]) cube([50, 2, 16]);
        translate([slit_pos, 0, 16/2]) cube([2, 3, 16+2], center=true);
      }
      PlotFunction(6, [-25, 0.4, 25], [0, 0.4, 30]);
    }

  }
}


module SelectFrom(n) { children(n); }

module Demo(n=0) {
  demo_cnt = 5;
  demo_cnt_sqrt = floor(sqrt(demo_cnt));
  demo_order = [2, 3, 4, 1, 5];
  rotate_demos = 270;
  //rotate_demos = 180;
  if (n == 0) {
    for (i=[1:demo_cnt])
      translate([((i-1)%demo_cnt_sqrt)*60, floor((i-1)/demo_cnt_sqrt)*60, 0])
        rotate([0, 0, rotate_demos])
        if (i-1 < len(demo_order)) {
          DemoNumber(demo_order[i-1]);
        }
        else{
          DemoNumber(i);
        }
  }
  else {
    DemoNumber(n);
  }
}


