declare name "MS STEREO TO BFORMAT ENCODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MS STEREO TO BFORMAT ENCODER";

import("stdfaust.lib");
//import("../seam.lib");
deg2rad = *(ma.PI/180);

inspector(x) = vgroup("[01]MS INSP", x);

// LS and RS are dead channels to create VST routing consistency
ms2bfmt(M,S,LS,RS) = W,X,S,Z
  with{
    W = M * 0.707;
    X = M * cos(0) * cos(0);
    Z = M * sin(0);
};

bargraphs = hgroup("[02]BFMT", vbargraph("W", -1,1), vbargraph("X", -1,1), vbargraph("Y", -1,1), vbargraph("Z", -1,1));

mspan(x) = m, s
  with{
    pot = vslider("[01] Azimuth [style:knob]", 0, -180, 180, 0.1) : deg2rad : si.smoo;
    m = (0.5 * x) + (0.5 * (x * cos(pot)));
    s = x *(sin(-pot));
};

process = os.osc(1000) : mspan, 0,0 : ms2bfmt : bargraphs;

