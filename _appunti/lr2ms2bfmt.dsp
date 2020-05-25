declare name "LR STEREO TO MID SIDE TO BFORMAT ENCODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2020";
declare description "LR STEREO TO MID SIDE TO BFORMAT ENCODER";

import("stdfaust.lib");
//import("../seam.lib");

lr2ms(L,R) = mid,side
  with{
    mid = 0.707*(L+R);
    side = 0.707*(L-R);  
};

ms2bfmt(M,S) = W,X,Y,Z
  with{
    W = M * 0.707;
    X = M * cos(0) * cos(0);
    Y = S;
    Z = M * sin(0);
};

process = lr2ms,!,! : ms2bfmt;

