// Based on the Vocoder class by Joshua Parmenter
(
SynthDef(\vocoder, {|freq=440, in=0, num=56, low=100, high=5000, q=0.02,
	hpf=5000, hpfscal=0.05, outscal=25, gate=1, out=0|

	var mod, hasFreq, car, ratio, cf, filtmod, tracker,
	filtcar, env, sig;

	mod = SoundIn.ar(in);
	// #freq, hasFreq = Tartini.kr(mod);
	// freq = freq.cpsmidi.round(1);
	// freq = freq + 3;
	// freq = freq.midicps;

	car = LFSaw.ar(freq, 0, 0.1);

	sig = Mix.arFill((56 + 1), {|i|
		ratio = ((high / low)**num.reciprocal);
		cf = (ratio**i) * low;
		filtmod = BPF.ar(mod, cf, q);
		tracker = Amplitude.kr(filtmod);
		filtcar = BPF.ar(car, cf, q);

		(outscal * (filtcar * tracker ));
	});

	env = EnvGen.ar(Env.asr(0.8,1, 1.5), gate, doneAction: 2);

	Out.ar(out,
		sig.dup * env
	);
}).add;
)

MIDIIn.connectAll;

~synths = Array.newClear(128);
MIDIdef.noteOn(\vocoderOn, {|vel, num|
	~synths[num] = Synth(\vocoder, [\freq, num.midicps]);
});

MIDIdef.noteOff(\vocoderOff, {|vel, num|
	~synths[num].set(\gate, 0);
});
