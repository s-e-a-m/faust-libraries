declare name "MICHAEL GERZON MONO TO BFORMAT ENCODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON MONO TO BFORMAT ENCODER";

import("stdfaust.lib");
import("../../seam.lib");

// LS and RS are dead channels to create VST routing consistency
m2bfmt(L,R,LS,RS) = W,X,Y,Z
  with{
    encoder(x) = hgroup("BFMT ENCODER", x);
    azi = encoder(vslider("[01] Azimuth [style:knob]", 0, 0, 360, 0.1) : deg2rad : si.smoo);
    elv = encoder(vslider("[01] Elevation [style:knob]", 0, 0, 360, 0.1) : deg2rad : si.smoo);
    W = L * 0.707;
    X = L * cos(azi) * cos(elv);
    Y = L * sin(azi) * cos(elv);
    Z = L * sin(elv);
};

process = m2bfmt;
