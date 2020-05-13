declare name "MICHAEL GERZON LRC PANNING";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON LCR PANNING";
declare options "[midi:on]";

import("stdfaust.lib");
import("../../seam.lib");

meters(x) = vgroup("[2] METERS", x);
signal = os.osc(1000);
sinpot = os.osc(0.01)*(45) <: attach(_/(90), hbargraph("[01] DIRECTION DEGREES",-45,45));

process = signal, sinpot : lrcpan : meters(shmeter), meters(shmeter), meters(shmeter);
