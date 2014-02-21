// From the "Emulating Video Game Sounds" recipe, page 78 of
// "Steal This Sound" by Mitchell Sigman
// Adapted by Arthur Carabott

(
SynthDef(\rockit, {|freq=440, detune=2, gate=1, out=0|
	var osc1, osc2, pwm, mix, env;

	// envelope for pulse width
	pwm = EnvGen.kr(Env([0, 0.5, 0], [0.1, 0.3], ['lin', -1]));

	// two oscillators, slightly detuned
	osc1 = LFPulse.ar(freq, 0, pwm);
	osc2 = LFPulse.ar(freq - detune, 0, pwm);

	// mixdown  oscillators
	mix = Mix([osc1, osc2]);

	// amplitude envelope
	env = EnvGen.ar(Env.asr(0.001, 1, 0.05), gate, doneAction:2);
	mix = mix * env;

	Out.ar(out,
		Pan2.ar(mix, 0)
	);

}).add;
)

MIDIIn.connectAll;

~synths = ();
MIDIdef.noteOn(\noteOn, {|vel, num|
	~synths[num] = Synth(\rockit, [\freq, num.midicps]);
});

MIDIdef.noteOff(\noteOff, {|vel, num|
	~synths[num].set(\gate, 0);
});
