(
SynthDef(\bass, {|freq=100, mul=0.1, submul=0.1, ffreq=12000, out=0|
	var sig = VarSaw.ar(freq, 0, 0.5, mul);
	var sub = SinOsc.ar(freq / 2, 0, submul);
	var mix = Mix([sig, sub]);
	var crush = Decimator.ar(mix, 20000, 8);
	var filt = MoogLadder.ar(crush, ffreq, 0.05);

	Out.ar(out,
		filt.dup
	);
}).add;
);

x = Synth(\bass);

MIDIIn.connectAll;
MIDIdef.noteOn(\noteOn, {|vel, num|
	x.set(\freq, num.midicps);
});


(
SynthDef(\wobblebass, {|wob=3, freq=100, smul=1, submul=1, ffreq=12000, mul=0.1, out=0|
	var wobble, sig, sub, mix, crush, filt;
	wobble = SinOsc.kr(wob);
	freq = freq.lag(0.2);
	sig = VarSaw.ar(freq, 0, 0.5, smul * wobble);
	sub = SinOsc.ar(freq / 2, 0, submul * wobble);
	mix = Mix([sig, sub]);
	crush = Decimator.ar(mix, wobble.abs.range(10000, 20000), wobble.abs.range(2, 4));
	wobble.abs.poll;
	filt = MoogLadder.ar(crush, wobble.abs.range(freq, 25000), 0.05);
	filt = filt * mul;
	Out.ar(out,
		filt.dup
	);
}).add;
)

x.free;x = Synth(\wobblebass, [\wob, 1.5, \ffreq, 5000]);
x.set(\wob, 2);

MIDIIn.connectAll;

MIDIdef.noteOn(\noteOn, {|vel, num|
	x.set(\freq, num.midicps);
});
