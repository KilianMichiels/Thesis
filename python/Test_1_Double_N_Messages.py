# -*- coding: utf-8 -*-
'''
ROS: Simuleer 1 Double die N ROS berichten verzendt. Wat gebeurt er?
    Hoe?
        Obj-C script, for loop van N berichten op (1) verschillende (random) of (2) hetzelfde topic.
        Tegelijk verzenden starten en in een Pythonscript wachten op alle ROS berichten die verzonden zijn (deze zijn op voorhand gekend).
    Resultaat?
        Op het einde van de test beschikt men over:
            Tijd tot het ROS netwerk alle berichten kan verwerken.
            De kennis dat het ROS netwerk al dan niet berichten kwijt raakt.

'''
# IMPORTS
import sys
import os
import rospy
import numpy as np
import random
import string
from geometry_msgs.msg import Twist, Vector3
from std_msgs.msg import Int32, Bool, String, Time, Float32
from sensor_msgs.msg import NavSatFix, CompressedImage
import cv2
from cv_bridge import CvBridge, CvBridgeError
from tqdm import tqdm, trange
import time
import datetime
import Queue
from threading import Thread
from thread import start_new_thread, allocate_lock

global meanTime
global NumberOfMessages
global lock
global threads

def updateMeanTime(addtime):
    global meanTime

    diff = time.time()-float(addtime)
    if(float(addtime) != 19):
        meanTime += diff

        print('startTime: {} -- endTime: {}'.format(rospy.Time.now().to_sec(), addtime))

        if NumberOfMessages > 0:
            print('Current Mean Time: {} seconds for {} messages.'.format(1.0*meanTime/NumberOfMessages, NumberOfMessages))

def callback(data):
    global NumberOfMessages

    lock.acquire()
    if float(data.data) != 19:
        NumberOfMessages += 1
    lock.release()
    t = Thread(target=updateMeanTime, args=(data.data,))
    t.start()
    threads.append(t)

def main(args):

    print('''
--------------------------------------------
TEST: Simuleer 1 Double die N ROS berichten
      verzendt. Wat gebeurt er?

TEST: Simulate 1 Double which sends N ROS
      messages. What happens?
--------------------------------------------
This script will try to receive N messages which are sends through the
the firmware channel of the Double topic 'Double_1/firmwareVersion'.
The difference between the time of transmission and the time of
arrival will be calculated and shown during the program.

    ''')

    global meanTime
    global NumberOfMessages
    global lock
    global threads

    meanTime = 0
    NumberOfMessages = 0
    lock = allocate_lock()
    threads = []

    rospy.init_node('ListeningFirmwareVersion',anonymous=True)

    rospy.Subscriber("/Double_1/firmwareVersion", String, callback)

    rospy.spin()

if __name__ == '__main__':
    main(sys.argv)
