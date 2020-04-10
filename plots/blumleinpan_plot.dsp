declare name "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";

import("stdfaust.lib");
import("../../seam.lib");

//radsweep = (os.lf_trianglepos(1)*90)-45 : deg2rad;
radsweep = (os.lf_trianglepos(1)*360)-180 : deg2rad;

process = 1,radsweep : blumlein <: _,_,nsum;
