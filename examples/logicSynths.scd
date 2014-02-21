// Emulations of two synths from Logic Pro X, by Arthur Carabott

SynthDef(\esm, {|freq=440, mix=0.5, glide=0, cutoff=20000, rq=1, fdec=0, fint=1,
	vel=1, fvel=1, t_gate=1, vdec=1, vvel=0, od=0, mul=0.1, pan=0, out=0|
	var sig, saw, rect, fstart, fenv, vstart, venv;

	freq = freq.lag(glide);

	// oscillators
	saw = LFSaw.ar(freq, 0, 1);
	rect = LFPulse.ar(freq, 0, 0.5, 1);
	sig = Mix([saw * (1-mix), rect * mix]);

	// filter
	fstart = vel.linlin(0, fvel, 0, fint).linexp(0, 1, cutoff, 20000);
	fenv = EnvGen.kr(Env([fstart, fstart, cutoff], [0.001, fdec]), t_gate);
	sig = LPF.ar(sig, fenv, rq);

	// volume env
	vstart = vel.linlin(0, vvel.max(10e-1), 0, 1);
	venv = EnvGen.ar(Env([vstart, vstart, 0], [0.01, vdec], \cub), t_gate);
	sig = sig * venv;

	// distortion
	sig = sig * od.linlin(0, 1, 1, 100).clip2(mul);

	Out.ar(out,
		Pan2.ar(sig, pan);
	)
}).add;

x.free;x = Synth(\esm, [\cutoff, 2000, \fdec, 3, \fint, 1, \od, 0.5, \glide, 0.5]);

MIDIIn.connectAll;

MIDIdef.noteOn(\noteOnAction, {|vel, num|
	x.set(
		\freq, num.midicps,
		\vel, vel.linlin(0, 127, 0, 1),
		\t_gate, 1
	);
});

SynthDef(\esp, {|freq=440, tmul=0, smul=1, rmul=0, r1mul=0.84, r2mul=1, nmul=0,
	ffreq=20000, rq=1, att=4.67, dec=7, sus=0.115, rel=1.35, gate=1, od=1,
	chorus=0, mul=0.1, pan=0, out=0|

	// Signal generators
	var vfreq = freq + vlfo;
	var tri = LFTri.ar(vfreq, 0, tmul / 6);
	var saw = LFSaw.ar(vfreq, 0, smul / 6);
	var rect = LFPulse.ar(vfreq, 0, 0.5, rmul / 6);
	var rect1 = LFPulse.ar(vfreq / 2, 0, 0.5, r1mul / 6);
	var rect2 = LFPulse.ar(vfreq / 4, 0, 0.5, r2mul / 6);
	var noise = WhiteNoise.ar(nmul / 6);
	// combined
	var mix = Mix([tri, saw, rect, rect1, rect2, noise]);

	// TODO lfo left off for now as requires second synth + bus

	// filter
	var filt = RLPF.ar(mix, ffreq, rq);

	// overdrive
	var overdrive = (filt * od).clip2(1);

	// envelope
	var env = EnvGen.ar(Env.adsr(att, dec, sus, rel), gate, doneAction: 2);

	// chorus
	var numChorus = 3;
	var chorusSig = Mix.fill(numChorus, {
		var chorusFreq = rrand(2.5, 2.9);
		var maxdel = rrand(0.0005, 0.001);
		var chorusDel = SinOsc.kr(chorusFreq, 0, 0.5, 0.5);

		DelayC.ar(filt, maxdel, chorusDel * maxdel) / numChorus;
	});

	var sig = Mix([overdrive, chorusSig * chorus]) * env * mul;

	Out.ar(out,
		Pan2.ar(sig, pan)
	);

}).add;


MIDIIn.connectAll;

~synths = ();
MIDIdef.noteOn(\noteOnAction, {|vel, num|
	~synths[num] = Synth(\esp, [
		\freq, num.midicps,
		\tmul, 1,
		\smul, 1,
		\rmul, 1,
		\r1mul, 0.5,
		\r2mul, 0.5,
		\nmul, 0.1,
		\chorus, 1,
		\od, 6
	]);
});
MIDIdef.noteOff(\noteOffAction, {|vel, num|
	~synths[num].set(\gate, 0);
});


// speed: 	0.02 - 20
// vib:		1 - freq * 0.8
// cutoff:
	// no key track:	1100 - 25000
	// 1/3 key track:
// envelope
	// a: 0 - 10
	// d: 0 - 10
	// s: 0 - 1
	// r: 0 - 10


// 1/3, log scale

// fund 	filt
// 110		640
// 220		800
// 440		1000
// 880		1200


// 2/3

// 110		360
// 220		560
// 440		860
// 880		1320

// 3/3

// 110		190
// 220		380
// 440		760
// 880		1500
s.mute;