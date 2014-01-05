(

SynthDef(\wobble, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	sig1 = LFSaw.ar(freq * 1 + (0.04 * [1,-1]));
	sig2 = LFSaw.ar(freq * 0.99 );
	sig3 = LFSaw.ar(freq * 1 );
	sig = sig1 + sig2 + sig3;
	sig = (sig*50).tanh;
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:doneAction);
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;

~bus = Bus.audio(s,2);
Pdef(\wobble).quant=4;
Ndef(\lfo1).quant=4;
Ndef(\fx).quant=4;
);

(
Pdef(\wobble).play;
Ndef(\fx).play;
Pdef(\wobble, Pbind(
	\instrument, \wobble,
	\out, ~bus,
	\freq, Pseq([50,60,40],inf) + [0,1],
	\legato, 1,
	\dur, Pseq([1/4,1/8,1/8]*8,inf);
));

Ndef(\fx, { arg ffreq=300, rq=0.3, choose=0, freqshift=40, time=2, minrate=0.7, curve=(-1);
	var in = In.ar(~bus, 2);
	var sig;
	var sig1,sig2,sig3,sig4,sig5;
	var buf = LocalBuf(2*s.sampleRate, 2);
	var rate;
	var choosetrig;
	sig = in;

	sig1 = RLPF.ar(sig, ffreq, rq);

	choosetrig = choose > 0;
	RecordBuf.ar(sig1, buf, loop:1, trigger:choosetrig);
	rate = EnvGen.kr(Env([1,1,minrate],[0,time], curve), choosetrig);
	sig2 = PlayBuf.ar(2, buf, rate, choosetrig, loop:1);

	sig = Select.ar(choose, [sig1, sig2]);
	sig;
});

Ndef(\fx).put(1, \set -> Pbind(
	\choose, Pseq([
		0,0,0,0,
		0,0,0,1,
	],inf).stutter(4),
	\time, 2,
	\dur, 1/2,
));

Ndef(\fx).map(\ffreq, Ndef(\lfo1));

Ndef(\lfo1, { arg freq=4, base=2100, choose=0, loval=5, hival=1000, time=1;
	Select.kr(choose, [
		SinOsc.kr(freq).range(5,base),
		Sweep.kr(Impulse.kr(1/time), 1/time) * base + 50,
	])
});


Ndef(\lfo1).put(1, \set -> Pbind(
	\freq, Pseq([
		4,4,4,8,
		0,0,0,0,
		8,8,4,4,
		0,0,0,0,

		4,6,4,8,
		0,0,0,0,
		8,8,4,4,
		0,0,0,0,
	],inf),
	\choose, Pseq([
		0,0,0,0,
		1,1,1,1,
		0,0,0,0,
		1,1,1,1,
	],inf),
	\base, Pseq([1000,1500,5000,2000],inf).stutter(4) + Pseq([0,-500,0,500],inf),
	\time, Pseq([1,1,1,2],inf).stutter(4),
	\dur, 1/2,
));
);