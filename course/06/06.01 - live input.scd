/* ============================================================ */
/* Live Input		                                            */
/* ============================================================ */

/*
--------
WARNING!
--------

Make sure you are using headphones for all of these examples, otherwise you'll
be in feedback city...



SuperCollider, live audio input, got your back...

*/

(
SynthDef(\inVerb, { |in=0, mix=0.5, room=0.9, damp=0.1, pan=0, out=0|
	var sig = SoundIn.ar(in);
	var reverb = FreeVerb.ar(sig, mix, room, damp);

	Out.ar(out,
		Pan2.ar(reverb, pan);
	);
}).add;
)

~cave = Synth(\inVerb, [\in, 0]);

~cave.set(\room, 0.2);
~cave.set(\room, 1);


/*

Other UGens to explore with live input:
- CombC
- PitchShift
- Decimator
- CrossoverDistortion
- GVerb
- SwitchDelay
*/
