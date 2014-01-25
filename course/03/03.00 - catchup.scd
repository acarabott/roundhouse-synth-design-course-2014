/* ============================================================ */
/* Session 3 Warmup	                                            */
/* ============================================================ */

(
s.meter;
s.makeWindow;
s.scope;
FreqScope.new;
)

MIDIIn.connectAll;

(
/*
Mono synth with a square wave, only freq and mul control
*/

SynthDef(\monosquare, { |freq=440, mul=0.1, out=0|
	var sig = LFPulse.ar(freq, 0, 0.5, mul);

	Out.ar(out,
		sig
	);
}).add;
)

(
~synth = Synth(\monosquare, [\freq, 100]);

MIDIdef.noteOn(\noteOn, {|vel, num|
	~synth.set(\freq, num.midicps, \mul, vel.linlin(0, 127, 0, 0.1));
});
)

~synth.free;

(
/*
Poly synth with a square wave.
Additional control over attack, release and pan

Envelope used to release synth on noteOff. Note the gate argument
*/
Env.new([0, 1, 0], [0.05, 2], 'sin', 1).plot;

SynthDef(\polysquare, { |freq=440, mul=0.1, att=0.05, rel=2, gate=1, pan=0,
	out=0|

	var sig, env;

	sig = LFPulse.ar(freq, 0, 0.5, mul);
	env = EnvGen.ar(
		Env.new([0, 1, 0], [att, rel], 'sin', 1),
		gate,
		doneAction: 2
	);

	Out.ar(out,
		Pan2.ar(sig * env, pan);
	);
}).add;
)

(
/*
Need to have a noteOff MIDIdef now.

The noteOn MIDIdef is doing something special, can you work out what it is?
*/
~synths = Array.newClear(128);

MIDIdef.noteOn(\noteOn, {|vel, num|
	~synths[num] = Synth(\polysquare, [
		\freq, 	num.midicps,
		\mul, 	vel.linlin(0, 127, 0, 0.1),
		\pan,	num.linlin(48, 72, -1, 1)
	]);

});

MIDIdef.noteOff(\noteOff, {|vel, num|
	~synths[num].set(\gate, 0);
});
)


/*

To ingrain this stuff, make a new file and try and (roughly) rewrite these
examples from memory.

If you find something tricky to understand, note it down, we will compile a list
of the things people are finding difficult and go through them together.

*/