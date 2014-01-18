/* ============================================================ */
/* Filters 			                                            */
/* ============================================================ */

/*
Filters are great tools for sculpting sounds.

A filter is an amplifier that can amplify, pass, or cut the energy at some
frequencies.

The most common types that you're probably familiar with are Low Pass, High Pass
and Band Pass

- A Low Pass filter passes through frequencies below it's cutoff, cutting those
above it

- A High Pass filter passes frequencies above it's cutoff and cuts those below
it

- A Band Pass filter passes frequencies in a given band and cuts those above and
below it

In SuperCollider we have these filters and many more, they often have intuitive
names

*/
LPF.ar
HPF.ar
BPF.ar

/*
To see the full list, in the Help Window:
1. Press Browse
2. Scroll down and click on UGens
3. Click on Filters
4. Click on Linear



Usually the filters you see on Synth plugins are Resonant filters
These are filters with a Q factor control, this is the bandwidth of the filter
(the range of the neighbouring frequencies that will also be affected)

With a high enough Q factor the filter has internal feedback and becomes a sine
wave generator

See 02.docs/filters.pdf for some visual explanations of these terms




SuperCollider's got you covered
*/
RLPF.ar
RHPF.ar
// BPF is a resonant filter

/*
Let's make an LFSaw SynthDef with a RLPF
(Saw waves are rich in high frequencies)

It will take the arguments

freq		LFSaw freq
mul			LFSaw mul
ffreq		RLPF freq
rq			RLPF rq


We are going to plug our LFSaw into the in argument of RLPF.ar
The RLPF will be plugged into the channelsArray argument of Out.ar

*/

// Let's code it up!
SynthDef(\sawres, { |out=0|

}).add;

// This will give us MIDI control, and two GUI sliders to control ffreq and rq
MIDIIn.connectAll;
~synth = Synth(\saw);

MIDIdef.noteOn(\noteOnAction, {|vel, num|
	~synth.set(\freq, num.midicps, \mul, vel.linlin(0, 127, 0, 0.2));
});

~filter = EZSlider(label:"filter freq");
~filter.action_({|ez|
	~synth.set(\ffreq, ez.value.linexp(0, 1, 10, 20000));
});

~rq = EZSlider(label:"filter rq");
~rq.action_({|ez|
	~synth.set(\rq, ez.value);
});


/*
Notice in the FreqScope how changing the ffreq and rq affect the frequencies
*/







/*
-------------------------
Task: Velocity -> Filter
-------------------------


Extend your SynthDef so that the velocity input controls the cutoff frequency
of your filter
*/










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

SynthDef(\env, { |trig=1, out=0|
	var sig = SinOsc.ar(440, 0, 0.1);
	var env = EnvGen.ar(Env.new([0, 1, 0], [0.01, 1]), trig);

	Out.ar(out,
		(sig * env).dup
	);
}).add;

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
