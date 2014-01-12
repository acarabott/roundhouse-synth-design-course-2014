/* ============================================================ */
/* Envelopes 			                                        */
/* ============================================================ */


/*
------------------------
click click click
------------------------

You've probably noticed that when we free our synths we get a click, which may be undesirable.

This is because the synth is ending while output something other than a 0.
This creates an extremely fast transition from x to 0, which sounds like a click

To prevent this happening we need to create a smooth transition to 0, to do this we need to use an Envelope.

You've probably used an ADSR (Attack Decay Sustain Release) envelope before

In SuperCollider we can easily create an ADSR, but also many other types of envelopes

To create an ADSR envelope we just do
*/

Env.adsr

/* We can see what this looks like by doing */

Env.adsr.plot;

/* We can set values for the Env like so */

Env.adsr(0.5, 0.3, 0.9, 1).plot;

/*
This isn't quite ready to use in a SynthDef yet, it's just an Envelope.

We need to turn it into an audio signal, which we can then use to control our mul

This is done with EnvGen.ar, which has other arguments; we're going to use two of them

1. The first argument is the Env

2. The second is the gate, if this value is 1 then it will keep sustaining, if it's 0 then it will release.
-- We'll use an argument called gate for this, as we will want to set it to 0 on noteOff

3. The sixth is doneAction, which if we set to 2 will do .free on the synth once the envelope is finished
-- We can skip the 3rd-5th arguments by setting this argument by name doneAction:

*/
EnvGen.ar(Env.adsr(0.5, 0.3, 0.9, 1), gate, doneAction: 2);

/*
So now our SynthDef looks like this

A couple of things are different:
1. First of all I've assigned the LFTri and EnvGen to variables called sig and env
-- Variables inside a synthdef don't use ~ they have the word "var" and a space before them
2. Instead of plugging env into sig's mul argument, I've multiplied them at the end sig * env
-- This is the same thing, mul is short for multiply and is just a number to multiply the signal by

*/

SynthDef(\tri, {|freq=440, mul=0.1, gate=1, out=0|
	var sig = LFTri.ar(freq, 0, mul);
	var env = EnvGen.ar(Env.adsr(2, 0.3, 0.9, 1), gate, doneAction: 2);

	Out.ar(out,
		sig * env
	);
}).add;


/*
And if we update our MIDIdefs accordingly...
*/

MIDIIn.connectAll;
~synths = Array.newClear(128);

MIDIdef.noteOn(\noteOnAction, {|vel, num|
	~synths[num] = Synth(\tri, [\freq, num.midicps, \mul, vel.linlin(0, 127, 0, 0.15)]);
});

/*
And we can make a noteOff MIDIdef to free the synths
*/

MIDIdef.noteOff(\noteOffAction, {|vel, num|
	~synths[num].set(\gate, 0);
});

/*
Lovely and click free.
*/











/*
--------------------------
Defining our own envelopes
--------------------------

Now you get to see some of the power of SuperCollider.

We can into fact define our own envelopes, with as many portions as we like, not limited to just ADSR

Here's an example
*/

Env.new([0, 1, 0.3, 0.8, 0.2, 0.6, 0], [0.05, 0.2, 0.3, 0.6, 0.2, 1], \sin, 5).test.plot;

/*
And something weirder
*/
Env.new(Array.fill(15, {|i| i % 2 * rrand(0.25, 0.7) }) ++ 0, Array.fill(15, {0.05}), \sin).test.plot;


/*
With Env.new

1. The first argument is an array of volumes between 0.0 and 1.0
e.g. this means start at 0, go up to 0.8 then back down to 0

[0, 0.8, 0]

2. The second argument is an array of durations in seconds
(there is always one less duration than level, I always check by making sure the number
of durations matches the number of commas in the levels array)

[0.05, 1]

This means
- take 0.05 seconds to go from 0 to 0.8
- take 1 second to go back to 0

3. The third argument is the type of curve to use, this can be

\lin
\exp
\sin
\wel
\sqr
\step
\cub
A number e.g. 2.0
an array of the above

4. The fourth argument is the loopNode: the index of the volumes that you want to sustain on

e.g. with [0, 0.8, 0]

if you want to sustain on the 0.8, the index would be 1
(array indexes start at 0)

Try out different curve values with the env below
*/

Env.new([0, 0.8, 0], [0.05, 1], \lin, 1).test.plot;


/*
Let's add a custom envelope to a SynthDef
*/

SynthDef(\tri, {|freq=440, mul=0.1, gate=1, out=0|
	var sig = LFTri.ar(freq, 0, mul);
	var env = EnvGen.ar(Env.new([0, 1, 0.05, 0.8, 0], [1, 0.05, 0.01, 0.1], \sin, 1), gate, doneAction: 2);

	Out.ar(out,
		sig * env
	);
}).add;


/*
One last thing...

If we don't give our Env a release node:
- It won't sustain
- It will release automatically
- We don't need a gate
- So we don't need to store and release it
*/


SynthDef(\autoTri, {|freq=440, mul=0.1, out=0|
	var sig = LFTri.ar(freq, 0, mul);
	var env = EnvGen.ar(Env.new([0, 1, 0], [0.05, 0.5, ], \sin), doneAction: 2);

	Out.ar(out,
		sig * env
	);
}).add;

MIDIdef.noteOn(\noteOnAction, {|vel, num|
	Synth(\autoTri, [\freq, num.midicps, \mul, vel.linlin(0, 127, 0, 0.15)]);
});

MIDIdef.noteOff(\noteOffAction, {|vel, num|
	// do nuffink
});
