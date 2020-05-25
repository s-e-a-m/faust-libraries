declare name 		"matrix";
declare version 	"1.0";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2006";

//-----------------------------------------------
// Audio Matrix : N inputs x M outputs
//-----------------------------------------------

import("stdfaust.lib");

matrix(IN,OUT) = xy
  with{
    switch(in) = checkbox("IN %3inn") : si.smoo
      with{
        inn = in+(1);
    };  
    outs(N,nout) = hgroup("OUT %3outn", par(in, N, *(switch(in)) ) :> _ )
      with{
        outn = nout+(1);
    };
    xy = vgroup("Matrix %IN x %OUT", par(in, IN, _) <: par(out, OUT, outs(IN, out)));
};

process = no.pink_noise, os.osc(1000) <: matrix(4, 4);