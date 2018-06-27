from pythonosc import udp_client
import argparse
import time
import random

# music stuff
KICK = 0
SNARE = 1
HH = 2
CLICK = 3

drum_types = ["kick", "snare", "hh", "click"]

def parseCommandLineArgs():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose",
                        action="store_true", help="will enable print statements")
    parser.add_argument("-t", "--test",
                        action="store_true", help="will run the test")
    return parser.parse_args()

if __name__ == "__main__":
    ip = "127.0.0.1"
    port = 6449

    client = udp_client.SimpleUDPClient(ip, port)

    args = parseCommandLineArgs()

    # these variables are used to keep track of the current state of your drum machine
    # you should map the inputs from your sensors to these values and then send them to
    # the drum machine. If you directly send values from your sensors then this program
    # does not know what the drum machine is doing
    current_samples = [2,2,2,2]
    current_bpm = 120
    current_patterns = [0,1,2,3]
    current_mutes = [0,0,0,0]

    if args.test == False:
        while True:
            # put your code in here after deleting the time.sleep(10) line
            time.sleep(10)
    else:
        while True:
            current_mode = random.randint(0,2)
            current_bpm = (random.random() * 200 ) + 20

            # randomly change a pattern mapping in the sequencer

            # randomly choose a sample for each dum
            for i in range(0,4):
                temp = random.randint(0,2)
                current_samples[i] = temp

            # randomly choose a pattern for each dum
            for i in range(0,4):
                temp = random.randint(0,9)
                current_patterns[i] = temp

            # 30% chance to mute a random drum part
            for i in range(0,4):
                if random.random() < 0.3:
                    current_mutes[i] = 1
                else:
                    current_mutes[i] = 0

            client.send_message("/bpm", (random.random()*200 + 20))
            client.send_message("/samples", (current_samples[0],
                                current_samples[1], current_samples[2], current_samples[3]))
            client.send_message("/patterns", (current_patterns[0],
                                current_patterns[1], current_patterns[2], current_patterns[3]))
            client.send_message("/mutes", (current_mutes[0], current_mutes[1], current_mutes[2], current_mutes[3]))
            client.send_message("/replacePattern", (random.randint(0,9),random.randint(0,1),random.randint(0,1),random.randint(0,1),
                random.randint(0,1),random.randint(0,1),random.randint(0,1),random.randint(0,1),random.randint(0,1)))
            time.sleep(10)
