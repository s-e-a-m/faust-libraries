declare name "MICHAEL GERZON UHJ TO BFORMAT DECODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON UHJ TO BFORMAT DECODER";

import("stdfaust.lib");
import("../seam.lib");

uhj2bfmt(L,R,T,Q) = W,X,Y,Z
  with{
    S = (L+R)/2;
    D = (L-R)/2;
    j = fi.pospass(128, 35) : *(2), !;
    W = (0.982*S) + j(0.197*((0.828*D)+(0.768*T)));
    X = (0.419*S) - j(0.828*(D+(0.768*T)));
    Y = j(0.187*S) + ((0.796*D)-(0.676*T));
    Z = 1.023 * Q;
};

process = uhj2bfmt;
