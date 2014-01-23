/* ============================================================ */
/* Subtractive Synthesis                                        */
/* ============================================================ */

/*
So far, our approach to generating signals would be classified as
'additive synthesis'

This is where you take simple building blocks, like oscillators, and add them
together to make richer sounds.

There is an opposite approach known as 'subractive synthesis'.
This is where you start with something complex or full (typically noise),
and then subtract from it using filters.

Try this example, start with the mouse at the left side of the screen and slowly
move it to the right, watch as a peak appears.
*/
FreqScope();
{BPF.ar(WhiteNoise.ar(MouseX.kr(0.1, 1.5)), 880, MouseX.kr(1, 0.001))}.scope;

/*
This has a different quality to it, partly from the bits of whitenoise still
audible, and partly from the randomness of energy at our frequency

We can set up multiple band pass filters and achieve harmonics
*/

{
	var noise = WhiteNoise.ar(1);
	var scale = Scale.minor.degrees + 60;
	var fundamental = Select.kr(MouseX.kr(0, scale.size).round, scale).midicps;
	var sig = Mix.fill(8, {|i|
		BPF.ar(noise, (i + 1) * fundamental + rrand(-3.0, 3.0), 0.0001)
	});

	Normalizer.ar(sig, 0.2);
}.scope;