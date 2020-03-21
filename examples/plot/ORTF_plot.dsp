declare name "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MID SIDE PANNER - LEFT RIGHT LOUDSPEAKER";

import("stdfaust.lib");
import("../../seam.lib");

//radsweep = (os.lf_trianglepos(1)*90)-45 : deg2rad;
radsweep = (os.lf_trianglepos(1)*360)-180 : deg2rad;
radfix = 23 : deg2rad;

process = 1,radsweep : ortf <: _,_,nsum;
//process = os.osc(20000),radsweep : ortf <: _,_,nsum,ndif;

band1 = os.osc(20000),radfix : ortf : nsum;// : RMS(1000);
band2 = os.osc(10000),radfix : ortf : nsum;// : RMS(1000);
band3 = os.osc(5000),radfix : ortf : nsum;// : RMS(1000);
band4 = os.osc(2500),radfix : ortf : nsum;// : RMS(1000);
band5 = os.osc(1250),radfix : ortf : nsum;// : RMS(1000);
band6 = os.osc(625),radfix : ortf : nsum;// : RMS(1000);
band7 = os.osc(312),radfix : ortf : nsum;// : RMS(1000);
band8 = os.osc(150),radfix : ortf : nsum;// : RMS(1000);
band9 = os.osc(75),radfix : ortf : nsum;// : RMS(1000);
band10 = os.osc(35),radfix : ortf : nsum;// : RMS(1000);

//process = band1, band2, band3, band4, band5, band6, band7, band8, band9, band10 :> _;

ortfnoise = no.pink_noise, radfix : ortf <: nsum,ndif;

//process = ortfnoise;
