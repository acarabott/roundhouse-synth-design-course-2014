// By James Harkins ont he sc-users list

(
SynthDef(\808, {|out=0|
	var sig = LPF.ar(Ringz.ar(Impulse.ar(0), 60, 1), 500);
	var cmp = CompanderD.ar(sig, -20.dbamp, 1, 0.3, 0.003, 0.08);

	cmp = cmp * (10.dbamp);
	// cmp = sig;
	Out.ar(out,
		cmp.dup
	);
}).add;
)

(
~routine = {
	inf.do {
		Synth(\808);
		0.5.wait;
	};
}).fork;
)