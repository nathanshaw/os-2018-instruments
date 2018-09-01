from pythonosc import udp_client
import argparse
import time
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
    parser.add_argument("-m", "--mac",
                        action="store_true", help="will run on mac")
    return parser.parse_args()

def runTest():
    # a While True loop will execute the code held within over and over again forever
    while True:
        current_instrument = MANDOLIN
        current_mode = MELODIC
        pluck_pos = random.random()# random.random() returns a number between 0 and 1
        damping = random.random()
        detune = random.random()
        verb = random.random()/3# this will return a number between 0 and 0.333333
        vel = (random.random()+2)/3# this will return a number between 0.666 and 1
        note = random.randint(0, 10)# this will return a whole number between 0 and 10
        client.send_message("/parameters", [pluck_pos, damping, detune, verb])
        client.send_message("/play", [note, vel]);
        if random.random() < 0.07:
            if current_instrument == 0:
                current_instrument = 1
            else:
                current_instrument = 0
            client.send_message("/instrument", current_instrument)
            if args.verbose is True:
                print("changed instrument")
        if random.random() < 0.07:
            if current_mode == 0:
                current_mode = 1
            else:
                current_mode = 0
            client.send_message("/mode", current_mode)
            if args.verbose is True:
                print("changed playMode")
        if args.verbose is True:
            print("note:{} vel:{} pos:{} damp:{} detune:{} verb:{}".format(
            note, vel, pluck_pos, damping, detune, verb))
        time.sleep(0.2)

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
            self.current_note = self.length-1
        return self.notes[self.current_note]

    def firstNote(self):
        """ plays the first note in the melody"""
        self.current_note = 0
        return self.notes[self.current_note]

    def repeatNote(self):
        """ plays the same note that was just played"""
        return self.notes[self.current_note]

def melodyTutorial():
    # this is a short example of how to use the Melody class
    # create some melodies (check out the class above)
    # the numbers correspond to the note numbers there can be any number
    melody1 = Melody([0, 2, 3, 1, 0, 5, 9, 4,])
    # you can create as many instance of melody as you want!
    # melody2 = Melody([1, 5, 3, 6, 0, 2, 1, 0, 0, 1])
    # to start playing our melody call the firstNote() method
    print("lets explore the melody1 class we made")
    note = melody1.firstNote()
    print("note: ", note)
    # then send the note to your instrument over OSC
    client.send_message("/noteOn", [note, 1.0]) # the 1.0 is the velocity of our note
    time.sleep(0.5)# wait for a half a second before continueing
    # now lets play through the rest of the melody
    for i in range(0, melody1.length):
        note = melody1.nextNote()
        print("note: ", note)
        client.send_message("/noteOn", [note, 1.0])
        time.sleep(0.5)

    time.sleep(2.0)

    print("lets randomize our MANDOLIN's parameters and then play the melody in reverse")
    client.send_message("/parameters", [random.random(), random.random(), random.random(), random.random()])
    for i in range(0, melody1.length):
        note = melody1.lastNote()
        print("note: ", note)
        client.send_message("/noteOn", [note, 1.0])
        time.sleep(0.5)

    time.sleep(2.0)

    print("lets change our instrument to the MODALBAR and randomize the parameters")
    client.send_message("/instrument", MODALBAR)
    client.send_message("/parameters", [random.random(), random.random(), random.random(), random.random()])
    # we can play each note twice
    for i in range(0, melody1.length):
        note = melody1.nextNote()
        print("note: ", note)
        client.send_message("/noteOn", [note, 1.0])
        time.sleep(0.25)
        note = melody1.repeatNote()
        print("note: ", note)
        client.send_message("/noteOn", [note, 1.0])
        time.sleep(0.25)

    time.sleep(2.0)

    print("lets randomize our parameters again and then play random notes from the melody")
    client.send_message("/parameters", [random.random(), random.random(), random.random(), random.random()])
    for i in range(0, melody1.length*4):
        note = melody1.notes[random.randint(0, melody1.length-1)]
        print("note: ", note)
        client.send_message("/noteOn", [note, 1.0])
        time.sleep(0.33)

    print("now lets switch to the HARMONIC mode and play all the available chords")
    play_mode = HARMONIC
    client.send_message("/playMode", play_mode)
    for i in range(0, 9):
        chord = i
        print("chord: ", chord)
        client.send_message("/noteOn", [chord, 1.0])
        time.sleep(0.5)


# the code within this if statement is what is run when the program is called
# from the command line
#
# Remember that Python programs start from the bottom and work upwards
if __name__ == "__main__":
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ########### DO NOT MODIFY THE CODE BETWEEN THESE LINES #################
    args = parseCommandLineArgs()
    ip = "127.0.0.1"# the IP of whatever computer this program is running on
    # do not change this, it is required for OSC communication between

    # this program and python
    port = 6449
    client = udp_client.SimpleUDPClient(ip, port)

    # these allow us to use MANDOLIN instead of 0 when sending /instrument messages
    MANDOLIN = 0 # variables which are all-caps usually signify constants
    MODALBAR = 1 # constants do not change their value when the program is running
    MELODIC = 0
    HARMONIC = 1

    # sets random values for  our instruments parameters
    # for mandolin
    pluck_pos = random.random()
    damping = random.random()
    detune = random.random()
    # for modal bar
    strikePosition = random.random()
    stickHardness = random.random()
    vibratoFreq = random.random()

    # for both
    vel = (random.random()+2)/3
    note = random.randint(0, 8)
    verb = random.random()/3

    ####### Variables to keep track of your Physical Model
    current_instrument = MANDOLIN
    client.send_message("/instrument", current_instrument) # making sure we are using the current instrument
    play_mode = MELODIC
    client.send_message("/playMode", play_mode)

    # run the test function if the -t flag is passed into the script
    if args.test == True:
        runTest()

    ########### DO NOT MODIFY THE CODE BETWEEN THESE LINES #################
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ########### WRITE YOUR CODE BELOW THIS LINE ############################

    # comment out the line below by adding # before it after you understand how to use the Melody Class
    melodyTutorial()
