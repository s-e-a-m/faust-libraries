declare name "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";

import("stdfaust.lib");
import("../../seam.lib");

pisweep = (os.lf_trianglepos(1)*360)-180;
rad = 45 : deg2rad;

//process = os.osc(50), 0 : mspan;

process = os.osc(50) <: *(sin(rad)), *(cos(rad));
