(
SynthDef(\303, { arg out=0, freq=440, wave=0, ctf=100, res=0.2, slide=0, lag=0.1,
	sustain=1, decay=1.0, env=1000, t_gate=1, amp=0.2, clip=5, mul=0.1;

	var filEnv, volEnv, waves, sig;
	// volume envelope
	volEnv = EnvGen.ar(Env.new([10e-10, 1, 1, 10e-10], [0.01, sustain, decay], 'exp'), t_gate);
	// filter envelope
	filEnv = EnvGen.ar(Env.new([10e-10, 1, 10e-10], [0.01, decay], 'exp'), t_gate);
	// optional lag on frequency
	lag = Select.kr(slide, [0.05, lag]);
	// oscillators
	waves = [Saw.ar(freq.lag(lag), volEnv), Pulse.ar(freq, 0.5, volEnv)];
	// resonant
	sig = RLPF.ar( Select.ar(wave, waves), ctf + (filEnv * env), res);
	//distortion
	sig = (sig * clip).clip2(mul);

	Out.ar(out,
		sig.dup
	);
}).add;

)

x.free; x = Synth(\303, [\ctf, 350, \res, 0.1, \clip, 4, \mul, 0.4, \decay, 4, \sustain, 1, \lag, 0.135]);

TempoClock.tempo = 112/60
(
Tdef(\303, {
	var freqs = ([-5, 22, 7, 7, 15, 13, -9, 19, 15, -5, 17, 19, -5, 7, -2, 19] + 48).midicps;
	var slides = [0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1];

	inf.do {
		freqs.do {|freq, i|

			x.set(
				\freq, freq,
				\slide, slides[i],
				\t_gate, 1
			);
			0.25.wait;
		}
	}
}).play;
)

a = EZSlider();

a.action = {|ez|
	x.set(\ctf, ez.value.linexp(0, 1, 20, 5000).postln);
};
