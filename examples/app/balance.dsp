import("stdfaust.lib");

p = hslider("balance", 0.5,0,1,0.01);

psweep = ba.sweep(1001,1)/1000;

linbal(p) = _*(1-p),_*(p);
quadbal(p) = _*sqrt(1-p),_*sqrt(p);
normbal(p) = _*(min(1,2*(1-p))),_*(min(1,2*(p)));
norqbal(p) = _*(min(1,2*sqrt(1-p))),_*(min(1,2*sqrt(p)));
//process = 2*(1-p) : min(1);
process = 1<:linbal(psweep),quadbal(psweep),normbal(psweep) : +,+,+;
