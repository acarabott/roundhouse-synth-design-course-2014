// By Matthew Yee-King
// MykNetClock : MykClock {

//   >clock;

//   tick{
// 	// start any unstarted routines
// 	max_slots.do{arg i;
// 	  if (pending[i] == 1, {
// 		// got a pending routine
// 		routs[i].play(clock, quant:1);
// 		pending[i] = nil;
// 	  });
// 	}
//   }
// }

MykClock : Object {
  var
  <>interval,
  ticker,
  routs,
  pending,
  max_slots = 100;

  *new{arg interval = 0.5;
	^super.newCopyArgs(interval).prInit;
  }

  prInit{
	// stores playback routines
	routs = Array.newClear(max_slots);
	// stores the states of the routines
	pending = Array.newClear(max_slots);
  }
  // add a function to the clock
  // index - where to add the function
  // beats - an array of beat intervals for the function
  // delay - how long after the start of a bar to wait before triggering the function (in beats).
  add{arg index=0, task={"test ".postln}, beats=[1], seq=[1], delay=0, linear = 1;
	var server;
	server = Server.local;
	if (index >(max_slots - 1),
	  {("warning - only "++(max_slots)++" slots available").postln},
	  {
		// kill the old one if needed
		if (routs[index] != nil, {this.remove(index)});
		routs[index] = Routine.new{
		  (delay * interval).wait;
		  inf.do{
			// use seq as a probability of playing at this time
			//("coining "++seq[0]).postln;
			if(seq[0].coin, {
			  // if you are reading, this, i broke my clock... for forks sake!
			  {server.makeBundle(0.02,{task.value})}.fork;
			  //server.makeBundle(0.02,{task.value});
			});
			seq = seq.rotate(-1);
			if (linear == 0,
			  {(beats.choose * interval).wait;},
			  {beats = beats.rotate(-1);
				(beats[0] * interval).wait;}
			);
		  };
		};
		pending[index] = 1;
	  });
  }

  remove{arg index;
	routs[index].stop;
	routs[index] = nil;
	pending[index] = nil;
  }

  run{
	ticker = Routine.new{
	  inf.do{
		this.tick;
		interval.wait;
	  };
	}.play;
  }

  stop{
	ticker.stop;
  }

  bpm{arg bpm = 120;
	// convert bpm to an interval in seconds
	interval = 60/bpm;
  }

  tick{
	// start any unstarted routines
	max_slots.do{arg i;
	  if (pending[i] == 1, {
		// got a pending routine
		routs[i].play;
		pending[i] = nil;
	  });
	}
  }
}