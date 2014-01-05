/* ============================================================ */
/* Getting Polyphonic                                           */
/* ============================================================ */

/*
Before we start getting fancier with our synth design, we should learn how to be polyphonic.

To achieve this takes a few big steps, but will take us to the level needed for the rest of the course.

SynthDefs / Synths
Envelopes - self killing
Envelopes - release

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

Here's our LFTri synth written out as a SynthDef
*/

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
- The .add tells the computer to add this SynthDef to the library so that it can be used later

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
*/
