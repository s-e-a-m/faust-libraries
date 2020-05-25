declare name "BFORMAT DECODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2020";
declare description "BFORMAT DECODER";

import("stdfaust.lib");
//import("../seam.lib");

bfmt2poly(n,W,X,Y,Z) = polygon
  with{
      azi(n) = 360/(n) : deg2rad;
      p = 0.5;
      m = p *(0.707*(W))+((1-p)*((X*cos(azi))+(Y*sin(azi))));
      polygon(n) = par(i, n, m);
};

process = bfmt2poly(4);