// By Arthur Carabott, based on Sound on Sound article
(
SynthDef(\axel, {|freq=440, lpfreq=12000, rq=0.2, gate=1, out=0|
	var chorus = LFNoise2.ar(1).range(0.99, 1.01);
	// var chorus = 1;
	var saw1 = LFSaw.ar(freq * chorus, 0, 0.1);
	var saw2 = LFSaw.ar((freq.cpsmidi - 0.1).midicps * chorus, 0, 0.1);
	var tri = LFTri.ar(freq * chorus, 0, 0.1);
	var mix = Mix([saw1, saw2, tri]);
	var lpf = RLPF.ar(mix, lpfreq, rq);
	var env = EnvGen.ar(Env.adsr(0.3, 0.6, 0.5, 0.25), gate, doneAction: 2);

	Out.ar(out,
		Pan2.ar(lpf * env, 0);
	);
}).add;

)

MIDIIn.connectAll;

(
~synths = Array.newClear(128);

MIDIdef.noteOn(\acOn, {|val, num, chan, src|
	// [val, num, chan, src].postln;
	~synths[num] = Synth.before(c, \axel, [
		\freq, num.midicps
	]);
});

MIDIdef.noteOff(\acOff, {|val, num, chan, src|
	// [val, num, chan, src].postln;
	~synths[num].set(\gate, 0);
});

)