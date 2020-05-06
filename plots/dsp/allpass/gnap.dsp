declare name "GIORGIO NOTTOLI ALLPASS FILTER DESIGN";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2020";
declare description "GIORGIO NOTTOLI ALLPASS FILTER DESIGN";

import("stdfaust.lib");
import("../../../seam.lib");

process = lsweep : gnalp(512,0.9);
