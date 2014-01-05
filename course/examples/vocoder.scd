(
SynthDef(\vocoder, {|freq=440, in=0, num=56, low=100, high=5000, q=0.02, hpf=5000,
	hpfscal=0.05, outscal=25, out=0|

	var mod, hasFreq, car, ratio, cf, filtmod, tracker,
	filtcar, sig;

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

	Out.ar(out,
		sig.dup
	);
}).add;
)


x.free;x = Synth(\vocoder);


MIDIIn.connectAll;

MIDIdef.noteOn(\vocoder, {|val, num, chan, src|
	x.set(\freq, num.midicps);
});


x.set(\freq, 60.midicps)

x.free

x = {|freq=440| Vocoder.ar(Saw.ar(freq,1),SoundIn.ar(1),56).dup}.play;