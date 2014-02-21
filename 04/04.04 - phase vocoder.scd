/* ============================================================ */
/* Phase Vocoder UGens                                          */
/* ============================================================ */


/*
A phase vocoder is a type of vocoder which can scale both the frequency and time
domains of audio signals by using phase information.
- http://en.wikipedia.org/wiki/Phase_vocoder

You have probably (possibly unknowingly used a phase vocoder before), it enables
(among other things), the time stretching of audio, without altering the pitch.

In SuperCollider can do this with the PV family of UGens

-----------
PV Analysis
-----------

Using the PV Ugens requires an additional step compared to PlayBuf and company;
we have to perform an FFT analysis on the audio file. An FFT analysis tells us
how much energy there is in various frequency bins (ranges).

A normal soundfile tells us what the amplitude of a signal is over time.

*/
(
s.boot;
s.makeWindow;
)

~path = Platform.resourceDir ++ "/sounds/a11wlk01.wav"; // path to our file
~soundfile = SoundFile.new(~path); // lets us get info on this file
~soundfile.openRead;
~soundfile.close;

// allocate an EMPTY buffer on the server that is big enough for our FFT data
~sBuf = Buffer.read(s, ~path); // read the file into a buffer
~aBuf = Buffer.alloc(s, ~soundfile.duration.calcPVRecSize(1024, 0.25));

/*
This SynthDef will take some learning to understand fully, but the essence of
it is:
- play the original Buffer with a PlayBuf
- Do an FFT analysis (convert the information from time to frequency domain)
- Record this FFT Data to our empty Buffer
*/

(
SynthDef(\pvrec, { |soundBuf=0, analysisBuf=0, out=0|
	var sig = PlayBuf.ar(1, soundBuf, BufRateScale.kr(soundBuf), doneAction: 2);
	// second argument of LocalBuf is number of channels,
	// has to match PlayBuf's number of channels
	var fft = FFT(LocalBuf(1024, 1), sig, 0.25, 1);

	// .new not .ar
	PV_RecordBuf.new(fft, analysisBuf, 0, 1, 0, 0.25, 1);
	// No output, this Synth just does analysis
}).add;
)

// Make sure you can see your Server window, watch as the number of Synths goes
// up by 1, then back down when the Synth frees itself. Only then can you use
// the analysis
~analysisSynth = Synth(\pvrec, [\soundBuf, ~sBuf, \analysisBuf, ~aBuf]);


// Now we can play back this analysis, we use an inverse FFT to convert the data
// back from frequency to time domain
(
SynthDef(\pvplay, { |buf=0, rate=1, pan=0, out=0|
	var sig = PV_PlayBuf.new(LocalBuf(1024, 1), buf, rate, 0, 1);
	var ifft = IFFT(sig, 1);

	Out.ar(out,
		Pan2.ar(ifft, pan);
	);
}).add;
)

~pv = Synth(\pvplay, [\buf, ~aBuf]);

~pv.set(\rate, 0.5);	// half speed
~pv.set(\rate, 0.25);	// quarter speed
~pv.set(\rate, 2);		// double speed
~pv.set(\rate, -2);		// reverse double speed


/*
We can write our analysis buffer to a file so that in future we can just load
this rather do the analysis all over again.

We will use the same path, but with the .scpv (SuperCollider Phase Vocoder)
extension.
*/

~aBuf.write(~path ++ ".scpv", "wav", "float32");


/*
------------
PV_MagFreeze
------------

PV_MagFreeze lets you freeze the current magnitudes of our FFT's frequency bins,
it sounds great.

We use a freeze parameter to decide whether to freeze or not.
*/

// replace the path with the file in 04/sounds/guitar.wav
~gBuf = Buffer.read(s, "~/Library/Application Support/SuperCollider/Extensions/sounds/guitar.wav".standardizePath);
~gBuf.numChannels.postln;

(
SynthDef(\pvfreeze, { |buf=0, freeze=0, pan=0, mul=0.5, out=0|
	var sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf), loop:1);
	var fft = FFT(LocalBuf(2048, 2), sig, 0.25);
	var magfreeze = PV_MagFreeze(fft, freeze);
	var ifft = Mix(IFFT(magfreeze) * mul);

	Out.ar(out,
		Pan2.ar(ifft, pan);
	);
}).add;
)

~freeze = Synth(\pvfreeze, [\buf, ~gBuf]);

~freeze.set(\freeze, 1);
~freeze.set(\freeze, 0);
