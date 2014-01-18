/* ============================================================ */
/* Getting Polyphonic                                           */
/* ============================================================ */

/*
Before we start getting fancier with our synth design, we should learn how to be
polyphonic.

To achieve this takes a few big steps, but will take us to the level needed for
the rest of the course.
*/


/*
------------------
New Synth per note
------------------
If we adjust our MIDIdef we can get a new synth for each key
*/
MIDIIn.connectAll;
MIDIdef.noteOn(\noteOnAction, {|vel, num|
	num.postln;
	// Synth(\tri, [\freq, num.midicps, \mul, vel.linlin(0, 127, 0, 0.15)]);
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

Storing all of these synths in different variables would be messy and we'd need
128 different variables to do so.

Instead we can store them in an Array, which is like a variable with numbered
slots. It's a bucket with dividers.

See 02.docs/varVsArray.pdf for a visualisation

We store this array in a variable, then we can easily look up any slot in that
array.

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
This puts a synth with a the frequency of MIDI note 60 (261.6255653006 Hz) into
the slot numbered 60

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
	~synths[num] = Synth(\tri, [
		\freq, num.midicps,
		\mul, vel.linlin(0, 127, 0, 0.15)
	]);
});

/*
And we can make a noteOff MIDIdef to free the synths
*/

MIDIdef.noteOff(\noteOffAction, {|vel, num|
	~synths[num].free;
});
