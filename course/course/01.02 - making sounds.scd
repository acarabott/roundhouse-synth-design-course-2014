/* ============================================================ */
/* Booting the Server                                           */
/* ============================================================ */

/*
Before we make any sounds we have to boot the server that generates audio

Do this by running the line below;
*/

s.boot;

/* -------------- */
/* Useful windows */
/* -------------- */

/* Running these lines will give you some useful windows */

s.meter;         // Input / Output meters
s.makeWindow;    // Server Window: Master Volume, Mute, Boot and Record controls
s.scope;         // Oscilloscope
FreqScope.new;   // Frequency Analyser

/* Resize this main window so that you can see each of these tools */









/* ============================================================ */
/* Making Sounds                                                */
/* ============================================================ */

// Run this line to generate another sine wave
{ SinOsc.ar(567, 0, 0.1) }.play;

/*
We are passing three numbers to this SinOsc, these are called 'arguments' or 'parameters'

The helpfile tells us that these are
  - frequency
  - phase
  - mul (multiplier, affects volume)

Start typing out the line above, and you will notice after you type the ( a yellow box will appear
This is to help you remember what each number does, and shows you the default value.

Make sure your line is EXACTLY the same as the one above, and run it
*/

{ SinOsc.ar(440, 0, 0.1] }.play;

/*
Hopefully you got another sinewave, if not, check the Post Window, you probably have an error.
Double check your code is exactly the same, if it still doesn't work say "Umm, my code isn't working", or run the line below
*/
"Ummm, my code isn't working".speak;



/* -------------- */
/* Get some chops */
/* -------------- */

/*
To get used to the weird symbols and pickiness of the computer, write 10 more sound generators...

- Use any frequency you want (human hearing is 20-20000, although this will be lower depending on your age)
- Make sure you always use 0.1 or lower for mul

Instead of SinOsc you can use any of the following:
  LFSaw
  LFTri
  LFCub
  LFPar
*/

/*
Now generator some noise

These only have one argument which is mul, keep it at 0.1
  WhiteNoise
  BrownNoise
  PinkNoise
  ClipNoise

And these have two arguments, useful ranges are given for the first argument, the second is mul

Crackle   // 1.0 - 2.0
Dust      // 10 - 10000
LFNoise0  // 10 - 2000
*/




/* -------------- */
/* Bigger example */
/* -------------- */

// Just to show you that these simple sounds can lead to something more interesting

(
    // select all the code and run it
    // use mouse to strum strings
{
	var pitch, mousex, out;
	pitch = [ 52, 59, 66, 67, 71, 81 ];
	mousex = MouseX.kr;
	out = Mix.arFill(pitch.size, { arg i;
		var pos, trigger1, trigger2, pluck1, pluck2, period, string1, string2, delay, mix;

		pos = 0.25 + (i * 0.1);
		period = pitch.at(i).midicps.reciprocal;

		trigger1 = HPZ1.kr(mousex > pos).abs;
		pluck1 = PinkNoise.ar(Decay.kr(trigger1, 0.05));
		string1 = CombL.ar(pluck1, period, period, 4);

		trigger2 = HPZ1.kr(mousex > (pos + 0.015)).abs;
		pluck2 = PinkNoise.ar(Decay.kr(trigger2, 0.05));
		string2 = CombL.ar(pluck2, period/2, period/2, 4);

		mix = Mix([string1, string2]);
		delay = CombN.ar(mix, 0.2, 0.2, 2);
		mix = Mix([mix, delay * 0.2]);

		Pan2.ar(FreeVerb.ar(delay, 0.5, 0.9, 0.4), i * 0.2 - 0.5);
	});
	LPF.ar(out, 12000);

	LeakDC.ar(out);


}.play;
)
