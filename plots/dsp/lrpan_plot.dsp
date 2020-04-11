declare name "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";

import("stdfaust.lib");
import("../../seam.lib");

pot = os.lf_trianglepos(1);

lrpan(x,pot) 	= l,r
  with{
    l = sqrt(pot)*x;
    r = sqrt(1-pot)*x;
};

process = 1, pot : lrpan;
