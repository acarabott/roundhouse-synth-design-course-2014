// From the Kraftwerk "Spacelab" example in SuperCollider/examples
// by jy

(
SynthDef(\res, { | out=0, gate=1, freq=440, ffreq=1500|
	var aEnv, osc, flt;
	aEnv = EnvGen.kr(Env.perc(0, 0.7), gate, doneAction: 2);
	osc = Mix([Saw.ar(freq), Pulse.ar(freq / 2, 0.5)]);
	flt = RLPF.ar(osc, ffreq, 0.1, aEnv);
	Out.ar(out, Pan2.ar(flt, 0));
}).add;

SynthDef(\poly, { | out=0, gate=1, freq=440 |
	var aEnv, fEnv, osc1, osc2, flt;
	aEnv = EnvGen.kr(Env.asr(0.2, 1, 0.1), gate, doneAction: 2);
	fEnv = EnvGen.kr(Env.asr(7, 1, 0.2), levelScale: 12000);
	osc1 = Pulse.ar(freq * [1, 1.007], LFCub.kr(2, 0, 0.3, 0.5));
	osc2 = Pulse.ar(freq / 2, 0.3);
	flt = RLPF.ar(osc1 + osc2, fEnv, 0.9, aEnv);
	Out.ar(out, flt);
}).add;

SynthDef(\solo, { | out=0, gate=1, freq=440 |
	var aEnv, fEnv, osc, flt;
	aEnv = EnvGen.kr(Env.asr(0.2, 1, 2), gate);
	fEnv = EnvGen.kr(Env.adsr(0.4, 1.2, 0.7, 2), gate, 800);
	osc = Saw.ar(Lag.kr(freq, 0.1) * [1, 1.005]);
	flt = LPF.ar(osc, fEnv + 600, aEnv);
	Out.ar(out, flt);
}).add;

SynthDef(\string, { | out=0, gate=1, freq=1000 |
	var aEnv, osc, flt;
	aEnv = EnvGen.kr(Env.asr(0.2, 1, 0.5), gate, doneAction: 2);
	osc = Saw.ar([
		LFCub.kr(0.3, Rand(0, 1), freq * 0.003, freq),
		freq,
		LFCub.kr(0.7, Rand(0, 1), freq * 0.001, freq)
	]);
	flt = LPF.ar(osc, 1500, aEnv);
	Out.ar(out, flt);
}).add;

SynthDef(\bass, { | out=0, gate=1, freq=440 |
	var aEnv, fEnv, osc, flt;
	aEnv = EnvGen.kr(Env.asr(0, 1, 1), gate, doneAction: 2);
	fEnv = EnvGen.kr(Env.perc(0, 3), levelScale: 6000);
	osc = Mix([Saw.ar(freq * [1, 1.005]), Pulse.ar(freq / 2, 0.5)]);
	flt = LPF.ar(osc, fEnv + 100, aEnv);
	Out.ar(out, flt);
}).add;

SynthDef(\intro, { | out=0 |
	var trig, div, freq, oct, reps, env, osc, flt;
	oct = [0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3];
	trig = Impulse.kr(EnvGen.kr(Env([1.75, 120], [30], 6.5)));
	div = PulseDivider.kr(trig, 16, 16);
	reps = PulseCount.kr(div);
	env = EnvGen.kr(Env.perc(0, 3), trig, 0.5);
	freq = (Stepper.kr(trig, div, 42, 74, 2, 42) + (12 * Select.kr(reps, oct))).midicps;
	osc = Saw.ar(freq * [1, 1.01], env);
	flt = RLPF.ar(osc, freq * 2, 0.7);
	Out.ar(out, flt);
}).add;
)


Synth(\bd);
Synth(\sd);
Synth(\hat);


Synth(\res, [\freq, 84.midicps]);

~poly = Synth(\poly, [\freq, 50.midicps]);
~poly.set(\gate, 0);

~solo = Synth(\solo, [\freq, 84.midicps]);
~solo.set(\gate, 0);

~string = Synth(\string, [\freq, 40.midicps]);
~string.set(\gate, 0);

~bass = Synth(\bass, [\freq, 50.midicps]);
~bass.set(\gate, 0);

~into = Synth(\intro);
~intro.free;