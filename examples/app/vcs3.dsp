declare name "EMS VCS3 Eploration";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "EMS VCS3 Eploration";

import("stdfaust.lib");
import("../../seam.lib");

osc1_g(x) = hgroup("[001]OSCILLATOR 1", x);
freq  = osc1_g(vslider("[001]FREQUENCY[style:knob][scale:exp]", 100,1,10000,0.01) : si.smoo);

process = vcs3osc1;
