/* ============================================================ */
/* Getting Polyphonic                                           */
/* ============================================================ */

/*
Before we start getting fancier with our synth design, we should learn how to be polyphonic.

To achieve this takes a few big steps, but will take us to the level needed for the rest of the course.
*/








/*
-------------------------
Many synths, one SynthDef
-------------------------

For a polyphonic synth, we actually need a new synth whenever we press a key.

To do this we are going to alter the way we make synths slightly, by creating one SynthDef from which we can make many Synths

A SynthDef is like a recipe, it gives us the definition or shape of the synth we want.
Think of it as a jelly mould which you can then make many jellies.
We can then easily make many (tens, hundreds, thousands...) of Synths from this mould

Here's our LFTri synth, and then the same thing written out as a SynthDef

*/

// old and busted
~tri = {|freq=440, mul=0.1| LFTri.ar(freq, 0, mul) }.play;

// new hotness
SynthDef(\tri, {|freq=440, mul=0.1, out=0|
	Out.ar(out,
		LFTri.ar(freq, 0, mul);
	);
}).add;

/*
It's very similar, but with a couple of changes.
1. It's now wrapped up inside SynthDef(\tri, {}).add;
2. We have this Out UGen
3. It doesn't make a sound when we run it

1.
- SynthDef tells the computer that this is a SynthDef
- The \tri bit at the beginning is the name for our SynthDef, this needs to be unique
- We don't store it in a variable, doing .add stores it in a global library for use later

2.
- The Out UGen is what connects our sound to our speakers
- It's first argument uses the argument out, which has the default value of 0
- This means use the first speaker (computer count from 0), if we set it to 1, it would be the right speaker


3.
We need to create a Synth from it, like so
*/
~tri = Synth(\tri, [\freq, 220, \mul, 0.05]);

/*
This creates a synth with specific values passed into the arguments, it's like calling .set straight away.

Now that we have this recipe, we can make 50 synths, all with different values
*/

50.do {
	Synth(\tri, [\freq, rrand(100, 5000), \mul, 0.01]);
}

/* Or make a nice, polyphonic synth by changing our noteOn MIDIdef */










/*
------------------
New Synth per note
------------------
If we adjust our MIDIdef we can get a new synth for each key
*/

MIDIdef.noteOn(\noteOnAction, {|vel, num|
	Synth(\tri, [\freq, num.midicps, \mul, vel.linlin(0, 127, 0, 0.15)]);
});

/*
---------------
Ahhhhh shut up!
---------------

The only problem is we are never ending our synths, they stay on indefinitely.
What we need to do is store these synths, and quieten them on noteOff

-------------------
Storing many things
-------------------

Storing all of these synths in different variables would be messy and we'd need 128 different variables to do so.

Instead we can store them in an Array, which is like a variable with numbered slots. It's a bucket with dividers.

We store this array in a variable, then we can easily look up any slot in that array.

To make and store an array that has 128 slots (number of MIDI notes) we do this:
*/

~synths = Array.newClear(128);

/*
now to put something into a slot we do

~synths[SLOT_NUMBER] = THING_WE_WANT_TO_PUT_IN_THERE

e.g.
*/

~synths[60] = Synth(\tri, [\freq, 60.midicps]);

/*
This puts a synth with a the frequency of MIDI note 60 (261.6255653006 Hz) into the slot numbered 60

We can access this synth by doing
*/

~synths[60];

/*
So to free it we would do
*/

~synths[60].free;

/*
------------------------
noteOn / noteOff
------------------------

So now our noteOn MIDIdef can store a synth each time a key is pressed
*/

MIDIdef.noteOn(\noteOnAction, {|vel, num|
	~synths[num] = Synth(\tri, [\freq, num.midicps, \mul, vel.linlin(0, 127, 0, 0.15)]);
});

/*
And we can make a noteOff MIDIdef to free the synths
*/

MIDIdef.noteOff(\noteOffAction, {|vel, num|
	~synths[num].free;
});











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

We can in fact define our own envelopes, with as many portions as we like, not limited to just ADSR

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
