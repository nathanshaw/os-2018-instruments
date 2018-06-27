// OSC time now
OscRecv orec;
//port 6449
6449 => orec.port;
orec.listen();

// FM synthesis instrument for O&S
SinOsc mod => blackhole;
SinOsc carrierSin => ADSR adsr => JCRev reverb => Gain output_gain => dac;
TriOsc carrierTri => adsr;
SawOsc carrierSaw => adsr;

0 => carrierSin.sync;
0 => carrierTri.sync;
0 => carrierSaw.sync;

1 => int selectedOsc;
0 => int SIN;
1 => int TRI;
2 => int SAW;

[0.06125, 0.125, 0.25, 0.5, 1.0, 1.25, 1.5, 2.0, 2.5, 4.0] @=> float freqRatios[];

1 => int GUI;
1000 => float cf;
cf => carrierSin.freq;
cf => carrierTri.freq;
cf => carrierSaw.freq;
80 => float mf;
mf => mod.freq;
200 => float index; //mod.gain;
0.5 => float MAX_GAIN => carrierSin.gain => carrierTri.gain => carrierSaw.gain;
MAX_GAIN => output_gain.gain;

// note stuff
[48.0, 50, 52.0, 55.0, 57.0, 60.0, 62.0, 64.0, 67.0, 69.0, 72.0] @=> float notes[];
for (int i; i < 10; i++) {
    notes[i] - 12 => notes[i];
}
3.5 => float freq_ratio;

// envelope
adsr.set(35::ms, 70::ms, 0.3, 600::ms);

//GUI
/*
MAUI_View view;
MAUI_Slider s_mod_gain, s_mod_freq, s_carrier_freq, s_output_gain, s_reverb_mix;
MAUI_Button b_play, b_cont;
view.size(800, 400);

65 => int s_height;
350 => int s_width;

s_reverb_mix.range(0.0, 1.0);
s_reverb_mix.size(s_width, s_height);
s_reverb_mix.position(0,0);
s_reverb_mix.value(0.0);
s_reverb_mix.name("Reverb Mix");
view.addElement(s_reverb_mix);

s_mod_gain.range(10, 500);
s_mod_gain.size(s_width, s_height);
s_mod_gain.position(s_reverb_mix.x(), s_reverb_mix.y() + s_reverb_mix.height());
s_mod_gain.value(200);
s_mod_gain.name("Modulator Gain");
view.addElement(s_mod_gain);

s_mod_freq.range(0.5, 1000);
s_mod_freq.size(s_width, s_height);
s_mod_freq.position(0, s_mod_gain.y() + s_mod_gain.height());
s_mod_freq.value(mf);
s_mod_freq.name("Modulator Frequency");
view.addElement(s_mod_freq);
view.display();

s_carrier_freq.range(0.5, 10000);
s_carrier_freq.size(s_width, s_height);
s_carrier_freq.position(0, s_mod_freq.y() + s_mod_freq.height());
s_carrier_freq.value(cf);
s_carrier_freq.name("Carrier Frequency");
view.addElement(s_carrier_freq);
view.display();

s_output_gain.range(0.0, 0.9);
s_output_gain.size(s_width, s_height);
s_output_gain.position(0, s_carrier_freq.y() + s_carrier_freq.height());
s_output_gain.value(0.7);
s_output_gain.name("Output Gain");
view.addElement(s_output_gain);

b_play.pushType();
b_play.size(s_output_gain.width(), s_output_gain.height());
b_play.position(s_output_gain.x(), s_output_gain.y() + s_output_gain.height());
b_play.name("Play Note");
view.addElement(b_play);

b_cont.toggleType();
b_cont.size(b_play.width(), b_play.height());
b_cont.position(b_play.x() + b_play.width(), b_play.y());
b_cont.name("Note Mode");
view.addElement(b_cont);

view.display();

spork ~ modGainSlider(s_mod_gain);
spork ~ modFreqSlider(s_mod_freq);
spork ~ carrierFreqSlider(s_carrier_freq);
spork ~ outputGainSlider(s_output_gain);
spork ~ reverbMixSlider(s_reverb_mix);
spork ~ playButton(b_play);
spork ~ contButton(b_cont);
<<<"Created GUI Components">>>;
*/


fun void quickFade (UGen ugen, float target) {
    float factor;
    
    if (target == 0.0){
        0.01 => target;
    }
    
    if (ugen.gain() > target){
        0.998 => factor;
    }
    else{
        1.002 => factor;
    }
    while(true){
        ugen.gain() * factor => ugen.gain;
        1::samp => now;
        if (factor > 1.0 && ugen.gain() > target){
            target => ugen.gain;
            break;
        }
        else if (factor < 1.0 && ugen.gain() < target){
            target => ugen.gain;
            break;
        }
    }
}


fun void oscEnvParameters() {
    orec.event("/envParameters,ffff") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getFloat() => float a;
            event.getFloat() => float d;
            event.getFloat() => float s;
            event.getFloat() => float r;
            a::ms => adsr.attackTime;
            d::ms => adsr.decayTime;
            s => adsr.sustainLevel;
            r::ms => adsr.releaseTime;
            <<<"a:",a,"d:",d,"s:",s,"r:",r>>>;
        }
    }         
}

fun void oscNoteOn() {
    orec.event("/noteOn,i") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => int note;
            Std.mtof(notes[note]) => float f;
            f => carrierSin.freq => carrierTri.freq => carrierSaw.freq;
            carrierSin.freq() * freq_ratio => mod.freq;
            // s_carrier_freq.value(carrier.freq());
            // s_mod_freq.value(mod.freq());
            adsr.keyOn();
        }
    }    
}

fun void oscNoteOff() {
    orec.event("/noteOff,i") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => int _trash;
            adsr.keyOff();
        }    
    }    
}

fun void oscFreqRatio() {
    orec.event("/frequencyRatio,i") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            freqRatios[event.getInt()] => freq_ratio;
            <<<"Freq Ratio Changed to ", freq_ratio>>>;
            carrierSin.freq() * freq_ratio => mod.freq;
        }    
    }    
}

fun void oscReverbMix() {
    orec.event("/reverbMix,f") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getFloat()/7 => float r_mix;
            <<<"Reverb Mix Changed to ", r_mix>>>;
            // s_reverb_mix.value(r_mix);
            r_mix => reverb.mix;
        }    
    }    
}

fun void triggerADSR(float a, float d){
    adsr.keyOn();
    (a + d)::ms => now;
    adsr.keyOff(); 
}

/*
fun void playButton(MAUI_Button b) {
    while(1) {
        b => now;
        adsr.keyOn();
        0.5::second => now;
        adsr.keyOff();
    }
}


fun void modGainSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => mod.gain;
    }
}

fun void modFreqSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => mod.freq;
    }    
}

fun void carrierFreqSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => cf;
        cf => carrier.freq;
        <<<"set carrier freq to :", s.value()>>>;
    }  
}

fun void outputGainSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => output_gain.gain;
    }  
}

fun void reverbMixSlider(MAUI_Slider s) {
    while(1){
        s => now;
        s.value() => reverb.mix;
    }  
}
*/

fun void oscMode() {
    orec.event("/mode,i") @=> OscEvent event;   
    while ( true )
    { 
        event => now; // wait for events to arrive.
        while( event.nextMsg() != 0 )
        { 
            event.getInt() => selectedOsc;
            <<<"Mode Changed to ", selectedOsc>>>;
            if (selectedOsc == SIN) {
                quickFade(carrierTri, 0.01);
                quickFade(carrierSaw, 0.01);
                quickFade(carrierSin, MAX_GAIN);
            }
            else if (selectedOsc == TRI) {
                quickFade(carrierSin, 0.01);
                quickFade(carrierSaw, 0.01);
                quickFade(carrierTri, MAX_GAIN);
            } else {
                quickFade(carrierTri, 0.01);
                quickFade(carrierSin, 0.01);
                quickFade(carrierSaw, MAX_GAIN);
            }
        }    
    }    
}

spork ~ oscMode();
spork ~ oscNoteOn();
spork ~ oscNoteOff();
spork ~ oscEnvParameters();
spork ~ oscFreqRatio();
spork ~ oscReverbMix();

while(true) {
    if (selectedOsc == SIN) {
        cf + (index * mod.last()) => carrierSin.freq;
    } else if (selectedOsc == TRI){
        cf + (index * mod.last()) => carrierTri.freq;    
    }
    else {
        cf + (index * mod.last()) => carrierSaw.freq;
    }
    1::samp => now;
}
