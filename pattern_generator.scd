
(
var envdur;
~start = 3456;
envdur = ~start /44100 -0.02; //-0.5;
~env = Env.asr(attackTime:0.02,sustainLevel:1,releaseTime:envdur,curve:\lin);
)
~env.plot

~steps = Array.fill(16, { '\rest' });

~steps = [ 200, \rest, 200, \rest ];
~sequence = PatternProxy(Pn(Pseq(~steps, 16), inf));

(
~mypat = Pbind(
//	\freq, Pseq([ 200, \rest, 200, \rest ],inf),
	\freq, ~sequence,
	\dur , Pseq([0.5], inf)
).play;
)

~steps = Array.fill(16, { '\rest' });

~sequence.source = PatternProxy(Pn(Pseq(~steps, 16), inf));

~steps[1] = 200;
~mypat.play;

~steps = ~steps.replace('\rest', 200);
~steps.put(1, \rest);

~currentFile = "~/x3dLooper/x3dL_default.aiff";
~currentFile = "/Volumes/ssdData/infiniteorchestra/convertedwav/11652.wav";
~playBuff = Buffer.read(s, ~currentFile.standardizePath, 0);
~playBuff = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
// same of x3dlooper
SynthDef(\play, {| outBus = 0, bufnum, start = 0, loop = 0, panpot = 0 |
	var source, out, env, envdur;
	envdur = start / 44100 - 0.02 - 0.5;
	env = Env.asr(attackTime:0.02,sustainLevel:1,releaseTime:envdur,curve:\lin);
	source = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), 1, start, loop, doneAction:2) *
	EnvGen.ar(env);
	out = Pan2.ar(source, panpot);
    Out.ar(outBus, out)
}).send(s);
// specific OSC receiver
OSCdef(\getstep, {|msg, time, addr, port|
	if (msg[1]==1) {
		var stp = ~clockstep;
		~clockstep.postln;
		~steps.put(stp, 400);
	};
 },
	'/jXcontrol/1'
);
~steps = Array.fill(16, { '\rest' });
~steps.put(0, 200);
~stepnum = 16;
~stepdur = 0.1; // seconds
~sequence = PatternProxy(Pn(Pseq(~steps, 16), inf));
~stepdurseq = PatternProxy(Pn(Pseq([~stepdur], inf)), inf);
~playBuffpx = PatternProxy(~playBuff);
~mypat = Pbind(
	\instrument, \play,
	\bufnum, ~playBuffpx,
	\freq, ~sequence,
	\dur , ~stepdurseq
);
// task that act as a clock sync
~clocker = Task({
	// start the pattern HERE!
	~ppp = ~mypat.play;
	inf.do{|idx|
		("[PATTERN]:"++idx).postln;
		~clockstep = 0;
		~stepnum.do{|stp|
			~clockstep = stp;
			("[STEP]:"++stp).postln;
			~stepdur.wait;
		}
	}
});
)
~clocker.start;
// stop everything (pattern and task
~clocker.stop; ~ppp.stop;

(
// change the pattern speed
~stepdur = 0.1;
~stepdur = ~bpm2sec.value(80.0)
~stepdurseq.source = PatternProxy(Pn(Pseq([~bpm2sec.value(80.0)], inf)), inf);
)
(
// change current sample
~currentFile = "/Volumes/ssdData/infiniteorchestra/convertedwav/11652.wav";
~playBuff = Buffer.read(s, ~currentFile.standardizePath, 0);
~playBuffpx.source = PatternProxy(~playBuff);
)

// convert BPM in seconds and divide by 2(semicrome value) while bpm refere to beats(crome)
~bpm2sec = {|bpm|
	var sec;
	sec = (60.0 / bpm); // bpm riferito alle crome/ritorna la durata di una semicroma
};
~bpm2sec.value(120.0)