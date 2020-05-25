declare name "METRONOMO";
import("stdfaust.lib");
//------ numero dei campioni per minuto
SPM = ma.SR*60;
//------ cursore di selezione dei BPM
//--------------------- init min max step
BPM = hslider("[01]BPM", 60, 40, 240, 0.1);
//------ conversione da BPM a numero campioni
tempo = SPM/BPM : int; // non può essere un numero decimale
//------ impulso temporizzato
//--------------- dim dist
impulso = ba.pulsen(1,tempo);
//------ filtro risonante
fireson = fi.highpass(128,1000) : fi.lowpass(8,1000);
metronomo = impulso : fireson;
process = metronomo <: _,_;