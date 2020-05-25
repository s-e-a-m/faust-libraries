import("stdfaust.lib");

//pot = vslider("Pan Pot [style:knob]", 0, -90, 90, 0.01)/180 : si.smoo; 

lcrpan(x, pot) = l,c,r
  with{
    plr = (pot) + (0.5);
    l = x*((1 - (plr)) * (pot) * (-2.0));
    c = x*(cos(pot * ma.PI));
    r = x*((plr) * (pot) * (2.0));
  };

process = lcrpan;