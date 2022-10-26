import("seam.lib");
import("seam.vcs3.lib");

switch(in) = checkbox("IN %3inn") : si.smoo
  with { 
      inn = in + (1);
};

outcol(in,col) = vgroup("OUT %3coln", par(in, in, *(switch(in)))) :> _
  with {
      coln = col + (1);
};
//par successione parallela di funzioni, in questo caso è la funzione "*switch"

//process = no.noise, os.osc(1000) : outcol(2,7); //Come dovrebbe apparire più o meno il process finale del Vcs3

matrix(in,out) = hgroup("MATRIX %in %out", si.bus(in) <: par(out, out, outcol(in, out)));
// si.bus(in) serve per dare tutte le stesse entrate a tutte le uscite
