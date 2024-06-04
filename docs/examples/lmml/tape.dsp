import("../../../src/seam.lib");
t = hslider("samples",1,1,100,1);
process = si.bus(2), si.block(8) : sjm.apfn(4,t,1/sqrt(2)),sjm.apfn(4,t,1/sqrt(2));
