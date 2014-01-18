/* ============================================================ */
/* Session 2 Warmup	                                            */
/* ============================================================ */

s.meter;
s.makeWindow;
s.scope;
FreqScope.new;

/*
Let's do some warm ups to get back into it.
You should look at the files from last week if you get stuck

Create three synths that are playable with the keyboard, using any of these
oscillators

LFSaw, LFTri, LFCub, LFPar

- We need to store them in variables e.g.
	~sine, ~synth, ~sound, ~smell, ~something, ~chips
- They should have freq and mul arguments with default values e.g.
- The arguments should control the oscillators freq and mul parameters
- Use MIDIdef.noteOn to .set the freq using num.midicps
- .set the mul using vel.linlin(0, 127, 0, 0.1)
- Have all three playing at once, controlled by your keyboard

Here's one to get you started
*/
~sine = {|freq=440, mul=0.1| SinOsc.ar(freq, 0, mul); }.play;

MIDIIn.connectAll;

MIDIdef.noteOn(\noteOnAction, {|vel, num|
	~sine.set(\freq, num.midicps, \mul, vel.linlin(0, 127, 0, 0.1));
});