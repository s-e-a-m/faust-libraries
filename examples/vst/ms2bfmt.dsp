declare name "MS STEREO TO BFORMAT ENCODER";
declare version "003";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MS STEREO TO BFORMAT ENCODER";

import("stdfaust.lib");
import("../../seam.lib");

// LS and RS are dead channels to create VST routing consistency
midside2bfmt(M,S,LS,RS) = W,X,Y,Z
  with{
    W = M * 0.707;
    X = M * cos(0) * cos(0);
    Y = S;
    Z = M * sin(0);
};

process = _,_,*(0.0),*(0.0) : midside2bfmt;
