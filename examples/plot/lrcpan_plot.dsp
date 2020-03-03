declare name "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";

import("stdfaust.lib");
import("../../seam.lib");

pisweep = (os.lf_trianglepos(1)*360)-180;
pot = pisweep : deg2rad ;//vslider("[01] Azimuth [style:knob]", 0, -180, 180, 0.1) : deg2rad : si.smoo;

lrcpan(x,pot) = l,r,c
  with{
    plr = (pot) + (0.5);
    l = x*((1 - (plr)) * (pot) * (-2.0));
    c = x*(cos(pot * ma.PI));
    r = x*((plr) * (pot) * (2.0));
};

mspan(x,rad) = m,s
  with{
    m = (0.5*x)+(0.5*(x*cos(rad)));
    s = x*(sin(-rad));
};

center(x,rad) = (0.5*x)+(0.5*(x*cos(rad)));

process = 1, pot <: mspan_lr,center ;
