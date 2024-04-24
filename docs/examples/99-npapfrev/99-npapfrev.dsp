import("../../../src/seam.lib");
// N = order
// t = smallest t
// m = base for m^i => step
apfnp(N,t,m) = seq(i,N,sms.apfv(ma.SR*N*2,t*m^i : max(sff.np,1),1/sqrt(2)));
// m = 3 = schroeder
process = apfnp(13,2,3);
