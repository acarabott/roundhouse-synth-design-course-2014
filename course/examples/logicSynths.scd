FreqScope();

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

SynthDef(\esp, {|freq=440, tmul=1, smul=1, rmul=1, r1mul=1, r2mul=1, mul=0.1,
	nmul=1, out=0|
	var tri = LFTri.ar(freq, 0, tmul);
	var saw = LFSaw.ar(freq, 0, smul);
	var rect = LFPulse.ar(freq, 0, 0.5, rmul);
	var rect1 = LFPulse.ar(freq / 2, 0, 0.5, 1);
	var rect2 = LFPulse.ar(freq / 4, 0, 0.5, 1);
	var noise = WhiteNoise.ar(nmul);
}).add;
