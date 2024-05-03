import("../../../src/seam.lib");
delmax = ma.SR*4;
times = par(i,23,sma.srphi(i,delmax));
//process = times;
apfnp(N,mdel,t) = seq(i,N,sms.apfv(mdel,ba.take(i+1,t) : max(sff.np,1),1/sqrt(2)));
process = apfnp(16,delmax,times);
