from pythonosc import udp_client
import argparse
import time
import random

def changeBPM(bpm):
    client.send_message("/bpm", float(bpm))

def changeMutes(mutes):
    # do some testing before we send the message
    if type(mutes) is not list:
        print("you have to pass a list [] into the changeMutes() function, not sending message")
        return
    elif len(mutes) != 4:
        print("you have to pass a list [] that has 4 integers into the changeMutes() function inside e.g. [1,0,1,0]")
        return
    for mute in mutes:
        if mute is not 0 and mute is not 1:
            print("please pass either a 0 for audable or 1 for muted into the changeMutes() function")
            return

    # send message
    client.send_message("/mutes", (mutes[0], mutes[1], mutes[2], mutes[3]))

def changeSamples(samples):
    # do some testing before we send the message
    if type(samples) is not list:
        print("you have to pass a list [] into the changeSamples function, not sending message")
        return
    elif len(samples) != 4:
        print("you have to pass a list that has 4 integers into the changeSamples function inside e.g. [1,0,1,2]")
        return
    for samp in samples:
        if samp < 0 or samp > 3:
            print("There are only 3 samples for each drum channel, you must have a 0, 1 or 2 for each of your values passed into changeSamples")
            return

    # send message
    client.send_message("/samples", (int(samples[0]),
                        int(samples[1]), int(samples[2]), int(samples[3])))

def changePatterns(patterns):

    client.send_message("/patterns", (patterns[0],
                        patterns[1], patterns[2], patterns[3]))

def replacePattern(patternNum, pattern):
        # note that this message take 9 values
        client.send_message("/replacePattern", (patternNum, pattern[0],
            pattern[1], pattern[2], pattern[3], pattern[4], pattern[5],
            pattern[6], pattern[7]))

def runTest():
    while True:
        bpm = (random.random() * 200 ) + 20

        # randomly change a pattern mapping in the sequencer

        # randomly choose a sample for each dum
        for i in range(0,4):
            temp = random.randint(0,2)
            samples[i] = temp

        # randomly choose a pattern for each dum
        for i in range(0,4):
            temp = random.randint(0,9)
            patterns[i] = temp

        # 30% chance to mute a random drum part
        for i in range(0,4):
            if random.random() < 0.3:
                mutes[i] = 1
            else:
                mutes[i] = 0

        changeBPM(bpm)
        changeSamples(samples)
        changeMutes(mutes)
        changePatterns(patterns)
        replacePattern(random.randint(0,9), custom_patterns[0])
        time.sleep(10)

def parseCommandLineArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose",
                        action="store_true", help="will enable print statements")
    parser.add_argument("-t", "--test",
                        action="store_true", help="will run the test")
    return parser.parse_args()

if __name__ == "__main__":
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ########### DO NOT MODIFY THE CODE BETWEEN THESE BLOCKS #################
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ip = "127.0.0.1"# the IP of whatever computer this program is running on
    # do not change this, it is required for OSC communication between
    # this program and python
    port = 6449
    client = udp_client.SimpleUDPClient(ip, port)
    args = parseCommandLineArgs()

    # these variables are used to keep track of the current state of your drum machine
    # you should map the inputs from your sensors to these values and then send them to
    # the drum machine. If you directly send values from your sensors then this program
    # does not know what the drum machine is doing
    samples = [2,2,2,2]
    bpm = 120
    patterns = [0,1,2,3]
    mutes = [0,0,0,0]

    # these allow you to say KICK instead of 0
    drum_types = ["kick", "snare", "hh", "click"]
    KICK = 0
    SNARE = 1
    HH = 2
    CLICK = 3

    # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    ########### DO NOT MODIFY THE CODE BETWEEN THESE BLOCKS #################
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    # CUSTOMIZE THESE NUMBERS! (0 or 1 only)
    # add more if you want!
    custom_patterns = []
    custom_patterns.append([0,0,0,0, 1,1,1,1])
    custom_patterns.append([0,0,0,0, 1,1,1,1])
    custom_patterns.append([0,0,0,0, 1,1,1,1])
    custom_patterns.append([0,0,0,0, 1,1,1,1])
    custom_patterns.append([0,0,0,0, 1,1,1,1])
    custom_patterns.append([0,0,0,0, 1,1,1,1])
    custom_patterns.append([0,0,0,0, 1,1,1,1])

    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    ########### DO NOT MODIFY THE CODE BELOW THIS BLOCK #################
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # if the -t flag is sent in run the test function
    if args.test == True:
        runTest()
