import("stdfaust.lib");

tempo = nentry("[01]Tempo", 60, 20, 320, 0.1);
measure = nentry("[02]Misura", 4, 1, 16, 1.0) : int;
beat = ba.tempo(tempo) : int;
bar = beat / measure : int;
beatpulse = ba.pulsen(1, beat);
barpulse = ba.pulsen(1, bar);

freq = vslider("[03]Tone[style:knob]", 1000, 500, 2000, 1.0);

process =   beatpulse, barpulse : fi.highpass(128, freq), fi.highpass(128, 2*freq) : fi.lowpass(8, freq), fi.lowpass(8, 2*freq);