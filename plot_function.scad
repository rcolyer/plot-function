// Created in 2017 by Ryan A. Colyer.
// This work is released with CC0 into the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/
//
// https://www.thingiverse.com/thing:2391851


// Note:  For use as a library this file must be included with "include",
// not "use", so that it can access the functions defined in the including
// scad file.


//// Uncomment to try the usage examples:

//// Gravity well
//  function Func1(x, y) =
//    let ( z = 30 - 10*10/(x*x+y*y) )
//    z < 1 ? 1 : z;
//
//  translate([10, 0, 0])
//    PlotFunction(1, [-10, 0.4, 0], [-10, 0.4, 10]);


//// A bowl
//  function PolarFunc2(r, a) = let(z = 23-sqrt(23*23-r*r)) (z < 2 ? 2 : z);
//
//  difference() {
//    PlotPolarFunction(2, 20, 0.8);
//    translate([0, 0, -2]) PlotPolarFunction(2, 20.1, 0.8);
//  }


//// A rose
//  function PolarFunc3(r, a) = (15+5*sin(r*10))*exp(-pow(r*cos(a)*cos(r*8)+r*sin(a)*sin(r*35),2)/300) + 1;
//
//  PlotPolarFunction(3, 22, 0.4);


//// A simple chalice
//  function AxialFunc1(z, ang) = 5*(cos(log(z/5+1)*360) + 2);
//  function AxialFunc2(z, ang) = AxialFunc1(z, ang) - 2;
//
//  difference() {
//    PlotAxialFunction(1, [0, 0.4, 50], 180);
//    PlotAxialFunction(2, [2, 0.4, 51], 180);
//  }


// Plots the numbered function Func1 through Func9, where FuncN is 1 through 9.
// Each function is a function of x and y.
// minx_stepx_maxx should be [minx, stepx, maxx], and likewise for y,
// specifying the domain to be plotted.
// To guarantee a properly manifold shape, the routine will only render
// strictly positive values (z>0) of the defined function.  Add an offset if
// needed to achieve this.
module PlotFunction(FuncN, minx_stepx_maxx, miny_stepy_maxy) {
  minx = minx_stepx_maxx[0];
  stepx = minx_stepx_maxx[1];
  maxx = minx_stepx_maxx[2] + 0.001*stepx;
  miny = miny_stepy_maxy[0];
  stepy = miny_stepy_maxy[1];
  maxy = miny_stepy_maxy[2] + 0.001*stepy;
  minplot = 0.0005*(stepx+stepy);

  pointarrays = concat(
    [concat(  // Close miny edge of plot.
      [[maxx, miny-0.001*stepy, 0]],
      [[minx, miny-0.001*stepy, 0]],
      [
        for (x = [minx:stepx:maxx])
          [x, miny-0.001*stepy, 0.0001]
      ]
    )],

    [ for (y = [miny:stepy:maxy])
      concat(
        [[maxx, y, 0]],
        [[minx, y, 0]],
        [
          for (x = [minx:stepx:maxx]) let(
              z = CallFunc(x, y, FuncN),
              zchecked = z < minplot ? minplot : z
            )
            [x, y, zchecked]
        ]
      )
    ],

    [concat(  // Close maxy edge of plot.
      [[maxx, maxy+0.001*stepy, 0]],
      [[minx, maxy+0.001*stepy, 0]],
      [
        for (x = [minx:stepx:maxx])
          [x, maxy+0.001*stepy, 0.0001]
      ]
    )]
  );

  PlotClosePoints(pointarrays);
}


// Plots the numbered function PolarFunc1 through PolarFunc9, where
// PolarFuncN is 1 through 9.  Each function is a function of radius and
// angle.
// max_r is the outer radius, and min_step is the smallest step size between
// points.
// To guarantee a properly manifold shape, the routine will only render
// strictly positive values (z>0) of the defined function.  Add an offset if
// needed to achieve this.
module PlotPolarFunction(PolarFuncN, max_r, min_step=-1) {
  num_circle_steps = (min_step <= 0) ? 360 :
    ceil((max_r * 2*PI / min_step) / 8)*8;
  ang_step = 360 / num_circle_steps;
  eff_minstep = (min_step <= 0) ? 2*PI*max_r/num_circle_steps : min_step;
  num_r_steps = ceil(max_r / eff_minstep);
  r_step = (max_r - 0.001*eff_minstep) / num_r_steps;
  minplot = 0.001*r_step;

  pointarrays = concat(
    [
      [ for (a = [0:ang_step:359.9999])
          [max_r * cos(a), max_r * sin(a), 0]
      ]
    ],

    [ for (r = [max_r:-r_step:0.000001*r_step])
        [ for (a = [0:ang_step:359.9999]) let(
              z = CallPolarFunc(r, a, PolarFuncN),
              zchecked = z < minplot ? minplot : z
            )
            [r * cos(a), r * sin(a), zchecked]
        ]
    ]
  );

  PlotClosePoints(pointarrays);
}


// Plots the numbered function AxialFunc1 through AxialFunc9, where
// AxialFuncN is 1 through 9.  Each function is a function of z-height and
// angle, and returns the radius outward in the xy-plane.
// max_r is the outer radius, and min_step is the smallest step size between
// points.
// minz_stepz_maxz should be [minz, stepz, maxz], and likewise for y,
// specifying the domain to be plotted.
// To guarantee a properly manifold shape, the routine will only render
// strictly positive values (r>0) of the defined function.  Add an offset if
// needed to achieve this.
module PlotAxialFunction(AxialFuncN, minz_stepz_maxz, num_circle_steps=360) {
  ang_step = 360 / num_circle_steps;
  minz = minz_stepz_maxz[0];
  stepz = minz_stepz_maxz[1];
  maxz = minz_stepz_maxz[2] + 0.001*stepz;
  minplot = 0.001*stepz;

  pointarrays = [
    for (z = [minz:stepz:maxz])
      [ for (ai = [0:num_circle_steps-1]) let(
            a = ai * ang_step,
            r = CallAxialFunc(z, a, AxialFuncN),
            rchecked = r < minplot ? minplot : r
          )
          [rchecked * cos(a), rchecked * sin(a), z]
      ]
   
  ];

  PlotClosePoints(pointarrays);
}


// Relays function calls to Func1 through Func9
function CallFunc(x, y, n) = 
  (n == 1) ? Func1(x, y) :
  (n == 2) ? Func2(x, y) :
  (n == 3) ? Func3(x, y) :
  (n == 4) ? Func4(x, y) :
  (n == 5) ? Func5(x, y) :
  (n == 6) ? Func6(x, y) :
  (n == 7) ? Func7(x, y) :
  (n == 8) ? Func8(x, y) :
  (n == 9) ? Func9(x, y) :
  FunctionNumberOutOfRange;


// Relays function calls to PolarFunc1 through PolarFunc9
function CallPolarFunc(r, ang, n) = 
  (n == 1) ? PolarFunc1(r, ang) :
  (n == 2) ? PolarFunc2(r, ang) :
  (n == 3) ? PolarFunc3(r, ang) :
  (n == 4) ? PolarFunc4(r, ang) :
  (n == 5) ? PolarFunc5(r, ang) :
  (n == 6) ? PolarFunc6(r, ang) :
  (n == 7) ? PolarFunc7(r, ang) :
  (n == 8) ? PolarFunc8(r, ang) :
  (n == 9) ? PolarFunc9(r, ang) :
  PolarFunctionNumberOutOfRange;


// Relays function calls to AxialFunc1 through AxialFunc9
function CallAxialFunc(z, ang, n) = 
  (n == 1) ? AxialFunc1(z, ang) :
  (n == 2) ? AxialFunc2(z, ang) :
  (n == 3) ? AxialFunc3(z, ang) :
  (n == 4) ? AxialFunc4(z, ang) :
  (n == 5) ? AxialFunc5(z, ang) :
  (n == 6) ? AxialFunc6(z, ang) :
  (n == 7) ? AxialFunc7(z, ang) :
  (n == 8) ? AxialFunc8(z, ang) :
  (n == 9) ? AxialFunc9(z, ang) :
  AxialFunctionNumberOutOfRange;


function isfinite(x) = (!(x!=x)) && (x<(1/0)) && (x>(-1/0));


// This generates a closed polyhedron from an array of arrays of points,
// with each inner array tracing out one loop outlining the polyhedron.
// pointarrays should contain an array of N arrays each of size P outlining a
// closed manifold.  The points must obey the right-hand rule.  For example,
// looking down, the P points in the inner arrays are counter-clockwise in a
// loop, while the N point arrays increase in height.  Points in each inner
// array do not need to be equal height, but they usually should not meet or
// cross the line segments from the adjacent points in the other arrays.
// (N>=2, P>=3)
// Core triangles:
//   [j][i], [j+1][i], [j+1][(i+1)%P]
//   [j][i], [j+1][(i+1)%P], [j][(i+1)%P]
//   Then triangles are formed in a loop with the middle point of the first
//   and last array.
module PlotClosePoints(pointarrays) {
  function recurse_avg(arr, n=0, p=[0,0,0]) = (n>=len(arr)) ? p :
    recurse_avg(arr, n+1, p+(arr[n]-p)/(n+1));

  N = len(pointarrays);
  P = len(pointarrays[0]);
  NP = N*P;
  lastarr = pointarrays[N-1];
  midbot = recurse_avg(pointarrays[0]);
  midtop = recurse_avg(pointarrays[N-1]);

  faces_bot = [
    for (i=[0:P-1])
      [0,i+1,1+(i+1)%len(pointarrays[0])]
  ];

  loop_offset = 1;
  bot_len = loop_offset + P;

  faces_loop = [
    for (j=[0:N-2], i=[0:P-1], t=[0:1])
      [loop_offset, loop_offset, loop_offset] + (t==0 ?
      [j*P+i, (j+1)*P+i, (j+1)*P+(i+1)%P] :
      [j*P+i, (j+1)*P+(i+1)%P, j*P+(i+1)%P])
  ];

  top_offset = loop_offset + NP - P;
  midtop_offset = top_offset + P;

  faces_top = [
    for (i=[0:P-1])
      [midtop_offset,top_offset+(i+1)%P,top_offset+i]
  ];

  points = [
    for (i=[-1:NP])
      (i<0) ? midbot :
      ((i==NP) ? midtop :
      pointarrays[floor(i/P)][i%P])
  ];
  faces = concat(faces_bot, faces_loop, faces_top);

  polyhedron(points=points, faces=faces, convexity=8);
}


