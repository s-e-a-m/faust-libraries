import("stdfaust.lib");
//import("../faust-libraries/seam.lib");

delbank = _ : ( + : de.delay(D1,D1))~*(fbgain1);

fbgroup(x) = hgroup("Feedback Delay", x);

fbgain1 = fbgroup(vslider("[01]Fb 1 [style:knob]", 0.,0.,1.,0.1) : si.smoo);
fbgain2 = fbgroup(vslider("[02]Fb 3 [style:knob]", 0.,0.,1.,0.1) : si.smoo);
fbgain3 = fbgroup(vslider("[03]Fb 5 [style:knob]", 0.,0.,1.,0.1) : si.smoo);
fbgain4 = fbgroup(vslider("[04]Fb 7 [style:knob]", 0.,0.,1.,0.1) : si.smoo);

D1 = ba.sec2samp(5.0);
D2 = ba.sec2samp(5.5);
D3 = ba.sec2samp(6.2);
D4 = ba.sec2samp(6.6);
D5 = ba.sec2samp(7.3);
D6 = ba.sec2samp(7.7);
D7 = ba.sec2samp(8.2);
D8 = ba.sec2samp(9.1);

process = delbank;