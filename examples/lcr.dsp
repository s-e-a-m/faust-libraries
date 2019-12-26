declare name "MICHAEL GERZON LCR PANNING";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON LCR PANNING";
declare options "[midi:on]";

import("stdfaust.lib");
import("../seam.lib");

meters(x) = vgroup("[2] METERS", x);
signal = os.osc(1000);
sinpot = os.osc(0.01)*(0.5) <: attach(_, hbargraph("[01] DIRECTION",-0.5,0.5));

process = signal, sinpot : lcrpan : meters(shmeter), meters(shmeter), meters(shmeter);
