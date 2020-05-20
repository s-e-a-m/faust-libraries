import("stdfaust.lib");

tone(cf) = _*c1 : (+~_ *(c2))
with{
  b = 2 - (cos(2*ma.PI*(cf/ma.SR)));
  c1 = 1-c2;
  c2 = b - sqrt((b*b)-1.0);
};

process = no.noise : tone(1000);
