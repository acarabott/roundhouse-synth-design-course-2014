/* ============================================================ */
/* Session 2 Warmup	                                            */
/* ============================================================ */

s.meter;
s.makeWindow;
s.scope;
FreqScope.new;

/*
Let's do some warm ups to get back into it.
You should look at the files from last week

Create three SynthDefs that are playable with the keyboard, using any of these
oscillators

LFSaw, LFTri, LFCub, LFPar

1. Mono synth, no envelope, change frequency with keyboard, no volume control
2. Polyphonic synth with an ADSR envelope and a gate so that it can be released on noteOff
3. Polyphonic synth with a custom envelope
*/

SynthDef(\name, { |out=0|
	Out.ar(out,

	);
}).add;

MIDIIn.connectAll;
~synths = Array.newClear(128);

MIDIdef.noteOn(\noteOnAction, {|vel, num|
});

MIDIdef.noteOff(\noteOffAction, {|vel, num|
});
