declare name "MICHAEL GERZON LCR PANNING";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON LCR PANNING";
declare options "[midi:on]";

import("stdfaust.lib");

meters(x) = vgroup("[2] METERS", x);
signal = os.osc(1000);
sinpot = os.osc(0.01)*(45) <: attach(_/(90), hbargraph("[01] DIRECTION DEGREES",-45,45));

svmeter(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : vbargraph("[90][unit:dB]", -70, +6));
shmeter(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : hbargraph("[90][unit:dB]", -70, +6));
//------------------------------------------------------------------- RMS METERS

lcrpan(x,pot) = l,c,r
  with{
    plr = (pot) + (0.5);
    l = x*((1 - (plr)) * (pot) * (-2.0));
    c = x*(cos(pot * ma.PI));
    r = x*((plr) * (pot) * (2.0));
  };

process = signal, sinpot : lcrpan : meters(shmeter), meters(shmeter), meters(shmeter);
