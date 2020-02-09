declare name "MICHAEL GERZON BFORMAT TO PLANAR QUADRAPHONIC";
declare version "001";
declare author "Giuseppe Silvi";
declare license "GNU-GPL-v3";
declare copyright "(c)SEAM 2019";
declare description "MICHAEL GERZON BFORMAT TO PLANAR QUADRAPHONIC";

import("stdfaust.lib");
import("../seam.lib");

bamodule(W, X, Y, Z) = LFU,RFD,RBU,LBD
  with{
	  LFU = 0.5 * (W + X + Y + Z);
	  RFD = 0.5 * (W + X - Y - Z);
	  RBU = 0.5 * (W - X - Y + Z);
      LBD = 0.5 * (W - X - Y - Z);
};

bdmodule = shelf : bamodule
  with{
    shelf = fi.highshelf(2,1.76,350), fi.highshelf(2,-1.25,350), fi.highshelf(2,-1.25,350), *(0.0);
};

process = bdmodule;
