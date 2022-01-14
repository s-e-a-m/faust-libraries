import("stdfaust.lib");
// ------ comb
dflc(t, g) = (+ : de.delay(ma.SR, int(t-1)))~*(max(0, min(0.999, g))) : mem;
// ------ allpass
alp(t, g) = _<:(_*(ma.neg(max(0.5, min(0.9, g)))))+(dflc(t, g)*(1-(g*g)));

t = hslider("Largest T",2,2,24000,1);
fbk = hslider("FeedBack", 0.708, 0, 0.99, 0.01) : si.smoo;

np = ffunction(int next_pr(int), <nextprime.h>,"");

alpseq(N,t,fb) = seq(i, N, alp((t/(i+1)) : np, fb));

process = alpseq(16,t,fbk);
