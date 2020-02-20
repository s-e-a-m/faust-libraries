declare name "MS STEREO TO BFORMAT ENCODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MS STEREO TO BFORMAT ENCODER";

import("stdfaust.lib");
import("../../seam.lib");

// LS and RS are dead channels to create VST routing consistency
ms2bfmt(M,S,LS,RS) = W,X,Y,Z
  with{
    W = 0.5 *((M + S) + (M-S));
    X = M *(cos(0));
    Y = S;
    Z = 0.0;
};

process = ms2bfmt;
