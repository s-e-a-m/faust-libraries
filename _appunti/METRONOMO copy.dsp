//-------------------------------------------- METRONOMO ---
//------------------------------- dichiarazioni iniziali ---
declare name "METRONOMO";
import("stdfaust.lib");
//-------------------------------- cursore selezione BPM ---
//-------------------- init-min--max-step-------------------
BPM = hslider("[01]BPM", 60, 40, 240, 0.1);
//------------------- numero di campioni per ogni minuto ---
SPM = (60*ma.SR);
//------------- formula di conversione da BPM a campioni ---
tempo = SPM/BPM : int; // solo la parte intera
//---------------------------------------------- SINTESI ---
//------------------------------------- filtro risonante ---
fireson = fi.highpass(128, 1000) : fi.lowpass(8, 1000);
//------------------------------------ impulso risonante ---
metronomo = ba.pulsen(1, tempo) : fireson;
//-------------------- METRONOMO SU DUE CANALI DI USCITA ---
process =   metronomo <: _,_ ;