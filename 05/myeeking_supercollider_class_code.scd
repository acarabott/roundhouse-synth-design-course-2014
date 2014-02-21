// By Matthew Yee-King

s = Server.local.boot;
{SinOsc.ar(220)}.play;

// John Chowning 1973 ish??
SynthDef("fm", {
	var c, mod, mod_index, mod_freq;
	mod_index = MouseY.kr(0, 500);
	mod_freq = MouseX.kr(25, 800);
	mod = SinOsc.ar(
		freq:mod_freq,
		mul:mod_index);
	//lfo.poll;
	c = SinOsc.ar(200 + mod, mul:0.1);
	//c = c * Line.kr(1, 0, 0.5, doneAction:2);
	Out.ar([0, 1], c);
}).add();


SynthDef("fm2", {
	var c, mod, mod2, mod_index, mod_freq;
	//mod_index = MouseY.kr(0, 500);
	//mod_freq = MouseX.kr(25, 800);
	mod_index = LFDNoise1.kr(0.25).range(1.0, 500.0);
	mod_freq = LFDNoise1.kr(0.25).range(25, 800);
	mod = SinOsc.ar(
		freq:mod_freq,
		mul:mod_index);
	//lfo.poll;
	mod2 = SinOsc.ar(
		freq:125,
		mul:250);
	c = SinOsc.ar(200 + mod + mod2, mul:0.1);
	//c = c * Line.kr(1, 0, 0.5, doneAction:2);
	Out.ar([0, 1], c);
}).add();

~fm = Synth("fm2");
~fm.free;


SynthDef("fm3", {arg freq = 440, index = 100;
	var carrier,
	    carrier_freq,
	    mod1,
	    mod2,
	    mod1_index,
	    mod2_index,
	    mod1_freq,
	    mod2_freq;

	carrier_freq = freq;
	mod1_index = index;
	mod2_index = index;
	mod1_freq = 150.1;
	mod2_freq = 200;

	mod1 = SinOsc.ar(freq: mod1_freq,
		mul:mod1_index);
	mod2 = SinOsc.ar(freq: mod2_freq,
		mul:mod2_index);

	carrier = SinOsc.ar(freq:carrier_freq+ mod1+mod2);
	Out.ar([0, 1], carrier * Line.kr(0.25, 0, 0.1, doneAction:2));
}).add();


Synth("fm3");

SynthDef("hihat", {
	var c;
	c = WhiteNoise.ar(0.5);
	c = c * Line.kr(1, 0, 0.1, doneAction:2);
	Out.ar([0, 1], c);
}).add();

SynthDef("hihat2", {
	var c;
	c = WhiteNoise.ar(0.5);
	c = HPF.ar(c, Line.kr(200, 5000, 0.2) );
	c = c * Line.kr(1, 0, 0.1, doneAction:2);
	Out.ar([0, 1], c);
}).add();

Synth("hihat");
Synth("hihat2");

SynthDef("kick",{
	var c;
	c = SinOsc.ar(Line.kr(300, 30, 0.1));
	Out.ar([0, 1], c * Line.kr(1, 0, 1.0, doneAction:2));
}).add();

Synth("kick");

// snare is like the hihat but with a
SynthDef("snare", {
	var c;
	c = WhiteNoise.ar(0.5);
	c = HPF.ar(c, Line.kr(1, 1000, 0.2) );
	c = c + SinOsc.ar(300, mul:0.5);
	c = c * Line.kr(1, 0, 0.3, doneAction:2);
	Out.ar([0, 1], c);
}).add();

Synth("snare");

Synth("fm3", [\freq, 220]);

~cl = MykClock.new;
~cl.run;
~cl.remove(0);

~notes = [60, 62, 64, 65, 72, 75, 100];


// randomly choosing notes
~cl.add(2, {
	Synth("fm3", [\freq, ~notes.choose.midicps, \index, rrand(0, 1000)]);
    },
	[0.25],
);

// iterating through the notes
~cl.add(2, {
	Synth("fm3", [\freq, ~notes[0].midicps]);
	~notes = ~notes.rotate(-1);
    },
	[0.25],
);

~cl.bpm(120)


~cl.remove(2);

~cl.add(0, {Synth("kick");}, [0.5, 0.25], [0.75]);

~cl.add(0, {Synth("snare");}, [0.5, 0.25], [0.75]);

~cl.add(1, // this is channel 1 on the clock
	{Synth("hihat2");}, // this is the function to run
	[1, 1, 1, 1], // play every 0.25 beats
	[1, 1, 1, 0] // play with a 75% chance...
);

SynthDef("kick",{
	var c;
	c = SinOsc.ar(Line.kr(300, 30, 0.1));
	Out.ar([0, 1], c * Line.kr(0.5, 0, 1.0, doneAction:2));
}).add();

~cl.remove(0);










