import("../../../src/seam.lib");
//------------------------- SMOOTH DELAY FEEDBACK IN LOOP - FIXED - VARIABLE ---
dflcvs(md,it,t,g) = (+ : de.sdelay(md,it,int(t-1)))~*(g) : mem;
/*
process = ba.pulsen(1,ma.SR/3) : dflcvs(ma.SR,256,tmod(1000,250,0.4),1/sqrt(2))
with{
    tmod(t,r,f) = t+os.osc(f)*r;
};
*/
//
//------------------------- SMOOTH DELAY FEEDBACK IN LOOP - FIXED - VARIABLE ---
apfvs(md,it,t,g) = _ <: *(-g)+(dflcvs(md,it,t,g)*(1-(g*g)));
process = ba.pulsen(1,ma.SR/3) : apfvs(ma.SR,256,tmod(3500,200,1),os.osc(0.1))
with{
    tmod(t,r,f) = t+os.osc(f)*r;
};
