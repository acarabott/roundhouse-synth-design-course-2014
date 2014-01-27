// Reformatted for the Roundhouse Synth Design course from
// 08091500Acid309 by otophilia
// form SuperCollider/examples folder
(
SynthDef(\kick, {|out=0|
	var env0, env1, env1m, sig;

	env0 =  EnvGen.ar(
		Env([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2
	);
	env1 = EnvGen.ar(Env([110, 59, 29], [0.005, 0.29], [-4, -5]));
	env1m = env1.midicps;

	sig = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m * 1.5, env0);
	sig = sig + SinOsc.ar(env1m, 0.5, env0);

	sig = sig * 1.2;
	sig = sig.clip2(1);

	Out.ar(out, sig.dup);
}).add;

SynthDef(\snare, {|out=0, amp=0.8|
	var env0, env1, env2, env1m, oscs, noise, sig;

	env0 = EnvGen.ar(Env([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]));
	env1 = EnvGen.ar(Env([110, 60, 49], [0.005, 0.1], [-4, -5]));
	env1m = env1.midicps;
	env2 = EnvGen.ar(Env([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

	oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) +
	LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
	oscs = LPF.ar(oscs, env1m * 1.2, env0);
	oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

	noise = WhiteNoise.ar(0.2);
	noise = HPF.ar(noise, 200, 2);
	noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
	noise = noise * env2;

	sig = oscs + noise;
	sig = sig.clip2(1) * amp;

	Out.ar(out, sig.dup);
}).add;

SynthDef(\clap, {|out=0, amp = 0.5|
	var env1, env2, sig, noise1, noise2;

	env1 = EnvGen.ar(Env(
		[0, 1, 0, 1, 0, 1, 0, 1, 0],
		[0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03],
		[0, -3, 0, -3, 0, -3, 0, -4]
	));
	env2 = EnvGen.ar(Env([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	sig = noise1 + noise2;
	sig = sig * 2;
	sig = sig.softclip * amp;

	Out.ar(out, sig.dup);
}).add;

SynthDef(\hat, {|out=0, amp=0.3|
	var env1, env2, sig, oscs1, noise, n, n2;

	n = 5;
	thisThread.randSeed = 4;

	env1 = EnvGen.ar(Env([0, 1.0, 0], [0.001, 0.2], [0, -12]));
	env2 = EnvGen.ar(
		Env([0, 1.0, 0.05, 0], [0.002, 0.05, 0.03], [0, -4, -4]),
		doneAction:2
	);

	oscs1 = Mix.fill(n, {|i|
		SinOsc.ar(
			(i.linlin(0, n-1, 42, 74) + rand2(4.0)).midicps,
			SinOsc.ar((i.linlin(0, n-1, 78, 80) + rand2(4.0)).midicps, 0.0, 12),
			1/n
		)
	});

	oscs1 = BHiPass.ar(oscs1, 1000, 2, env1);
	n2 = 8;
	noise = WhiteNoise.ar;
	noise = Mix.fill(n2, {|i|
		var freq;
		freq = (i.linlin(0, n-1, 40, 50) + rand2(4.0)).midicps.reciprocal;
		CombN.ar(noise, 0.04, freq, 0.1)
	}) * (1/n) + noise;
	noise = BPF.ar(noise, 6000, 0.9, 0.5, noise);
	noise = BLowShelf.ar(noise, 3000, 0.5, -6);
	noise = BHiPass.ar(noise, 1000, 1.5, env2);

	sig = noise + oscs1;
	sig = sig.softclip;
	sig = sig * amp;

	Out.ar(out, sig.dup);
}).add;

SynthDef(\acid, {|out=0, gate=1, pitch=50, amp=0.1|
	var env1, env2, sig;
	pitch = Lag.kr(pitch, 0.12 * (1-Trig.kr(gate, 0.001)) * gate);
	env1 = EnvGen.ar(
		Env([0, 1.0, 0, 0], [0.001, 2.0, 0.04], [0, -4, -4], 2), gate, amp
	);
	env2 = EnvGen.ar(Env.adsr(0.001, 0.8, 0, 0.8, 70, -4), gate);
	sig = LFPulse.ar(pitch.midicps, 0.0, 0.51, 2, -1);

	sig = RLPF.ar(sig, (pitch + env2).midicps, 0.3);
	sig = sig * env1;

	sig = (sig * 7).clip2(amp);

	Out.ar(out, sig.dup);
}).add;
)


Synth(\kick);
Synth(\snare);
Synth(\clap);
Synth(\hat);


(

	~dseq = [
		[1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0],
		[0,0,0,0, 4,0,0,2, 0,0,0,0, 4,0,0,0],
		[0,0,0,0, 0,0,0,0, 0,0,0,0, 4,0,0,0],
		[1,2,4,0, 1,0,4,0, 1,2,4,2, 1,0,4,2],
		[1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0]
		].flop;

	~bseq = [
		[1,1,1,1, 1,1,1,1, 0,1,0,1, 1,1,1,0],
		[1,1,0,2, 1,1,0,0, 2,0,2,0, 1,2,0,4],
		[-5,22,7,7, 15,13,-9,19, 15,-5,17,19, -5,7,-2,19] + 48
		].flop;

	~pnt = 0;
	~shf = 0.16;
	~bpm = 130;

	~clock = TempoClock(~bpm/60);

	~clock.sched(0.0, {
		var delta, bass;
		delta = if(~pnt%2 == 0){1/4 * (1+~shf)}{1/4 * (1-~shf)};

		s.bind{
			if(~pnt == 0){
				~group = Group.new;
				~acid = Synth.head(~group, "acid", [\gate, 0]);
			};

			~dseq.wrapAt(~pnt).do{|x, i|
				switch(i,
					0, { if( x>0 ){ Synth.head(~group, \kick) } },
					1, { if( x>0 ){ Synth.head(~group, \snare, [\amp, (x/4).squared*0.7]) } },
					2, { if( x>0 ){ Synth.head(~group, \clap, [\amp, (x/4).squared*0.5]) } },
					3, { if( x>0 ){ Synth.head(~group, \hat, [\amp, (x/4).squared*0.32]) } }
				);
			};

			bass = ~bseq.wrapAt(~pnt);
			~acid.set(\pitch, bass[2]);
			if(bass[0]==1){ ~acid.set(\gate, 1) };
		};
		if(bass[1]>0){ ~clock.sched(delta * bass[1]/4 * 0.99, { s.bind{ ~acid.set(\gate, 0) } }) };

		~pnt = ~pnt+1;
		delta;
	});
);

});