/* ============================================================ */
/* Controlling our synths                                       */
/* ============================================================ */


/*
These sound generators or "UGens" (Unit Generators) can be connected up and plugged into each other
*/

// We are going to replace the frequency argument with a mouse control UGen
{ LFTri.ar(440, 0, 0.1) }.play;

// The mouse control UGen looks like this
MouseX.kr(220, 880)
// Where 220 is the value when the mouse is at the left of the screen, and 880 to the right

// frequency replaced, run it!
{ LFTri.ar(MouseX.kr(220, 880), 0, 0.1) }.play;

/*
.kr means Control Rate (why not cr?) which you should use if a UGen is controlling a sound, but not making a sound
if it is making a sound we use ar (Audio Rate)

Let's replace the mul argument with a slow SinOsc (LFO) so that we get a tremolo effect
Use this SinOsc to replace the mul argument (currently 0.1)
*/
SinOsc.kr(3, 0, 0.1)

{ LFTri.ar(MouseX.kr(220, 880), 0, 0.1) }.play;

/*
Now replace the frequency of this SinOsc with a Mouse Y UGen
MouseY.kr(20, 1)
*/

{ LFTri.ar(MouseX.kr(220, 880), 0, SinOsc.kr(MouseY.kr(10, 1), 0, 0.1)) }.play;




/* -------------- */
/* MIDI Control   */
/* -------------- */

/*
The MIDI keyboard is a very familiar control interface, and we will be using them a lot on this course

Run these two blocks of code and you should start seeing numbers when you the keys on your MIDI keyboard.
The first is the velocity, the second is the key number
*/

MIDIIn.connectAll;

MIDIdef.noteOn(\noteOnAction, {|vel, num|
	[vel, num].postln;
});

/*
To have this control our synths we need to make two changes to them.

1. We need to store them so we can access them later
2. We need to be able to pass new values to them
*/

/*
--------------
1. Storing
--------------

We store synths in a "variable", a variable is something, with a name, that you can store things in.
Think of it like a bucket with a label on it.

For now we are going to use global variables, which always start with a tilde ~ followed by a lower case letter e.g.

~synth
~synth2
~bigSynth
~megaSynth_666_2014_omfg

we put things into a variable using the equals symbol, this is called assignment
*/
~name = "Arthur"; // change this to your name...

// now if we run ~name.postln; our name will be printed
~name.postln;

// let's put a synth into a variable

~tri = { LFTri.ar(440, 0, 0.1) }.play;

// now we can do things to this synth, e.g. kill it, without killing all other sounds

~tri.free;

/*
--------------
2. Pass in values
--------------

To be able to pass in values, to change the frequency for example, we need to add arguments to our synth

Synth argument rules:
- Go after the first curly bracket
- Live between two pipes | (shift \, next to the return key)
- Start with a lower case letter

e.g.
*/

~tri = {|freq| LFTri.ar(440, 0, 0.1) };

// default values are set using equals (like variables, in fact, they are variables)

~tri = {|freq=440| LFTri.ar(440, 0, 0.1) };

// they can then be used to replace parameters in our synth, this lets us change those parameters later

~tri = {|freq=440| LFTri.ar(freq, 0, 0.1) }.play;

// we change them by using .set on the synth variable

~tri.set(\freq, 880);


/*
-----------------------
Putting it all together
-----------------------

We just need to change our MIDI noteOn responder to change the frequency of our synth whenever we press a key

The key number argument we get whenever we press a key is a MIDI note number, but our synth wants a frequency.

Fortunately .midicps converts a midi note to frequency, run this line below to see
*/
69.midicps;


// So if we add this to our MIDIdef....
MIDIdef.noteOn(\noteOnAction, {|vel, num|
	[vel, num].postln;

	~tri.set(\freq, num.midicps);
});

/*
-----------------------
Adding velocity
-----------------------

Right, your first proper challenge, lets make this synth respond to the velocity of our playing.

Time to think like a programmer; break it down into small manageable steps.

1. We need to be able to pass a value into our synth that controls the mul: our synth needs a new argument
2. That argument needs to replace the mul value in our LFTri
3. We need to convert our MIDI velocity values (0-127) to good synth mul values (0.0 - 0.1)
- we can't use .midicps for this, instead we use .linlin(inMin, inMax, outMin, outMax)
- inMin/inMax are the min and max numbers we will get as input (0, 127)
- outMin/outMax are the min and max values we want to output (0, 0.1)
4. Our MIDIdef needs to set the new argument on our synth.
*/