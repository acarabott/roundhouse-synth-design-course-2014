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


