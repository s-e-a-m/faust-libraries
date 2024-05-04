import("../../../src/seam.lib");
// N = order
// t = smallest t
// m = base for m^i => step
apfnp(N,md,t,m) = seq(i,N,sms.apfv(md,t*m^i : max(sff.np,1),1/sqrt(2)));
// m = 3 = schroeder
process = apfnp(10,ma.SR,2,3);
