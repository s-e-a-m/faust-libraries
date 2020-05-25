declare name "MID-SIDE STEREO TO BFORMAT ENCODER";
declare version "003";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2020";
declare description "MID-SIDE STEREO TO BFORMAT ENCODER";

import("stdfaust.lib");
//import("../seam.lib");

ms2bfmt = (_ <: _,_), _, !,*(0);

process = ms2bfmt;

