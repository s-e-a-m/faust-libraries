import ("stdfaust.lib");

lin2db = 20*log10(0.5);
db2lin = pow(10, -6/20.0);
process = log2lin;

pvmeter(x) = attach(x, an.amp_follower(0.150, x) : ba.linear2db : vbargraph("[90][unit:dB]", -70, +6));

amp_follower(rel) = abs : env
with {
 p = ba.tau2pole(rel);
 env(x) = x * (1.0 - p) : (+ : max(x,_)) ~ *(p);
};

tau2pole(tau) = exp(-1.0/(tau*ma.SR));

tone(freq) = _*c1 : (+~_ *(c2))
with{
  hp = freq;
  b = 2 - (cos(2*ma.PI*(hp/ma.SR)));
  c1 = 1-c2;
  c2 = b - sqrt((b*b)-1.0);
};