declare name "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER - LEFT CHANNEL IN FEEDBACK";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER - LEFT CHANNEL IN FEEDBACK";

import("stdfaust.lib");
import("../../seam.lib");

pot = os.lf_trianglepos(1);// : 1-(_);

process = 1, pot : (+,_ : lrpanq)~*(1), (pot*350);
