(
	SynthDef("sc303", { arg out=0, freq=440, wave=0, ctf=100, res=0.2,
		sustain=0, decay=1.0, env=1000, t_gate=0, amp=0.2, clip=0.5;
		var filEnv, volEnv, waves, sig;
		volEnv = EnvGen.ar(Env.new([10e-10, 1, 1, 10e-10], [0.01, sustain, decay], 'exp'), t_gate);
		filEnv = EnvGen.ar(Env.new([10e-10, 1, 10e-10], [0.01, decay], 'exp'), t_gate);
		waves = [Saw.ar(freq, volEnv), Pulse.ar(freq, 0.5, volEnv)];

		sig = RLPF.ar( Select.ar(wave, waves), ctf + (filEnv * env), res);

		sig = sig.clip(0, clip);

		Out.ar(out, sig.dup * amp);
	}).add;

)
p.stop

x.free;
x = Synth("sc303");

(
Tdef(\303, {
	inf.do {
		x.set(
			\freq, (Scale.minor.degrees + 36).midicps.choose,
			\t_gate, 1
		);
		0.15.wait;
	}
}).play;
)

a = EZSlider();

a.action = {|ez|
	x.set(\ctf, ez.value.linexp(0, 1, 20, 5000));
};

x.set(\res, 0.1);

x.free;

x.set(\clip, 0.1)