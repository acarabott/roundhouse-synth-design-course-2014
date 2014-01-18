/* ============================================================ */
/* SynthDef                                                     */
/* ============================================================ */

/*
-------------------------
Many synths, one SynthDef
-------------------------

For a polyphonic synth, we actually need a new synth whenever we press a key.

To do this we are going to alter the way we make synths slightly, by creating
one SynthDef from which we can make many Synths

A SynthDef is like a recipe, it gives us the definition or shape of the synth we
want.

Think of it as a jelly mould which you can then make many jellies.

We can then easily make many (tens, hundreds, thousands...) of Synths from this
mould

Here's our LFTri synth, and then the same thing written out as a SynthDef

*/

// old and busted
~tri = {|freq=440, mul=0.1| LFTri.ar(freq, 0, mul) }.play;

// new hotness
SynthDef(\tri, {|freq=440, mul=0.1, out=0|
    Out.ar(out,
        LFTri.ar(freq, 0, mul);
    );
}).add;

/*
It's very similar, but with a couple of changes.
1. It's now wrapped up inside SynthDef(\tri, {}).add;
2. We have this Out UGen
3. It doesn't make a sound when we run it

1.
- SynthDef tells the computer that this is a SynthDef
- The \tri bit at the beginning is the name for our SynthDef, this needs to be
  unique
- We don't store it in a variable, doing .add stores it in a global library for
  use later

2.
- The Out UGen is what connects our sound to our speakers
- It's first argument uses the argument out, which has the default value of 0
- This means use the first speaker (computer count from 0), if we set it to 1,
  it would be the right speaker


3.
We need to create a Synth from it, like so
*/
~tri = Synth(\tri, [\freq, 220, \mul, 0.05]);

/*
This creates a synth with specific values passed into the arguments, it's like calling .set straight away.

Now that we have this recipe, we can make 50 synths, all with different values
*/

50.do {
    Synth(\tri, [\freq, rrand(100, 5000), \mul, 0.01]);
}

/* Or make a nice, polyphonic synth by changing our noteOn MIDIdef */





/*
--------------------------
Variables inside SynthDefs
--------------------------

Often it's useful to use variables inside SynthDefs, as it can make code easier.

However, inside SynthDefs we don't use the tilde (~) symbol, instead we put the
word 'var' before it e.g.

*/

var level = 0.5;

/*
Here's an example of how it can make code much more readable
*/

SynthDef(\ugly, { |out=0|
    Out.ar(out,
        RLPF.ar(LFSaw.ar(MouseX.kr(110, 880), 0, MouseY.kr(0.2, 0)), 800, 0.2);
    );
}).add;

SynthDef(\pretty, { |out=0|
    var freq    = MouseX.kr(110, 880);
    var mul     = MouseY.kr(0.2, 0);
    var saw     = LFSaw.ar(freq, 0, mul);
    var filter  = RLPF.ar(saw, 800, 0.2);

    Out.ar(out,
        filter
    );
}).add;