from pythonosc import osc_message_builder
from pythonosc import udp_client
import time
import random

if __name__ == "__main__":
    ip = "127.0.0.1"
    port = 6449

    client = udp_client.SimpleUDPClient(ip, port)

    while True:
        pluck_pos = random.random()
        damping = random.random()
        detune = random.random()
        vel = random.random()
        client.send_message("/parameters", [pluck_pos, damping, detune])
        client.send_message("/pluck", vel);
        print("plucking now : vel:{} pos:{} damp:{} detune{}".format(
            vel, pluck_pos, damping, detune))
        time.sleep(1.0)
