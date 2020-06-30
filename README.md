# faust-libraries

The SEAM library local importing points to other libraries catalogued by arguments, like in Standard Faust Libraries.

Actually there are five different libraries:

* **seam.lib** contains general functions and the pointers to each specific library. It may also comprehend the custom performative environment definition, as it could be for the inputs and the out- puts, the setup parameters and the performative controls.
* **gerzon.lib** contains early Michael Gerzon works, his core concepts of spatialization and stereophony, that conducted him to conceive the Ambisonic technology. In a sustained environment, the role of this library is to avoid misunderstanding of what stereo is and what we are loosing in the electroacoustic staging perception.
* **hardware.lib** contains hardware-related functions like MIDI mapping and I/O assignment to an audio interface, with a routing strategy to connect instruments to real-world hardware with a graphical user interface to map routing.
* **measurement.lib** contains some audio analysis strategy to define musical display feature for audio inspection, such as integrated measurement and loudness monitoring, that are indispensable tools for today staging of public addressed music.
* **nono.lib** is the first author-related library that points to contain Live Electronics Instruments. The idea is to collect instruments into the library and use them, work by work, in a hardware-like approach. The nono.lib should contain reusable instruments typical of his literature like the Harmonizer, the Halaphon, and so on, directly called back into the performance environment of each work, to enforce the reusability and the sustainability of those instruments.
* **vcs3.lib** is the first synth related library, it contains a porting of the EMS VCS3 synth; the main idea is to recreate the 1969 synth into the library and use it together with the other libraries.

```text
declare name "Faust SEAM main lib";
declare version "0.2";
declare author "Giuseppe Silvi";
declare author "Davide Tedesco";
declare license "CC3";

// calling standard faust libraries
import("stdfaust.lib");

// ## SEAM LIBS

// ### standard faust lib extensions
sba = library("seam.basic.lib");
sma = library("seam.math.lib");
sfi = library("seam.filters.lib");

// ### michael gerzon and general ambisonic teory
smg = library("seam.gerzon.lib");
sam = library("seam.ambisonic.lib");

// ### stereophony and perception
sst = library("seam.stereophony.lib");
shr = library("seam.hrtf.lib");

// ### CSound and MaxMsp object cloning
scs = library("seam.csound.lib");
scy = library("seam.cyclone.lib");

// ### author specific literature
sln = library("seam.nono.lib");
sgn = library("seam.nottoli.lib");

// ### live electronics stuff
sgu = library("seam.gui.lib");
shw = library("seam.hardware.lib");
san = library("seam.analyzers.lib");
smx = library("seam.mixer.lib");

// ### instrument specific literature
svc = library("seam.vcs3.lib");
```

## Example usage

```text
process = sma.PIc;
```
