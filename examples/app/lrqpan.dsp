declare name "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";

import("stdfaust.lib");
import("../../seam.lib");

main(x) = hgroup("Mid-Side Panner", x);
p = main(vslider("[01] Pat Bal [style:knob]", 0, 0, 1, 0.01)) : si.smoo;
rad = main(vslider("[02] Azimuth [style:knob]", 0, -180, 180, 0.1)) : deg2rad : si.smoo;

process = _,p,rad : mspan_lr;
