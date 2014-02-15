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

*/