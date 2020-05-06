declare name "MICHAEL GERZON MONO TO BFORMAT ENCODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON MONO TO BFORMAT ENCODER";

import("stdfaust.lib");
import("../../seam.lib");

bfmt2m(W,X,Y,Z) = m
  with{
      encoder(x) = hgroup("BFMT MONO-DECODER", x);
      azi = encoder(vslider("[01] Azimuth [style:knob]", 0, 0, 360, 0.1) : deg2rad : si.smoo);
      p = encoder(vslider("[02] Polar [style:knob]", 0.5, 0, 1, 0.01) : si.smoo);
      m = p *(0.707*(W))+((1-p) *((X*cos(azi))+(Y*sin(azi))));
};

process = bfmt2m;
