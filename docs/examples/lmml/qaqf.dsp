import("../../../src/seam.lib");
qa = hslider("[01] QA", 1,1,100,1)/200 : si.smoo;
qf = hslider("[02] QF",0.1,0.1,320,0.1);

process = par(i,8,sml.qaqf(qa,qf));
