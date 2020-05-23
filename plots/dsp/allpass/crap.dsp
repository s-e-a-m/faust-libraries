declare name "CURTIS ROADS ALLPASS FILTER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2020";
declare description "CURTIS ROADS ALLPASS FILTER";

import("stdfaust.lib");
import("../../../seam.lib");

process = lsweep : cmtap(512,0.9);
