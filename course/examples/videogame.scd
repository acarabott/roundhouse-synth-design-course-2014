(
SynthDef(\vg, {|freq=220, mul=0.1, ffreq=1000, rq=1, gate=1, pan=0, bits=8, ds=8, out=0|
	var sig, sample;

	// square wave
	sig = LFCub.ar(freq, 0, 1);
	// band pass filter
	sig = BPF.ar(sig, ffreq, rq);
	// bit crusher,
	sig.trunc(1 / bits);
	// down sampling
	sig = Decimator.ar(sig, SampleRate.ir / ds, bits);
	// volume envelope
	sig = sig * mul.lag(0.01);

	Out.ar(out,
		Pan2.ar(sig, pan);
	);
}).add;
)

x.free;x = Synth(\vg);

MIDIIn.connectAll;

~current = 0;
MIDIdef.noteOn(\noteOnAction, {|vel, num|
	~current = num;
	x.set(\freq, num.midicps, \mul, 0.2);
});

MIDIdef.noteOff(\noteOffAction, {|vel, num|
	if(num == ~current) {
		x.set(\mul, 0);
	}
});
