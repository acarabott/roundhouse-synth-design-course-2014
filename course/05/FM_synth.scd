// By Matthew Yee-King
(
SynthDef("fm3", {

	|freq = 440, mul = 0.1, att = 0.005, rel = 0.3, gate = 1 |

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
	mod1_index = 100;
	mod2_index = 99;
	mod1_freq = 150.1;
	mod2_freq = 200;

	mod1 = SinOsc.ar(freq: mod1_freq,
		mul:mod1_index);
	mod2 = SinOsc.ar(freq: mod2_freq,
		mul:mod2_index);

	carrier = SinOsc.ar(carrier_freq+ mod1+mod2, 0, mul);

	Out.ar([0, 1], Pan2.ar(carrier * env1, 0));
}).add();
)

~fm = Synth(\fm3,[\freq, 600]);

MIDIIn.connectAll;

(
~synths = Array.newClear(128);


MIDIdef.noteOn(\noteOn, { |vel, num|

	~synths[num] = Synth(\fm3, [
		\freq, num.midicps,
		\mul, vel.linlin(0, 127, 0, 0.1)
		]
	);
	}
);

MIDIdef.noteOff(\noteOff, {|vel, num|

	~synths[num].set(\gate, 0);

});

)
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


SynthDef(\snare ,{}).add;




