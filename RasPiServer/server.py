from __future__ import print_function
from time import sleep
import aiy.voicehat as voicehat
import aiy.audio as audio
import requests

led = voicehat.get_led()
button = voicehat.get_button()
url = "http://192.168.2.1:8888"

from bottle import route, run

@route('/')
def index():
    return 'Hello, world'

@route('/lastspurt')
def lastspurt():
    audio.play_wave("/home/pi/Projects/he.wav")
    return 'lastspurt'

@route('/finish')
def finish():
    audio.play_wave("/home/pi/Projects/clap_mono.wav")
    return 'finish'

def _on_button_pressed():
    requests.get(url + "/start") 
    led.set_state(voicehat.LED.ON)
    sleep(0.01)
    audio.play_wave("/home/pi/Projects/he.wav")
    led.set_state(voicehat.LED.OFF)

if __name__ == "__main__":
    led.set_state(voicehat.LED.OFF)
    button.on_press(_on_button_pressed)

    run(host='localhost', port=8888)

    #while True:
    #    pass
