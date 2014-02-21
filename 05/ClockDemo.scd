// By Matthew Yee-King
~cl = MykClock.new;
~cl.run;
~cl.add(0, {Synth(\hihat)})

(
SynthDef(\hihat, {

	var c;
	c = WhiteNoise.ar(0.5);

	c = BPF.ar(c, 300, 0.5, 1);

//	c = HPF.ar(c, Line.kr(1, 400, 0.2));
	c = c * Line.kr(1, 0, 0.1, doneAction:2);
	Out.ar([0,1], c);


}).add;
)
Synth(\hihat);
Synth(\kick);

SynthDef(\kick ,{

	var sig = SinOsc.ar(100, 30, 0.4);

	Out.ar([0, 1], sig * Line.kr(0.5, 0, 0.1, doneAction:2));

}).add;


~cl = MykClock.new;
~cl.run;
~cl.add(0, {
	Synth(\hihat);
	},
	[1,1,1,1,1],
	[1,1,0.5,0.1,1]

)

~cl.add(1, {
	Synth(\kick);
	},
	[0.5],
	[1]

)



~cl.add(2, {
	Synth(\fm3, [\freq, ~notes.choose.midicps, \index, rrand(22,2500)])
},
	[(1/3)],
	[0.7]
)

~cl.bpm(140);

~notes = [60, 41, 43, 19];

(
SynthDef("fm3", {

	|freq = 440, mul = 0.1, att = 0.005, rel = 0.3, gate = 1 , index = 100 |

	var env1;

	var carrier,
	    carrier_freq,
	    mod1,
	    mod2,
	    mod1_index,
	    mod2_index,
	    mod1_freq,
	    mod2_freq;

	env1 = EnvGen.ar(
		Env.new([0, 1, 1, 0], [0.015 ,att, rel], ['lin', -2, -3], 2 ),
		gate,
		doneAction: 2
	);


	carrier_freq = freq;
	mod1_index = index;
	mod2_index = index;
	mod1_freq = 150.1;
	mod2_freq = 200;

	mod1 = SinOsc.ar(freq: mod1_freq,
		mul:mod1_index);
	mod2 = SinOsc.ar(freq: mod2_freq,
		mul:mod2_index);

	carrier = SinOsc.ar(carrier_freq+ mod1+mod2, 0, mul);
	carrier = carrier * Line.kr(0.5,0,0.1);

	Out.ar([0, 1], Pan2.ar(carrier));
	}).add;

)

Synth(\fm3);