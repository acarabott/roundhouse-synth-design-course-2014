/* ============================================================ */
/* Multiple Generators                                          */
/* ============================================================ */

/*
So far we have been using one signal generator (SinOsc, LFTri, WhiteNoise) at a
time.

It is very easy to combine multiple generators to create richer sounds
*/

(
SynthDef(\rich, { |freq=440, mul=0.1, att=0.05, rel=1, gate=1, pan=0, out=0|

	var square, sine, tri, mix, env;

	square = 	LFPulse.ar(freq, 0, 0.5, 0);
	sine = 		SinOsc.ar(freq / 2, 0, 1);
	tri = 		LFTri.ar(freq * 4, 0, 1);

	mix = Mix([square, sine, tri].poll);

	env = EnvGen.ar(
		Env.new([0, 1, 0], [att, rel], 'sin', 1),
		gate,
		doneAction: 2
	);

	Out.ar(out,
		Pan2.ar(mix * env * mul, pan);
	);
}).add;
)


(
~synths = Array.newClear(128);

MIDIdef.noteOn(\noteOn, {|vel, num|
	~synths[num] = Synth(\rich, [
		\freq, 	num.midicps,
		\mul, 	vel.linlin(0, 127, 0, 0.1)
	]);

});

MIDIdef.noteOff(\noteOff, {|vel, num|
	~synths[num].set(\gate, 0);
});
)

/*
You can also use Mix.fill to create lots of variations on a generator
*/
(
SynthDef(\fill, { |freq=440, mul=0.1, att=0.01, rel=1, gate=1, pan=0, out=0|
	var n, sig, env;

	n = 7;
	sig = Mix.fill(n, {|i|
		LFSaw.ar(Rand(freq - 3, freq + 3), 0, 1/n);
	});
	env = EnvGen.ar(
		Env.new([0, 1, 0], [att, rel], 'sin', 1),
		gate,
		doneAction: 2
	);

	Out.ar(out,
		Pan2.ar(sig * env * mul, 0);
	);
}).add;
)

(
~synths = Array.newClear(128);

MIDIdef.noteOn(\noteOn, {|vel, num|
	~synths[num] = Synth(\fill, [
		\freq, 	num.midicps,
		\mul, 	vel.linlin(0, 127, 0, 0.1)
	]);

});

MIDIdef.noteOff(\noteOff, {|vel, num|
	~synths[num].set(\gate, 0);
});
)