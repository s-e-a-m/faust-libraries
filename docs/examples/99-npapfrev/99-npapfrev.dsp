import("../../../src/seam.lib");
// N = order
// t = smallest t
// m = base for m^i => step
np = ffunction(int next_pr(int), "nextprime.h","");
apfnp(N,md,t,m) = seq(i,N,sms.apfv(md,t*m^i : max(np,1),1/sqrt(2)));
// m = 3 = schroeder
process = os.impulse : apfnp(10,ma.SR,2,3);
