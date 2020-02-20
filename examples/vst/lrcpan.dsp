declare name "MICHAEL GERZON LRC PANNING";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON LRC PANNING";
declare options "[midi:on]";

import("stdfaust.lib");
import("../../seam.lib");

pot = hslider("[01] LRCPOT", 0, -45, 45, 0.1) : /(90.0) : si.smoo;

// y and z are dead channels to create VST routing consistency
lrcpan(x,y,z) = l,r,c
  with{
    plr = (pot) + (0.5);
    l = x*((1 - (plr)) * (pot) * (-2.0));
    c = x*(cos(pot * ma.PI));
    r = x*((plr) * (pot) * (2.0));
};

process = lrcpan;
