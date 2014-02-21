/* ============================================================ */
/* Machine Listening                                            */
/* ============================================================ */

/*
Machine listening is a broad field that aims to have computers listen
intelligently: being able to pick out features of audio at the same level, or
beyond that of humans.

Warning: it is more succesful in some areas than others!
*/

/*
---------------
Onset Detection
---------------

Onset detectors are used to detect the start (or onset) of musical events.
Common onset detectors tend to work well for percussive sounds, but not so well
with instruments with a slow attack (e.g. bowed strings, wind instruments).

*/

/*
This synth uses Onsets
*/
SynthDef(\onsets, { |in=0, thresh=0.5, out=0|
	var sig = SoundIn.ar(in);
	var fft = FFT(LocalBuf(512, 1), sig);
	var onsets = Onsets.kr(fft, thresh);

	var sine = SinOsc.ar(440, 0, 0.1 * Decay.kr(onsets, 1));

	Out.ar(out,
		sine.dup
	);
}).add;

x = Synth(\onsets, [\in, 0]);

// adjust this if you're not getting triggers

x.set(\thresh, 0.2);

/*
We can also send these Onset triggers back to the SuperCollider programming
language (SCLang) and use them to do whatever we want. This is often a more
flexible way of working.

This requires not only a SynthDef, but also an OSCdef to receive the triggers
*/

(
SynthDef(\onsetSend, { |in=0, thresh=0.5, out=0|
	var sig = SoundIn.ar(in);
	var fft = FFT(LocalBuf(512, 1), sig);
	var onsets = Onsets.kr(fft, thresh);

	SendReply.kr(onsets, '/od', [onsets]);
}).add;

OSCdef(\onsetRecieve, {|msg, time, addr, recvPort|
	["ouch", "oww", "why?", "stop hitting me", "shush", "stop clapping",
		"quiet now"].choose.speak;


}, '/od');
)

x = Synth(\onsetSend, [\in, 0]);











/*
-------------------
Amplitude Following
-------------------

You can track the amplitude of any signal, and use it to control anything else.
It's a bit like a side chain, for anything.
*/

/*
Here's an example that uses the amplitude to control the decay time of a delay
*/
(
SynthDef(\ampdel, { |in=0, att=0.01, rel=0.01, out=0|
	var sig = 		SoundIn.ar(in);
	var amp = 		Amplitude.kr(sig, att, rel);
	var del = 		CombC.ar(sig, 0.5, 0.2, amp * 4);


	Out.ar(out,
		Mix([sig, del]).dup;
	);
}).add;
)

x = Synth(\ampdel, [\in, 0]);
x.set(\rel, 1);


/*
Here the output of Amplitude is written to a Control bus, which can then be used
to control synths created later.
*/

(
SynthDef(\amp, { |in=0, att=0.01, rel=0.01, out=0|
	var sig = SoundIn.ar(in);
	var amp = Amplitude.kr(sig, att, rel);

	Out.kr(out, amp);
}).add;

SynthDef(\tri, {|freq=440, mulbus=0.1, gate=1, out=0|
var mul = In.kr(mulbus) * 0.1;
var sig = LFTri.ar(freq, 0, mul);
var env = EnvGen.ar(
	Env.new([0, 1, 0.05, 0.8, 0], [1, 0.05, 0.01, 0.1], \sin, 1),
	gate,
	doneAction: 2
);

Out.ar(out,
	sig * env
);
}).add;
)


)

~mulbus = Bus.control(s, 1);
x = Synth(\amp, [\in, 0, \out, ~mulbus, \att, 5, \rel, 5]);


MIDIIn.connectAll;

(
~synths = Array.newClear(128);
MIDIdef.noteOn(\noteOnAction, {|vel, num|
	~synths[num] = Synth.after(x, \tri, [\freq, num.midicps, \mulbus, ~mulbus]);
});

MIDIdef.noteOff(\noteOffAction, {|vel, num|
	~synths[num].set(\gate, 0);
});

);













/*
---------------
Pitch Detection
---------------


Tartini and Pitch will perform pitch detection on mono sounds


*/
(
SynthDef(\pitchpoll, { |in=0, out=0|
	var sig, freq, hasFreq;

	sig = SoundIn.ar(in);
	# freq, hasFreq = Tartini.kr(sig);
	// Tartini outputs two values, the frequency, and a confidence level

	freq.poll;

}).add;
)

// this doesn't produce any sound, just prints out the current frequency
x = Synth(\pitchpoll, [\in, 0]);



/*
Example from the help files that combines Amplitude and Tartini to control a
synth
*/
(
SynthDef(\pitchSynth, { |in=0, out=0|
	var sig, sound, amp, freq, hasFreq;

	sig = SoundIn.ar(in);
	amp = Amplitude.kr(sig, 1, 1);
	# freq, hasFreq = Tartini.kr(sig);

	// autotune! convert freq to midi, round it, then convert back
	freq = freq.cpsmidi.round(1).midicps;

	sound = Mix.new(
		VarSaw.ar(freq * [0.5, 1, 2], 0, LFNoise1.kr(0.3, 0.1, 0.1), amp)
	);

	6.do {
		sound = AllpassN.ar(sound, 0.040, [0.04.rand, 0.04.rand], 2)
	};

	Out.ar(out,
		sound.dup;
	);

}).add;
)

x = Synth(\pitchSynth, [\in, 0]);



/*
Other UGens to check out:
- BeatTrack: Beat detector
- Chromagram: Energy at different octave intervals
*/