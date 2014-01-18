/* ============================================================ */
/* SuperCollider                                                */
/* ============================================================ */

/*

SuperCollider is a powerful programming language for music and audio

Pros:
   - Code based: extremely flexible and powerful, you can and use music and tools that are not
        possible in traditional software
   - Make your own sounds, rather than using synths and presets designed by other people
   - Designed for real-time; quicker and more dynamic than languages like C++
   - Can interface with all sorts of equipment: iPhones, MIDI, light sensors, custom hardware
   - Gives you a better understanding of how your sounds are made
   - You will learn the basic of programming, which can be applied to any discipline

Cons:
   - Code based: the computer is stupid and will reject syntax errors and typos
   - Can be frustrating to have to deal with programming problems when you have a specific
        musical idea
   - Not straightforward to integrate into traditional workflow
*/






/* ============================================================ */
/* The SuperCollider IDE                                        */
/* ============================================================ */

/*
The program you are running now (SuperCollider.app) is an IDE or Integrated Development Environment.

The window you are reading this from is called the Document Window, it is where you will write and run code.

To the left you can see the Post Window, this is where the output of your code is shown

To the right is the Help Window, this is where all the help files and documentation live

*/

/* ------------- */
/* Running Code  */
/* ------------- */

/*
To run code you put the blinking cursor on the line using the arrow keys or mouse and press

"cmd enter"

try it on the line below, you will see the result in the Post Window
*/

"Hello World!".postln;

/* ------------- */
/* Writing Code  */
/* ------------- */

/*
Code is written in plain text files like this, in SuperCollider we save them with the .scd extension instead of .txt, this lets the operating system know that it should be opened with SuperCollider and not with TextEdit.

Text that is after two slashes
// like this

or between these symbols
/* like this */

is a comment, it is ignored by the computer, it is for your own notes, everything else is exectuable code.

Run these lines
*/

4 + 4;
100 * 100;
"I am a string" + "and another string";

/*
You can highlight multiple lines of code and run them at once, try this on the code below.
*/
"First line".postln;
("line" + (1+1)).postln;
"line number: " + pi;

/* ------------------------- */
/* Clearing the Post Window  */
/* ------------------------- */

/*
To clear the Post Window press

cmd shift p

*/

/* ------------------------- */
/* Getting Help              */
/* ------------------------- */

/*
To get Help for a particular item, select the word and press

cmd d

Try it on this word:

SinOsc

This should open the helpfile for the Sine Wave Generator
*/