# faust-libraries

The SEAM library local importing points to other libraries catalogued by arguments, like in Standard Faust Libraries.

Actually there are five different libraries:

* **seam.lib** contains general functions and the pointers to each specific library. It may also comprehend the custom performative environment definition, as it could be for the inputs and the out- puts, the setup parameters and the performative controls.
* **gerzon.lib** contains early Michael Gerzon works, his core concepts of spatialization and stereophony, that conducted him to conceive the Ambisonic technology. In a sustained environment, the role of this library is to avoid misunderstanding of what stereo is and what we are loosing in the electroacoustic staging perception.
* **hardware.lib** contains hardware-related functions like MIDI mapping and I/O assignment to an audio interface, with a routing strategy to connect instruments to real-world hardware with a graphical user interface to map routing.
* **measurement.lib** contains some audio analysis strategy to define musical display feature for audio inspection, such as integrated measurement and loudness monitoring, that are indispensable tools for today staging of public addressed music.
* **nono.lib** is the first author-related library that points to contain Live Electronics Instruments. The idea is to collect instruments into the library and use them, work by work, in a hardware-like approach. The nono.lib should contain reusable instruments typical of his literature like the Harmonizer, the Halaphon, and so on, directly called back into the performance environment of each work, to enforce the reusability and the sustainability of those instruments.
* **vcs3.lib** is the first synth related library, it contains a porting of the EMS VCS3 synth; the main idea is to recreate the 1969 synth into the library and use it together with the other libraries.

