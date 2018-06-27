SndBuf snare => Gain master_gain => dac;
SndBuf kick => master_gain => dac;
SndBuf click => master_gain => dac;
SndBuf hh => master_gain => dac;


string kickFilenames[3];
me.dir() + "/samples/kick_01.wav" =>  kickFilenames[0];
me.dir() + "/samples/kick_02.wav" =>  kickFilenames[1];
me.dir() + "/samples/kick_03.wav" =>  kickFilenames[2];
kickFilenames[2] => kick.read;
kick.samples() => kick.pos;

string snareFilenames[3];
me.dir() + "/samples/snare_01.wav" =>  snareFilenames[0];
me.dir() + "/samples/snare_02.wav" =>  snareFilenames[1];
me.dir() + "/samples/snare_03.wav" =>  snareFilenames[2];
snareFilenames[2] => snare.read;
snare.samples() => snare.pos;

string clickFilenames[3];
me.dir() + "/samples/click_01.wav" =>  clickFilenames[0];
me.dir() + "/samples/click_02.wav" =>  clickFilenames[1];
me.dir() + "/samples/click_03.wav" =>  clickFilenames[2];
clickFilenames[2] => click.read;
click.samples() => click.pos;

string hhFilenames[3];
me.dir() + "/samples/hh_01.wav" =>  hhFilenames[0];
me.dir() + "/samples/hh_02.wav" =>  hhFilenames[1];
me.dir() + "/samples/hh_03.wav" =>  hhFilenames[2];
hhFilenames[2] => hh.read;
hh.samples() => hh.pos;

0.5 => float MAX_GAIN => snare.gain => kick.gain => hh.gain => click.gain => master_gain.gain;
120 => float bpm;
((60/bpm)/2)::second => dur noteLength; // /2 b/c we are working with eight notes

// determis if each drum is muted or not
[0,0,0,0] @=> int isMuted[];

// the different patterns or sequences
[
[1,0,0,0, 1,0,0,0],
[0,1,0,0, 0,1,0,1],
[1,1,1,0, 1,1,1,0],
[0,0,0,1, 0,0,0,1],
[1,0,1,0, 1,0,1,0],
[0,0,0,1, 0,0,0,1],
[1,0,0,1, 0,1,0,1],
[0,1,1,0, 0,1,1,0],
[0,0,1,0, 0,0,1,0],
[1,1,1,1, 1,1,1,1]
] @=> int patterns[][];

patterns[0] @=> int kickPattern[];
patterns[1] @=> int snarePattern[];
patterns[2] @=> int hhPattern[];
patterns[3] @=> int clickPattern[];

// OSC
OscRecv orec;
//port 6449
6449 => orec.port;
orec.listen();

fun void oscLoadSamples() {
    orec.event("/samples,iiii") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => int kIndex;   
            kickFilenames[kIndex] => kick.read;
            
            event.getInt() => int sIndex;
            snareFilenames[sIndex] => snare.read;
            
            event.getInt() => int hIndex;
            hhFilenames[hIndex] => hh.read;
            
            event.getInt() => int cIndex;
            clickFilenames[cIndex] => click.read;
            
            <<<"changing samples : ", kIndex, kIndex, hIndex, cIndex>>>;
        }
    }         
}

fun void oscMuteDrums() {
    orec.event("/mutes,iiii") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while(event.nextMsg() != 0)
        { 
            for (int i; i < 4; i++) {
                event.getInt() => int temp;
                temp => isMuted[i];
            }
            <<<"mutes: ", isMuted[0], isMuted[1], isMuted[2], isMuted[3]>>>;
        }
    }         
}
/*
fun void oscPlayDrum() {
    orec.event("/play,s") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getString() => string type;
            // <<<"playing drum: ", type>>>;
            if (type == "hh" || type == "h") {
                0 => hh.pos;
            }
            else if (type == "click" || type == "c") {
                0 => click.pos;
            }
            else if (type == "kick" || type == "k") {
                0 => kick.pos;
            }
            else if (type == "snare" || type == "s") {
                0 => snare.pos;
            }
        }
    }         
}
*/
fun void oscSetPatterns() {
    orec.event("/patterns,iiii") @=> OscEvent event;
    while (true) {
        event => now;
        while(event.nextMsg() != 0) {
            event.getInt() => int kP;
            event.getInt() => int sP;
            event.getInt() => int hP;
            event.getInt() => int cP;
            patterns[kP] @=> kickPattern;
            patterns[sP] @=> snarePattern;
            patterns[hP] @=> hhPattern;
            patterns[cP] @=> clickPattern;
            <<<"patterns: ", kP, sP, hP, cP>>>;
        }   
    } 
}

fun void oscCustomPattern() {
    orec.event("/replacePattern,iiiiiiiii") @=> OscEvent event;
    while (true) {
        event => now;
        while(event.nextMsg() != 0) {
            event.getInt() => int patternIndex;
            for (int i; i < 8; i++){
              event.getInt() => patterns[patternIndex][i];   
            }
            <<<"loaded custom pattern ", patternIndex>>>;
            for (int i; i < 8; i++){
                <<<patterns[patternIndex][i]>>>;
            }
        }   
    } 
}

fun void playBeat(int beat) {
    if (kickPattern[beat] == 1 && isMuted[0] == 0) {
        0 => kick.pos;
    }
    if (snarePattern[beat] == 1 && isMuted[1] == 0) {
        0 => snare.pos;
    }
    if (hhPattern[beat] == 1 && isMuted[2] == 0) {
        0 => hh.pos;
    }
    if (clickPattern[beat] == 1 && isMuted[3] == 0) {
        0 => click.pos;
    }  
}

fun void oscSetBPM() {
    orec.event("/bpm,f") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getFloat() => bpm;
            (60/bpm)::second => noteLength;
            <<<"set bpm to:", bpm>>>;
        }
    }    
}

spork ~ oscMuteDrums();
spork ~ oscSetBPM();
// spork ~ oscPlayDrum();
spork ~ oscLoadSamples();
spork ~ oscSetPatterns();
spork ~ oscCustomPattern();

0 => int beat;
8 => int beatsPerMeasure;
while (true) {
    <<<"beat : ", beat+1,"/ 8">>>;
    playBeat(beat);
    noteLength => now;
    (beat + 1) % beatsPerMeasure => beat;
}
