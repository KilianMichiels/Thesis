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


def sendMessages(publisher, N, verbose):
    rate = rospy.Rate(50)
    for n in range(N):
        msg = Twist(Vector3(0,0,0),Vector3(0,0,-1))
        publisher.publish(msg)
        rate.sleep()

def sendMessages2(publisher, N, verbose):
    rate = rospy.Rate(50)
    for n in range(N):
        msg = Twist(Vector3(0,0,0),Vector3(0,0,1))
        publisher.publish(msg)
        rate.sleep()

def setPublisher(N, verbose):
    if verbose:
        print('Starting: publisher_{}'.format(N))
    return rospy.Publisher('/Double_1/controls', Twist, queue_size=1)

def main(args):

    print('''
--------------------------------------------
TEST: Simuleer 1 Double die N ROS berichten
      moet verwerken. Wat gebeurt er?

TEST: Simulate 1 Double which has to process
      N ROS messages. What happens?
--------------------------------------------
This script will send 2*N*N controlmessages to the Double on the ROS netwerk.
These messages should be received on the Double side and counted and displayed in the
"Messages received: <count>" panel.

''')

    N = raw_input('''
How many messages would you like to send?
This number N will be multiplied with 2*N.
(Please enter a number.)

''')

    print('Total number of messages send: {}\n'.format(2*N*N))
    #------------------------------------------------------------------------------#

    rospy.init_node('applicationDataSender', anonymous=True)

    Publisher = setPublisher(1, False)
    threads = []

    for x in range(N):
        t = Thread(target=sendMessages, args=(Publisher, N, False))
        t.start()
        threads.append(t)
        t = Thread(target=sendMessages2, args=(Publisher, N, False))
        t.start()
        threads.append(t)

    for t in threads:
        t.join()

if __name__ == '__main__':
    main(sys.argv)
