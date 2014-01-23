/*
-------------------------
Re-triggering Envelopes
-------------------------

Fixed length envelopes (like those made with Env.new, but not sustaing ones like
ADSR) can be re-triggered by using a trigger on the gate argument of EnvGen e.g.

Let's say we want an envelope that looks like Env.new([0, 1, 0], [0.01, 1]) for
our mul, so that we get an attack every time it's triggered

We then need a trigger on our EnvGen, a trigger will happen when the values
changes from NON-positive (<= 0) to positive (> 0).

Try out this SynthDef and mono synth
*/
(
SynthDef(\env, { |trig=1, out=0|
	var sig = SinOsc.ar(440, 0, 0.1);
	var env = EnvGen.ar(Env.new([0, 1, 0], [0.01, 1]), trig);

	Out.ar(out,
		(sig * env).dup
	);
}).add;
)

x = Synth(\env); //trig is 1 by default, and will start at 0 so we get a trigger

x.set(\trig, 0); // set the trig to non-positive
x.set(\trig, 1); // set the trig to positive, we get a trigger

x.free;
/*
Now it's a bit tedious to do .set twice when you just want one trigger
fortunately if we put t_ (e.g. t_trig) at the beginning of an argument it, it
will set itself to 0 immediately after the value we give it
*/



SynthDef(\env, { |t_trig=1, out=0|
	var sig = SinOsc.ar(440, 0, 0.1);
	var env = EnvGen.ar(Env.new([0, 1, 0], [0.01, 1]), t_trig);

	Out.ar(out,
		(sig * env).dup
	);
}).add;

x = Synth(\env);
x.set(\t_trig, 1); // ahhh, glorious triggers






/*
-------------------------
Task: Enveloped Filter
-------------------------


Write a Synth with a filter (RLPF, RHPF or BPF) with its frequency controlled
by an envelope that can be re-triggered.

As we are using our EnvGen to control a value, and not for audio we can use
EnvGen.kr
*/
