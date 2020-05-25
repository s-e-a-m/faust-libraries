declare name "MICHAEL GERZON LCR PANNING";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON LCR PANNING";
declare options "[midi:on]";

import("stdfaust.lib");
//import("../seam.lib");

RMS(n) = square : mean(n) : sqrt;
// Square of a signal
square(x) = x * x;
// Mean of n consecutive samples of a signal (uses fixpoint to avoid the
// accumulation of rounding errors)
mean(n) = float2fix : integrate(n) : fix2float : /(n);
// Sliding sum of n consecutive samples
integrate(n,x) = x - x@n : +~_;
// Convertion between float and fix point
float2fix(x) = int(x*(1<<20));
fix2float(x) = float(x)/(1<<20);

shmeter(x) = attach(x, RMS(1000, x) : ba.linear2db : hbargraph("[90][unit:dB]", -70, +6));

meters(x) = vgroup("[2] METERS", x);
signal = no.pink_noise;
sinpot = os.osc(0.01)*(45) <: attach(_/(90), hbargraph("[01] DIRECTION DEGREES",-45,45));

lcrpan(x,pot) = l,c,r
  with{
    plr = (pot) + (0.5);
    l = x*((1 - (plr)) * (pot) * (-2.0));
    c = x*(cos(pot * ma.PI));
    r = x*((plr) * (pot) * (2.0));
};

process = signal, sinpot : lcrpan : meters(shmeter), meters(shmeter), meters(shmeter);
