(
SynthDef(\axel, {|freq=440, lpfreq=12000, rq=0.2, gate=1, out=0|
	// var chorus = LFNoise2.ar(3).range(0.99,1.01).dup(3);
	var chorus = 1;
	var saw1 = LFSaw.ar(freq * chorus, 0, 0.1);
	var saw2 = LFSaw.ar((freq.cpsmidi - 0.1).midicps * chorus, 0, 0.1);
	var tri = LFTri.ar(freq * chorus, 0, 0.1);
	var mix = Mix([saw1, saw2, tri]);
	var lpf = RLPF.ar(mix, lpfreq, rq);
	var env = EnvGen.ar(Env.adsr(0.3, 0.6, 0.5, 0.25), gate, doneAction: 2);

	Out.ar(out,
		Pan2.ar(lpf * env, 0);
	);
}).add;

SynthDef(\cheese, {|in=0, mix=0.5, room=0.8, damp=0.1, ldel=0.2, ldec=3,
	rdel=0.25, rdec=3, ldmul=0.5, rdmul=0.5, out=0|

	var sig = In.ar(in, 2);
	var lcomb = CombN.ar(sig[0], 1, ldel, ldec) * ldmul;
	var rcomb = CombN.ar(sig[1], 1, rdel, rdec) * rdmul;
	var left = Mix([sig[0], lcomb]);
	var right = Mix([sig[1], rcomb]);
	var verb = FreeVerb2.ar(left, right, mix, room, damp);

	Out.ar(out,
		verb
	);
}).add;
)

~bus = 0;
~bus = Bus.audio(s, 2);
c.free; c = Synth(\cheese, [\in, ~bus, \ldec, 1, \rdec, 1, \room, 0.5]);

MIDIIn.connectAll;

(
~notes = nil!128;
~lpfreq = 12000;
~rq = 0.2;

MIDIdef.noteOn(\acOn, {|val, num, chan, src|
	// [val, num, chan, src].postln;
	~notes[num] = Synth.before(c, \axel, [
		\freq, num.midicps,
		\lpfreq, ~lpfreq,
		\rq, ~rq,
		\out, ~bus
	]);
});

MIDIdef.noteOff(\acOff, {|val, num, chan, src|
	// [val, num, chan, src].postln;
	~notes[num].set(\gate, 0);
});

MIDIdef.cc(\lpf, {|val, num, chan, src|
	// [val, num, chan, src].postln;
	if (num == 7) {
		if(~islpf) {
			~lpfreq = val.linexp(0, 127, 20, 20000);
			~lpfreq.postln;
		} {
			~rq = val.linlin(0, 127, 0, 1);
			~rq.postln;
		};

		~notes.reject {|item, i| item.isNil}.do {|synth, i|
			synth.set(\lpfreq, ~lpfreq, \rq, ~rq);
		};
	};

	if (num == 64) {
		~islpf = val == 0;
	};
});

)

~islpf = true;
c.set(\mix, 0);
c.free

c = Synth(\cheese, [\in, ~bus]);
c.set(\ldec, 2, \rdec, 2, \room, 0.5);

~dbus = ~bus
~bus = 0