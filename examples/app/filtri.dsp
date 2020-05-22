import("stdfaust.lib");

tone(freq) = _*c1 : (+~*(c2))
with{
  b = 2 - (cos(2*ma.PI*(freq/ma.SR)));
  c1 = 1-c2;
  c2 = b - sqrt((b*b)-1.0);
};

g = 0.9;
freq = hslider("freq", 100,1,2000,1);

a(fc) = cos((2*ma.PI*fc)/ma.SR)-1+sqrt((0.5*(1+cos(2*((2*ma.PI*fc)/ma.SR))))-4*cos((2*ma.PI*fc)/ma.SR)+3);

onesample = (_<:mem+_)/2;

cy_onepole(fc) = *(a) : +~*(ac)
with{
    a= sin(abs(fc)*2*ma.PI/ma.SR);
    ac = 1-a;
    clip(a,b) = max(a) : min(b);
};

onepole(fc) = *(a) : +~*(1-a)
with{
    a = cos((2*ma.PI*fc)/ma.SR)-1+sqrt((0.5*(1+cos(2*((2*ma.PI*fc)/ma.SR))))-4*cos((2*ma.PI*fc)/ma.SR)+3);
};

process = no.noise <: _, fi.pole(g), fi.zero(g),onesample,tone(freq),cy_onepole(freq),onepole(freq);
