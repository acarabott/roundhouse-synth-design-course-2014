//s.boot

{
    var trig, note, son, sweep;

    trig = CoinGate.kr(0.5, Impulse.kr(2));

    note = Demand.kr(trig, 0, Dseq((22,24..44).midicps.scramble, inf));

    sweep = LFSaw.ar(Demand.kr(trig, 0, Drand([1, 2, 2, 3, 4, 5, 6, 8, 16], inf))).exprange(40, 5000);

    son = LFSaw.ar(note * [0.99, 1, 1.01]).sum;
    son = LPF.ar(son, sweep);
    son = Normalizer.ar(son);
    son = son + BPF.ar(son, 2000, 2);

    //////// special flavours:
    // hi manster
    son = Select.ar(TRand.kr(trig: trig) < 0.05, [son, HPF.ar(son, 1000) * 4]);
    // sweep manster
    son = Select.ar(TRand.kr(trig: trig) < 0.05, [son, HPF.ar(son, sweep) * 4]);
    // decimate
    son = Select.ar(TRand.kr(trig: trig) < 0.05, [son, son.round(0.1)]);

    son = (son * 5).tanh;
    son = son + GVerb.ar(son, 10, 0.1, 0.7, mul: 0.3);
    son.dup * 0.1
}.play


(
SynthDef(\bigbass, {|freq=100, wob=3, mul=0.1, out=0|
	var sig, wobble;

	wobble = LFSaw.kr(wob);
	sig = LFSaw.ar(freq * [0.99, 1, 1.01, 0.5, 0.51]).sum;
	sig = RLPF.ar(sig, wobble.exprange(40, 5000));
	sig = Normalizer.ar(sig);
	sig = sig + BPF.ar(sig, 2000, 2);
	sig = Decimator.ar(sig, 20000, 8);
	sig = (sig * 5).tanh;
	// sig = sig + GVerb.ar(sig, 10, 0.1, 0.7, mul:0.3);

	Out.ar(out,
		sig.dup * mul
	);
}).add;
)


x.free;x = Synth(\bigbass, [\wob, 3]);
x.set(\wob, 8);

MIDIIn.connectAll;

MIDIdef.noteOn(\noteOn, {|vel, num|
	x.set(\freq, num.midicps, \wob, [6, 8].choose);
});
