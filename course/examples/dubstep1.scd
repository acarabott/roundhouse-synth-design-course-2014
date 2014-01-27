(
SynthDef(\wobblebass, {|freq=100, wob=3, mul=0.1, out=0|
	var sig, wobble;

    freq = freq.lag(0.1);
	wobble = LFSaw.kr(wob);
	sig = LFSaw.ar(freq * [0.99, 1, 1.01, 0.5, 0.51]).sum;
	sig = RLPF.ar(sig, wobble.exprange(40, 5000));
    sig = Mix([sig, SinOsc.ar(freq / 2, 0, 1)]);
    sig = Normalizer.ar(sig);
    sig = sig + BPF.ar(sig, 2000, 2);
    sig = Decimator.ar(sig, 20000, 8);
    sig = (sig * 5).tanh;
	sig = sig + GVerb.ar(sig, 10, 0.1, 0.7, mul:0.3);

	Out.ar(out,
		sig.dup * mul
	);
}).add;
)


x = Synth(\wobblebass, [\wob, 0]); // no wobble
x.set(\wob, 3); // give it some wob

MIDIIn.connectAll;

MIDIdef.noteOn(\noteOn, {|vel, num|
    // new wobble with every note
	x.set(\freq, num.midicps, \wob, [3, 4, 6].choose);
});