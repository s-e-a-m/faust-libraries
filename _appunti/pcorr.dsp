import("stdfaust.lib");

pcorr(L,R) = correlation
  with{
    LSQ = L*L;
    RSQ = R*R;
    correlation = L*RSQ, LSQ, RSQ  : fi.lowpass3e(1000), sqrt(fi.lowpass3e(1000)),sqrt(fi.lowpass3e(1000)) :_,* :/;
  };

phcorr = (_<:_,* : _,sqrt(fi.lowpass3e(100))),(_ <: * <: sqrt(fi.lowpass3e(100)),_) : _,*,_ : _, ro.cross(2) : *,_ : fi.lowpass3e(100),_ : /;
process = os.osc(100), no.pink_noise : phcorr : vbargraph("[style:numerical]", -2,2);