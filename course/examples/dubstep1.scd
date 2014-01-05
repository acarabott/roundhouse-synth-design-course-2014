{
var trig, numSmp, rate, freq, wobble,out,note,mod;
freq = (140/60)/3; // It's not dubstep if it's not at an integer multiple of 140bpm.
trig = Impulse.kr(freq); // Main tempo pulse
note = Demand.kr(trig, 0, Dseq([40, 43, 47, 47, 40, 49-12, 43, 40-12], inf));
note = Slew.kr(note, 300, 20); // Pitch changes are slewed, faster up than down
numSmp = SampleRate.ir / freq;
rate = 2pi / numSmp;
rate = rate * Demand.kr(trig, 0, Dseq([1/2, 6, 6, 6*2, 2, 8, 6, 6*2], inf)) / 2; // Choose random "wobble" tempo
wobble = Phasor.ar(trig, rate, pi, 2pi ).cos; // Phasor is used to index cosine. Just sweeps through a half of a full wave.
out = VarSaw.ar(note.midicps, width: wobble.range(0.45,0.55)) // Tone to be filtered. Notice modulation of width param.
    + SinOsc.ar(note.midicps/2, mul: wobble.range(0,1)).dup;  // Subbass.
out = Decimator.ar(out, 20000, wobble.range(1.2,8)); // Sampling resolution is decreased in time with the wobble.
out = MoogLadder.ar(out, wobble.range(note.midicps,25000), wobble.range(0.03,0.1)).dup; // Emulated Moog Low Pass.
out = out * 0.25; // Turn it down a bit to prevent clipping.
out = [DelayC.ar(out, 1, wobble.range(0,0.0012)), DelayC.ar(out, 1, wobble.range(0.0012,0))]; // Spatialization
out = out * Linen.kr(trig, 0.01, 0.7, 1.3/freq, doneAction: 0); // Simple Envelope
}.play;