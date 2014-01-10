SynthDef("kickDrum", { arg gate=0;

        var daNoise,daOsc,env1,env2,env3;
        env1=Env.perc(0.001,1,80,-20);

        //mix-amp envelope

        //controlls overall amplitude...0 to 1

        env2=Env.perc(0.001,1,1,-8);

        //osc-pitch envelope

        //controlls pitch of the oscillator...0 to 80 Hz

        env3=Env.perc(0.001,1,80,-8);



        //Attack noise portion of the sound

        //filter cutoff controlled by env1

        //+20 to move it into the audible

        //spectrum

        daNoise=LPF.ar(WhiteNoise.ar(1),EnvGen.kr(env1,gate)+20);

    //VCO portion of the sound

    //Osc pitch controlled by env3

    //+20 to move the pitch into the

    //audible spectrum

        daOsc=LPF.ar(SinOsc.ar(EnvGen.kr(env3,gate)+20),200);



        //output

        Out.ar(0,Pan2.ar(

                                Mix.ar([daNoise,daOsc]),

                                0, //position

                                //level controlled by env2

                                EnvGen.kr(env2,gate,doneAction: 2)

                        );

                  );

}).load(s);


Synth("kickDrum",[\gate,1]);


(
SynthDef(\808, {|out=0|
	var sig = LPF.ar(Ringz.ar(Impulse.ar(0), 60, 0.5), 500);
	var cmp = CompanderD.ar(sig, -20.dbamp, 1, 0.3, 0.003, 0.08);

	cmp = cmp * (10.dbamp);
	// cmp = sig;
	Out.ar(out,
		cmp.dup
	);
}).add;
)

Tdef(\kick, {
	inf.do {
		Synth(\808);
		0.5.wait;
	};
}).play(quant:1);



SynthDef(\808, {|out=0|
	var sig = LPF.ar(Ringz.ar(Impulse.ar(0), 60, 0.5), 500);

	Out.ar(out,
		sig.dup
	);
}).gui



Synth(\808);