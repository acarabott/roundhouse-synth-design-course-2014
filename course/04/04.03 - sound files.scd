/* ============================================================ */
/* Playing Sound Files                                          */
/* ============================================================ */

/*
We can load and playback pre recorded audio (samples, loops) in a number of ways

The first thing we need to do is load the file into a Buffer


---------------
Reading Buffers
---------------
*/

~myBuffer = Buffer.read(s, Platform.resourceDir ++ "/sounds/a11wlk01.wav");

// Quick audio preview
~myBuffer.play;
// Quick visual preview
~myBuffer.plot;

/*
We are using the first two arguments of Buffer.read, which if you check the help
file, are
- the server on which we should load the buffer (the default server is
always stored in the variable s)
- the path to the soundfile on our computer

In this case I've used a default sound that comes with SuperCollider, which is
stored inside the SuperCollider.app application, Platform.resourceDir points to
this folder so it doesn't matter where you've stored the app.

The easiest way to find the path of an audio file is to just drag it into a text
document.

Find the file drumloop.wav in the 04/sounds/ folder and drag it into this file.

Now write your own Buffer.read, using that file
*/



/*
---------------
Playing Buffers
---------------

The quickest way to play a buffer in our SynthDefs is to use the PlayBuf.ar Ugen

PlayBuf takes the following arguments and defaults:

PlayBuf.ar(
	numChannels, 	// how many channels our audio file is (usually 1 or 2)
	bufnum: 0, 		// this is the buffer that we want to play
	rate: 1, 		// rate 1 = normal, 2 = double, 0.5 = half, -1 = reverse
	trigger: 1, 	// a trigger will restart the playback
	startPos: 0, 	// sample to start playback at
	loop: 0, 		// loop? 0 = no, 1 = yes
	doneAction: 0	// use 0 when looping, 2 for single shot
)
Let's code up a PlayBuf SynthDef together
*/





/*
A note on reverse single shots..

doneAction gets triggered when the playhead is >= number of samples
so if you are starting at sample 0, and going backwards, you will hit this
sample and trigger the doneAction

To avoid this, you must start at the penultimate sample, which you can get with
~buffer.numFrames - 2
*/



/*
TODO

LoopBuf
BufRd/Phasor
PV_PlayBuf
PV_Freeze
*/