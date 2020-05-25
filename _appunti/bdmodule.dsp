import("stdfaust.lib");

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