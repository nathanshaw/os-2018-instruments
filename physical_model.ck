// Physical model instrument for O&S
Mandolin mand[3];
ModalBar mod[3];

mand[0] => NRev reverb => Gain gain => dac;
mand[1] => reverb;
mand[2] => reverb;
mod[0] => reverb;
mod[1] => reverb;
mod[2] => reverb;

0 => int lastPlayed;

0 => int playMode;
0 => int MELODY;
1 => int HARMONY;

0 => int instrumentMode;//corresponds to the mandolin=0 or ModelBar=1
0 => int MANDOLIN;
1 => int MODAL_BAR;

0.1 => gain.gain;

0.1 => float reverbMix => reverb.mix;

[48.0, 50, 52.0, 55.0, 57.0, 60.0, 62.0, 64.0, 67.0, 69.0, 72.0] @=> float notes[];

[[48.0, 52.0, 55],//c3M I 5/3
[50.0, 53.0, 57.0],//d3m II 5/3
[55.0, 59.0, 62.0],//gM V 5/3
[52.0, 55.0, 60.0],//c inversion 1 - I 6/3
[53.0, 57.0, 62.0],//d inversion 1 - II 6/3
[59.0, 62.0, 67.0],//g inversion 1 - V 6/3
[55.0, 60.0, 64.0],//c inversion 2 - I 
[53.0, 57.0, 60.0],//f root position - IV
[62.0, 67.0, 71.0],//g inversion 2
[48.0, 60.0, 67.0]] @=> float chords[][];//c open

// set some random default parameters for the ModalBar
Math.random2f(0, 1.0) => float stickHardness;
Math.random2f(0, 1.0) => float strikePosition;
Math.random2f(0, 600.0) => float vibrato;

// set some random default parameters for the Mandolin
Math.random2f(0, 1.0) => float pluckPos;
Math.random2f(0, 1.0) => float stringDamp;
Math.random2f(0, 1.0) => float detune;

// what is our current note and our current frequency
float freqs[3];
48.0 => float note;
Std.mtof(note) => freqs[0] => freqs[1] => freqs[2];

// OSC
OscRecv orec;
//port 6449
6449 => orec.port;
orec.listen();


fun void randomizeParameters() {
    if (instrumentMode == MANDOLIN){
        Math.random2f(0, 1.0) => pluckPos;
        Math.random2f(0, 1.0) => stringDamp;
        Math.random2f(0, 1.0) => detune;
        for (int i; i < 3; i++) {
            mand[i].pluckPos(pluckPos);
            mand[i].stringDamping(stringDamp);
            mand[i].stringDetune(detune);  
        }
    } else {
        // set some random default parameters for the ModalBar
        Math.random2f(0, 1.0) => stickHardness;
        Math.random2f(0, 1.0) => strikePosition;
        Math.random2f(0, 600.0) => vibrato;
        for (int i; i < 3; i++) {
            mod[i].stickHardness(stickHardness);
            mod[i].strikePosition(strikePosition);
            mod[i].vibratoGain(vibrato);
            mod[i].vibratoFreq(vibrato);
        }
    }
}


fun void oscPlay() {
    orec.event("/noteOn,if") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => int _index;
            event.getFloat() => float _vel;
            
            if (playMode == MELODY) {
                if (_index >= 0 && _index <= notes.size()-1){
                    Std.mtof(notes[_index]) => freqs[lastPlayed];
                }
                // <<<"note on , ", _index, " at velocity: ", _vel, " freq: ", freqs[lastPlayed]>>>;
                
                if (instrumentMode == MANDOLIN) {            
                    freqs[lastPlayed] => mand[lastPlayed].freq;
                    mand[lastPlayed].pluck( _vel );  
                }
                else{
                    freqs[lastPlayed] => mod[lastPlayed].freq;
                    mod[lastPlayed].strike( _vel );
                }
            } else {
                if (_index >= 0 && _index <= chords.size()-1){
                    for (0 => int i; i < 3; i++){ 
                        Std.mtof(chords[_index][i]) => freqs[i];
                    }
                }
                <<<"Chord - ", _index, " at velocity: ", _vel>>>;
                if (instrumentMode == MANDOLIN) {
                    for (0 => int i; i < 3; i++){        
                        freqs[i] => mand[i].freq;
                        mand[i].pluck( _vel );  
                    }
                }
                else{
                    for (0 => int i; i < 3; i++){    
                        freqs[i] => mod[i].freq;
                        mod[i].strike( _vel );
                    }
                }
            }
        }
        (lastPlayed + 1) % 3 => lastPlayed;
    }         
}


fun void oscChangeParameters() {
    orec.event("/parameters,ffff") @=> OscEvent event;  // pluck pos, damping, detune 
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            if (instrumentMode == MANDOLIN) {
                event.getFloat() => pluckPos;
                event.getFloat() => stringDamp;
                event.getFloat() => detune;
                event.getFloat()/7 => reverbMix;
                
                <<<"pos: ", pluckPos, " damp:", stringDamp, " detune:", detune, " verbMix:", reverbMix>>>;
                mand[lastPlayed].pluckPos( pluckPos);
                mand[lastPlayed].stringDamping( stringDamp );
                mand[lastPlayed].stringDetune( detune );
                reverb.mix(reverbMix);
            }
            else {
                event.getFloat() => strikePosition;
                event.getFloat() => stickHardness;
                event.getFloat() => vibrato;
                event.getFloat()/7 => reverbMix;
                
                <<<"pos: ", strikePosition, " hardness:", stickHardness, " vibrato:", vibrato, " verbMix:", reverbMix>>>;
                mod[lastPlayed].strikePosition(strikePosition);
                mod[lastPlayed].stickHardness(stickHardness);
                mod[lastPlayed].vibratoGain(vibrato);
                vibrato * 600 => vibrato;
                mod[lastPlayed].vibratoFreq(vibrato);
                reverb.mix(reverbMix);
            }
        }
    }         
}


fun void oscChangeInstrument() {
    // listens for OSC messages which change the instrument type
    orec.event("/instrument,i") @=> OscEvent event;
    while (true) {
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => instrumentMode;
            <<<"instrumentMode Changed: ", instrumentMode>>>;
        }  
    }
}


fun void oscChangePlayMode() {
    // listens for OSC messages which change the instrument type
    orec.event("/playMode,i") @=> OscEvent event;
    while (true) {
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => playMode;
            <<<"playMode Changed: ", playMode>>>;
        }  
    }
}


// start listening for OSC messages
spork ~ oscChangePlayMode();
spork ~ oscChangeInstrument();
spork ~ oscPlay();
spork ~ oscChangeParameters();


while (1) {
    // gots to pass time or MA crashes
    1::second => now;
}
