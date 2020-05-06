declare name "STD FAUST ALLPASS";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2020";
declare description "STD FAUST ALLPASS";

import("stdfaust.lib");
import("../../../seam.lib");

process = lsweep : fi.allpass_comb((ma.SR/2),512,0.9);
