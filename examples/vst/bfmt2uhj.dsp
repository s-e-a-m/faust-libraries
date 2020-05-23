declare name "MICHAEL GERZON BFORMAT TO UHJ ENCODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON BFORMAT TO UHJ ENCODER";

import("stdfaust.lib");
import("../seam.lib");

bfmt2uhj(W,X,Y,Z) = L,R,T,Q
  with{
    j = fi.pospass(128, 300) : !, *(2);

    S = 0.9396926 * W + 0.1855740 * X;
    D = j((-0.3420201 * W) + (0.5098604 * X)) + (0.6554516 * Y);

    L = 0.5 * (S + D);
    R = 0.5 * (S - D);
    T = j((-0.1432 * W + 0.6512 * X)) - (0.7071 * Y);
    Q = 0.9772 * (Z);
};

process = bfmt2uhj;
