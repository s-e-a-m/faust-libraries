declare name "MICHAEL GERZON AB-MODULE";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON AB-MODULE";

import("stdfaust.lib");
//import("../../seam.lib");

abmodule(LFU,RFD,RBU,LBD) = W,X,Y,Z
	with{
    W = (0.5 * (LFU + RFD + RBU + LBD));
	  X = (0.5 * (LFU + RFD - RBU - LBD));
	  Y = (0.5 * (LFU - RFD - RBU + LBD));
	  Z = (0.5 * (LFU - RFD + RBU - LBD));
};

process = abmodule;
