declare name "MICHAEL GERZON MONO TO BFORMAT ENCODER";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON MONO TO BFORMAT ENCODER";

import("stdfaust.lib");
import("../seam.lib");

m2bfmt(x) = W,X,Y,Z
  with{
      encoder(x) = hgroup("BFMT ENCODER", x);
      azi = encoder(vslider("[01] Azimuth [style:knob]", 0, 0, 360, 0.1) : d2r : si.smoo);
      elv = encoder(vslider("[01] Elevation [style:knob]", 0, 0, 360, 0.1) : d2r : si.smoo);
      W = x * 0.707;
      X = x * cos(azi) * cos(elv);
      Y = x * sin(azi) * cos(elv);
      Z = x * sin(elv);
  };

process = os.osc(1000) : m2bfmt;
