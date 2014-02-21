// Based on Sound on Sound Synth Secrets Part 25
// by Arthur Carabott
(
SynthDef(\brass, {|freq=220, detune1=1, detune2=0.5, ffreq=12000, rq=0.4,
	mul=0.1, pan=0, gate=1,out=0|

	var sig, env, fenv;

	sig = Mix([freq, freq - detune1, freq + detune2, freq / 2].collect {|freq|
		LFSaw.ar(freq);
	});

	fenv = EnvGen.kr(Env([ffreq, 0], [0.06], \sin));

	sig = RHPF.ar(sig, fenv, rq);

	env = EnvGen.ar(Env.asr(0.01, 1, 0.1), gate, doneAction:2);

	Out.ar(out,
		Pan2.ar(sig * env, pan);
	);
}).add;
)

MIDIIn.connectAll;

~synths = ();
MIDIdef.noteOn(\noteOn, {|vel, num|
	~synths[num] = Synth(\brass, [\freq, num.midicps, \ffreq, 2000]);
});

MIDIdef.noteOff(\noteOff, {|vel, num|
	~synths[num].set(\gate, 0);
});

