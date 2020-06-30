declare name "BS1770 METERING";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "BS1770 METERING";

import("../seam.lib");

// signal = no.noise;
//
// process = signal <: abs(_), RMS(1000), bs1770 : hbargraph("peak", 0, 1), hbargraph("RMS", 0, 1), hbargraph("BS1770", 0, 1);

process = sba.gsweep(23,23);
