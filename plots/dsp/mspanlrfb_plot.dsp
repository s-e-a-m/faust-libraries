declare name "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER - LEFT CHANNEL IN FEEDBACK";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER - LEFT CHANNEL IN FEEDBACK";

import("stdfaust.lib");
import("../../seam.lib");

radsweep = (os.lf_trianglepos(1)*360)-180 : deg2rad;

process =  1,0.5,(radsweep <:_,_) : (+,_,_ : mspan_lr)~*(1), _/ma.PI;
