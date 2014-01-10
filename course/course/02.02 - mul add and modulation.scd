 ============================================================ */
/* Mul, Add and modulation                                      */
/* ============================================================ */


/*
-------------------------
Mul
-------------------------

We've used mul a lot, it affects the amplitude or volume of our synths.

A soundcard will output values between -1 and 1, anything outside of this range
will be clipped to these values and sound distorted.

Note that -1 is just as
loud as 1, 0 is silent.

This is why we are using low mul values, because if we have 10 signals with mul
of 0.1, we will be at our max volume. We are leaving ourselves "headroom"

Turn your volume right down before you play run this code.
Set the scope to one channel using the second number
*/
s.scope;

x = {SinOsc.ar(220, 0, 1)}.play;

/*
Here you can see the sine wave is reaching the top (1) and bottom (-1) of the scope

Let's use a MouseX control to adjust the mul and see what happens
*/
x.free;

x = {SinOsc.ar(220, 0, MouseX.kr(0, 1).poll)}.play;

/*
We can now see the height of the wave change, and in the post window the value of mul
Of course you can also hear the volume change
*/






/*
-------------------------
Add
-------------------------

Add will add a constant value to the output, so if we have a signal that is going
from -0.5 to 0.5, and we add 0.5 to it, it will go from -0 to 1

Set your scope back to 2 channels

This will create two Sine waves, one per channel. The first with no add, the
second with 0.5
*/

x = {
	[SinOsc.ar(440, 0, 0.5), SinOsc.ar(440, 0, 0.5, 0.5)]
}.play;

/*
Set your scope to 1 channel and change the first number box between 0 and 1
*/

x.free;

/*
Now try this example with add controlled by MouseX
watch the level in the meters, but notice how it doesn't change the sound as mul did
*/
s.meter;
x = {SinOsc.ar(1000, 0, 0.1, MouseX.kr(-0.9, 0.9))}.play;






/*
-------------------------
Alternative Notation
-------------------------

There's a shorthand, alternative way of doing mul and add on a signal:
* and +

e.g.
*/

SinOsc.ar(440, 0, 0.1, 0.1)

// is the same as

SinOsc.ar(440, 0) * 0.1 + 0.1







/*
-------------------------
Modulation
-------------------------

mul and add are useful when you want to use an a generator for something OTHER
than making a sound.

By default UGens like SinOsc and LFSaw generate signals between -1 and 1, but if
we want to use a SinOsc to control the cutoff frequency of a filter, we want
values between 0 and 20000, as these are valid Hz.

We can use mul and add for this
*/

SinOsc.kr(1, 0, 10000); // this will go from 10000 and -10000 and back once per second

SinOsc.kr(1, 0, 10000, 10000); // this will go from 0 to 20000

{
	var sig = LFSaw.ar(440, 0, 0.1);
	var lfo = SinOsc.kr(1, 0, 10000, 10000);

	LPF.ar(sig, lfo);
}.scope;

// Alternatively

{
	var sig = LFSaw.ar(440) * 0.1;
	var lfo = SinOsc.kr(1) * 10000 + 10000;

	LPF.ar(sig, lfo);
}.scope;

/*
Even more alternatively (hipster points)

.range will scale -1.0 - 1.0 to the arguments
*/

{
	var sig = LFSaw.ar(440) * 0.1;
	var lfo = SinOsc.kr(1).range(1, 20000).poll;

	LPF.ar(sig, lfo);
}.scope;