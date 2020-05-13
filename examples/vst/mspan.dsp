declare name "MID SIDE PANNER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MID SIDE PANNER";

import("stdfaust.lib");
//import("../seam.lib");
deg2rad = *(ma.PI/180);

mspan(x) = m, s
  with{
    pot = vslider("[01] Azimuth [style:knob]", 0, -180, 180, 0.1) : deg2rad : si.smoo;
    m = (0.5 * x) + (0.5 * (x * cos(pot)));
    s = x *(sin(-pot));
};

process = _,! : mspan;
