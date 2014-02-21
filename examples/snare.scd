// Based on Sound on Sound Synth Secrets 35
// by Arthur Carabott
SynthDef(\snare, { |sfreq=1500, out=0|
	var tri = Mix([LFTri.ar([111, 175, 224])]) * 0.5;
	var sine = Mix([SinOsc.ar([330, 180])]) * 0.5;
	var env = EnvGen.ar(Env.perc(0.01, 0.2), doneAction:2);
	var snares = WhiteNoise.ar(1);
	var snareEnv = EnvGen.ar(Env.perc(0.01, 0.2));

	snares = HPF.ar(snares, sfreq);
	snares = snares * snareEnv;

	Out.ar(out,
		Mix([tri, sine, snares]) * env
	);

}).add;


Synth(\snare, [\sfreq, 1500]);