from pythonosc import udp_client
import argparse
import time
import sys
import random

def parseCommandLineArgs():
    """
    DO NOT REMOVE OR MODIFY THIS FUNCTION

    it allows for command line arguments to effect the code and is needed for the -v flag to work
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--test",
                        action="store_true", help="will enable test mode")
    parser.add_argument("-v", "--verbose",
                        action="store_true", help="will enable print statements")
    return parser.parse_args()

class Melody():
    """
    This is a class for holding different melodies
    The fact that its a class means that you can create multiple
    independent copits of it. Classes follow the convention of
    having the first letter of its name capitalize while instances
    of the class do not.
    """
    def __init__(self, notes=[0,1,3,2,3,0,5,1,4]):
        self.current_note = -1 # this keep tracks of which note we are currently on
        self.notes = notes
        self.length = len(notes)

    def nextNote(self):
        """ returns the next note in the melody"""
        self.current_note = (self.current_note + 1) % self.length
        return self.notes[self.current_note]

    def lastNote(self):
        """returns the note before the current note"""
        self.current_note = (self.current_note - 1)
        if self.current_note < 0:
            self.current_note = self.length
        return self.notes[self.current_note]

    def firstNote(self):
        """ plays the first note in the melody"""
        self.current_note = 0
        return self.notes[self.current_note]

    def repeatNote(self):
        """ plays the same note that was just played"""
        return self.notes[self.current_note]

def runTest():
    while True:
        attack = random.random()*100
        decay = random.random()*100
        sustain = random.random() * 0.6 + 0.1
        release = random.random()*100

        freq_ratio = random.randint(0,9)
        reverb_mix = random.random()


        if random.random() < 0.05:
            client.send_message("/envParameters", [attack, decay, sustain, release]);
            if args.verbose is True:
                print("envParameters: a:{} d:{} s:{} r{}".format(attack, decay,
                    sustain, release))

        if random.random() < 0.05:
            client.send_message("/freqRatio", freq_ratio)
            if args.verbose is True:
                print("changed freqRatio to :", freq_ratio)

        if random.random() < 0.05:
            client.send_message("/reverbMix", reverb_mix)
            if args.verbose is True:
                print("changed reverb mix to :", reverb_mix)

        if random.random() < 0.05:
            client.send_message("/mode", random.randint(0,2))
            if args.verbose is True:
                print("changed carrier mode")

        client.send_message("/noteOn", random.randint(0, 9))

        if args.verbose is True:
            sys.stdout.write("note on ")
            sys.stdout.flush()

        time.sleep(random.random())
        client.send_message("/noteOff", 1)

        if args.verbose is True:
            sys.stdout.write("note off \n")
            sys.stdout.flush()
        time.sleep(release/250)

if __name__ == "__main__":
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ########### DO NOT MODIFY THE CODE BETWEEN THESE LINES #################
    ip = "127.0.0.1"# the IP of whatever computer this program is running on
    # do not change this, it is required for OSC communication between
    # this program and python
    port = 6449
    client = udp_client.SimpleUDPClient(ip, port)
    args = parseCommandLineArgs()

    # current state of the instrument
    vel = (random.random()+2)/3
    note = random.randint(0, 8)
    verb = random.random()/3

    # run the test function if the -t flag is passed into the script
    if args.test == True:
        runTest()
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ########### DO NOT MODIFY THE CODE BETWEEN THESE LINES #################


    # this is a short example of how to use the Melody class
    # create some melodies (check out the class above)
    # the numbers correspond to the note numbers there can be any number
    melody1 = Melody([0, 2, 3, 1, 0, 5, 9, 8])# add, remove, or change the numbers in me
    melody2 = Melody([1, 5, 3, 6, 8, 0, 2, 1, 0, 0, 1j])
    # to start playing our melody call the firstNote() method
    note = melody1.firstNote()
    print(" lets play through our melody1 class")
    # then send the note to your instrument over OSC
    client.send_message("/noteOn", note) # the 1.0 is the velocity of our note
    time.sleep(0.25)# wait for a quarter second before continueing
    # the FM synth uses a ADSR envelope and needs to receive a note off to turn off
    client.send_message("/noteOff", note)
    time.sleep(0.25)# wait for a quarter second before continueing
    for i in range(1, melody1.length):
        note = melody1.nextNote()
        print("note: ", note)
        client.send_message("/noteOn", note)
        time.sleep(0.25)
        client.send_message("/noteOff", note)
        time.sleep(0.25)


    print("lets randomize our envelope parameters then climb down the scale")
    time.sleep(2.0)
    client.send_message("/envParameters", [random.random()*200, random.random()*200,
                                        random.random(), random.random()*100])
    for i in range(1, melody1.length):
        note = melody1.lastNote()
        print("note: ", note)
        client.send_message("/noteOn", note)
        time.sleep(0.25)
        client.send_message("/noteOff", note)
        time.sleep(0.25)

    print("Now lets randomize our envelope, and then play each note in our melody twice")
    time.sleep(2.0)
    client.send_message("/envParameters", [random.random()*200, random.random()*200,
                                        random.random(), random.random()*100])
    for i in range(1, melody1.length):
        note = melody1.nextNote()
        print("note: ", note)
        client.send_message("/noteOn", note)
        time.sleep(0.125)
        client.send_message("/noteOff", note)
        time.sleep(0.125)
        print("note: ", note)
        note = melody1.repeatNote()
        client.send_message("/noteOn", note)
        time.sleep(0.125)
        client.send_message("/noteOff", note)
        time.sleep(0.125)

    print("Now lets play a random note each time after randomizing our parameters again")
    time.sleep(2.0)
    client.send_message("/parameters", [random.random(), random.random(), random.random(), random.random()])
    for i in range(1, melody1.length*4):
        note = melody1.notes[random.randint(0, melody1.length-1)]
        print("note: ", note)
        client.send_message("/noteOn", note)
        time.sleep(0.06125)
        client.send_message("/noteOff", note)
        time.sleep(0.06125)

    print("now lets play the same note but change the frequencyRatio of the synth")
    time.sleep(2.0)
    for n in range(melody1.length-1):
        note = n
        print("note:", note)
        for i in range(0, 9):
            print("frequencyRatio: ", i)
            client.send_message("/frequencyRatio", i)
            client.send_message("/noteOn", note)
            time.sleep(0.125)
            client.send_message("/noteOff", note)
            time.sleep(0.125)

    print("lastly we will hold notes for long periods of time by not sending \
            a noteOff right away (with a random freqRatio each time")
    time.sleep(2.0)
    client.send_message("/frequencyRatio", 2)
    for i in range(1, melody1.length):
        note = melody1.nextNote()
        rand = random.randint(0,9)
        print("note: ", note)
        print("frequencyRatio: ", rand)
        client.send_message("/frequencyRatio", i)
        client.send_message("/noteOn", note)
        time.sleep(0.25 + random.randint(1,2))
        client.send_message("/noteOff", note)
        time.sleep(0.25)

    print("Program exiting....")


