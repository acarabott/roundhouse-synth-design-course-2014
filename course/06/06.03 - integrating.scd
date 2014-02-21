/* ============================================================ */
/* Integrating with other programs                              */
/* ============================================================ */


/*
It is possible, although not super straightforward, to integrate SuperCollider
with other pieces of music software that you might use, e.g. DAWs like Logic,
Abeltone, Cubase etc







-----------------------
Controlling SC via MIDI
-----------------------

One approach is to treat SuperCollider like an old skool, hardware synth. One
that can be controlled via MIDI, and outputs audio. In fact you can just think
of it as plugging a nice keyboard (like a Nord) into your audio interface, but
instead of performing on it yourself, you use your DAW to send MIDI data.

There are a couple of ways of doing this. On a mac you have the internal IAC
Driver, which lets you send MIDI between applications.

Open /Applications/Utilities/Audio MIDI Setup.app to make sure that it is
enabled.

It's a good idea to create a second port on the driver, so that you use one for
your normal MIDI controllers, and the second for your internal routing.

You then set up an external MIDI instrument in your DAW, that outputs on this
second IAC port.

If your OS doesn't have an internal MIDI instrument you can either go old skool
with an 2 channel MIDI interface, sending out on one channel from your DAW, and
receiving in SuperCollider on the other. Alternatively you could try Jack:

http://www.jackosx.com/ (OS X)
http://jackaudio.org/ (Windows / Linux)

Set up SuperCollider with a MIDIdef.noteOn and MIDIdef.noteOff, and check that
you are receiving MIDI data properly
*/

MIDIIn.connectAll;

MIDIdef.noteOn(\noteOn, {|vel, num|
	"on".postln;
	[vel, num].postln;
});

MIDIdef.noteOff(\noteOff, {|vel, num|
	"off".postln;
	[vel, num].postln;
});

/*
Now comes the audio bit.

Within these MIDIdefs you can put your Synth creation code. Now to get audio
back into your DAW you have two options:

Inside the box software routing via SoundFlower or Jack

SoundFlower (OS X only)
	- http://cycling74.com/soundflower-landing-page/
Jack
	- http://www.jackosx.com/ (OS X)
	- http://jackaudio.org/ (Windows / Linux)

Or the ghetto technique of taking an audio cable out of your interface, and
sticking it straight back in. Surprisingly, this is often the easiest and most
straightforward approach, although you are limited by your number of ins/outs.


-------
Latency
-------

Note that with both of these approaches you may have to compensate for latency.
You can set SuperCollider's latency to lower than default like so:

If you start getting "late" messages, your latency is too low.
*/
s.latency = 0.02;

/*

Within the preferences of your DAW you will also find latency compensation
settings, for both MIDI and audio, so you can have it send MIDI messages
earlier than sequenced, to compensate for the latency.








=======================================
Controlling your DAW with SuperCollider
=======================================

You can also use SuperCollider to control your DAW via MIDI (or OSC if
supported).

The setup is the same as above, but in reverse. You will want to use the
MIDIOut class.

*/
MIDIClient.init;
MIDIClient.destinations; // this will show you the names of your outputs
// The names here must match EXACTLY that shown by MIDIClient.destinations
~midiout = MIDIOut.newByName("IAC Driver", "Bus 1");
~midiout.latency = 0;

~midiout.noteOn(0, 60, 120); // channel 0, note 60, 120 velocity
~midiout.noteOff(0, 60, 120);


/*
See the MIDIOut helpfile for further available messages.

This can be particularly useful for automating your automation! e.g. controlling
your automation via machine listening Synths.








===============
SuperColliderAU
===============

Another way to integrate SuperCollider with a DAW on a mac is to use
SuperColliderAU to create FX audio units. Unfortunately it's not a well
supported project, so creating virtual instruments isn't possible at the moment.

For a good tutorial see:

http://www.mojolama.com/building-audio-units-supercolliderau-big-picture

*/
