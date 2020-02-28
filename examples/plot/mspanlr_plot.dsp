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

process = os.osc(lsweep), pot : mspan_lr;
