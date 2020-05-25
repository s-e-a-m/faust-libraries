import("stdfaust.lib");

oscb(f) = os.impulse : fi.tf2(1,0,0,a1,1)
with {
  a1 = 2*cos(2*ma.PI*f/ma.SR)*_';
};

process = 0.01*(oscb(100));