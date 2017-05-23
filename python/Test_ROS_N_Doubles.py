# -*- coding: utf-8 -*-
'''
ROS: Simuleer N Double’s die op het ROS netwerk aangesloten zijn. Wat gebeurt er?
Hoe?
    Pythonscript, for loop van N * aantal publishers per Double
    Laat deze tegelijkertijd aanmelden op het netwerk (for loop zou snel genoeg moeten zijn om gelijktijdigheid te simuleren)
    Controleer vervolgens of alle publishers aanwezig zijn.
    Zo niet, blijf controleren tot ze allen aanwezig zijn.

Resultaat?
    Bij afloop van de test beschikt men over:
    Tijd tot alle Doubles zijn aangesloten bij een netwerk met grootte N.
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

'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                         APPLICATION AVAILABLE DATA                          ║
║                                                                             ║
║                     /Application/facialRecognitionMessage                   ║
║                     /Application/fails                                      ║
║                     /Application/firstTime                                  ║
║                     /Application/session                                    ║
║                     /Application/sessionSet                                 ║
║                     /Application/success                                    ║
║                     /Application/userTag                                    ║
║                     /Application/username                                   ║
║                     /Application/userPhoto                                  ║
║                     /Application/viewFlow                                   ║
║                                                                             ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''
'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                             DOUBLE AVAILABLE DATA                           ║
║                                                                             ║
║                     /Double_1/actualPoleHeightPercentage                    ║
║                     /Double_1/actualkickStandState                          ║
║                     /Double_1/batteryFullyCharged                           ║
║                     /Double_1/batteryPercentage                             ║
║                     /Double_1/camera                                        ║
║                     /Double_1/firmwareVersion                               ║
║                     /Double_1/location                                      ║
║                     /Double_1/motionDetection                               ║
║                     /Double_1/serial                                        ║
║                     /Double_1/status                                        ║
╚═════════════════════════════════════════════════════════════════════════════╝

'''
'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                                  FUNCTIONS                                  ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''

def setFacialRecognitionMessage(N, verbose):
    if verbose:
        print('Starting: facialRecognitionMessage_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/facialRecognitionMessage', String, queue_size=1)

def setFails(N, verbose):
    if verbose:
        print('Starting: fails_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/fails', Int32, queue_size=1)

def setSuccess(N, verbose):
    if verbose:
        print('Starting: success_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/success', Int32, queue_size=1)

def setFirstTime(N, verbose):
    if verbose:
        print('Starting: firstTime_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/firstTime', Bool, queue_size=1)

def setSession(N, verbose):
    if verbose:
        print('Starting: session_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/session', Time, queue_size=1)

def setSessionSet(N, verbose):
    if verbose:
        print('Starting: sessionSet_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/sessionSet', Bool, queue_size=1)

def setUserTag(N, verbose):
    if verbose:
        print('Starting: userTag_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/userTag', String, queue_size=1)

def setUsername(N, verbose):
    if verbose:
        print('Starting: username_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/username', String, queue_size=1)

def setUserPhoto(N, verbose):
    if verbose:
        print('Starting: userPhoto_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/userPhoto', CompressedImage, queue_size=1)

def setViewFlow(N, verbose):
    if verbose:
        print('Starting: viewFlow_{}'.format(N))
    return rospy.Publisher('/Application_' + str(N) +'/viewFlow', String, queue_size=1)

#------------------------------------------------------------------------------#

def setActualPoleHeightPercentage(N, verbose):
    if verbose:
        print('Starting: actualPoleHeightPercentage_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/actualPoleHeightPercentage', Float32, queue_size = 1)

def setActualkickStandState(N, verbose):
    if verbose:
        print('Starting: actualkickStandState_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/actualkickStandState', Int32, queue_size = 1)

def setBatteryFullyCharged(N, verbose):
    if verbose:
        print('Starting: batteryFullyCharged_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/batteryFullyCharged', Bool, queue_size = 1)

def setBatteryPercentage(N, verbose):
    if verbose:
        print('Starting: batteryPercentage_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/batteryPercentage', Float32, queue_size = 1)

def setFirmwareVersion(N, verbose):
    if verbose:
        print('Starting: firmwareVersion_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/firmwareVersion', String, queue_size = 1)

def setLocation(N, verbose):
    if verbose:
        print('Starting: location_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/location', NavSatFix, queue_size = 1)

def setMotionDetection(N, verbose):
    if verbose:
        print('Starting: motionDetection_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/motionDetection', Bool, queue_size = 1)

def setSerial(N, verbose):
    if verbose:
        print('Starting: serial_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/serial', String, queue_size = 1)

def setStatus(N, verbose):
    if verbose:
        print('Starting: status_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/status', Bool, queue_size = 1)

def setCamera(N, verbose):
    if verbose:
        print('Starting: camera_{}'.format(N))
    return rospy.Publisher('/Double_' + str(N) +'/camera', CompressedImage, queue_size = 1)

def givePublisherNames(N):
    publishers_Readable = []
    publishers_Readable.append('/Application_' + str(N) + '/facialRecognitionMessage')
    publishers_Readable.append('/Application_' + str(N) + '/fails')
    publishers_Readable.append('/Application_' + str(N) + '/firstTime')
    publishers_Readable.append('/Application_' + str(N) + '/session')
    publishers_Readable.append('/Application_' + str(N) + '/sessionSet')
    publishers_Readable.append('/Application_' + str(N) + '/success')
    publishers_Readable.append('/Application_' + str(N) + '/userTag')
    publishers_Readable.append('/Application_' + str(N) + '/username')
    publishers_Readable.append('/Application_' + str(N) + '/userPhoto')
    publishers_Readable.append('/Application_' + str(N) + '/viewFlow')

    publishers_Readable.append('/Double_' + str(N) + '/actualPoleHeightPercentage')
    publishers_Readable.append('/Double_' + str(N) + '/actualkickStandState')
    publishers_Readable.append('/Double_' + str(N) + '/batteryFullyCharged')
    publishers_Readable.append('/Double_' + str(N) + '/batteryPercentage')
    publishers_Readable.append('/Double_' + str(N) + '/firmwareVersion')
    publishers_Readable.append('/Double_' + str(N) + '/location')
    publishers_Readable.append('/Double_' + str(N) + '/motionDetection')
    publishers_Readable.append('/Double_' + str(N) + '/serial')
    publishers_Readable.append('/Double_' + str(N) + '/status')
    publishers_Readable.append('/Double_' + str(N) + '/camera')

    return publishers_Readable


def setPublishers(N, verbose):
    publishers = []

    # Application publishers:
    publishers.append(setFacialRecognitionMessage(N, verbose))
    publishers.append(setFails(N, verbose))
    publishers.append(setFirstTime(N, verbose))
    publishers.append(setSession(N, verbose))
    publishers.append(setSessionSet(N, verbose))
    publishers.append(setSuccess(N, verbose))
    publishers.append(setUserTag(N, verbose))
    publishers.append(setUsername(N, verbose))
    publishers.append(setUserPhoto(N, verbose))
    publishers.append(setViewFlow(N, verbose))

    # Double publishers:
    publishers.append(setActualPoleHeightPercentage(N, verbose))
    publishers.append(setActualkickStandState(N, verbose))
    publishers.append(setBatteryFullyCharged(N, verbose))
    publishers.append(setBatteryPercentage(N, verbose))
    publishers.append(setFirmwareVersion(N, verbose))
    publishers.append(setLocation(N, verbose))
    publishers.append(setMotionDetection(N, verbose))
    publishers.append(setSerial(N, verbose))
    publishers.append(setStatus(N, verbose))
    publishers.append(setCamera(N, verbose))

    # Return application & double publishers for 1 double
    return publishers

def check_connections(publishers, verbose):
    allCurrentTopics = rospy.get_published_topics()
    if verbose:
        for topic in allCurrentTopics:
            print topic[0]

    print('')

    counter = 0
    start = time.time()
    while counter < len(publishers):
        #print('Checking for: {}'.format(publishers[counter]))
        counter_2 = 0
        while counter_2 < len(publishers[counter]):
            if verbose:
                print('-----> Checking for: {}'.format(publishers[counter][counter_2]))
            counter_3 = 0
            while not(any(publishers[counter][counter_2] in sublist for sublist in allCurrentTopics)):
                allCurrentTopics = rospy.get_published_topics()

            if verbose:
                print('--> FOUND\n')
            counter_2 += 1
        counter += 1

    end = time.time()

    print('Total time to create all publishers: {} seconds'.format(end- start))
    return end - start

def startPublishers(N, verbose, queue):
    publishers = []
    for x in range(1, N+1):
        publishers.append(setPublishers(x, verbose))
    queue.put(publishers)

def publishMessages(messages, publishers, times_to_publish, publish_frequency, publishers_Readable):

    print('\n----------------- MESSAGES: {} --------------------\n'.format(len(messages)))
    #print(messages)
    print('\n---------------- PUBLISHERS: {} -------------------\n'.format(len(publishers)))
    #print(publishers)
    print('-----------------------------------------------------\n\n')

    for i,n_publisher in enumerate(publishers):
        rate = rospy.Rate(publish_frequency)
        for x in range(len(n_publisher)):
            #print('\nPublishing \t{}\n'.format(publishers_Readable[i][x]))
            n_publisher[x].publish(messages[i][x])
            rate.sleep()


def prepareMessages(N_messages):
    #print('Starting prepareMessages...')
    messages = []
    temp = []

    bridge = CvBridge()

    for N in range(N_messages):
        # Prepare messages:
        msg_facialRecognitionMessage = String()
        facialRecognitionMessage = str(N) + ' -- ' + str(time.time())
        msg_facialRecognitionMessage.data = facialRecognitionMessage
        temp.append(msg_facialRecognitionMessage)

        msg_fails = Int32()
        fails = int(1000*np.random.random())
        msg_fails.data = fails
        temp.append(msg_fails)

        msg_firstTime = Bool()
        firstTime = True
        msg_firstTime.data = firstTime
        temp.append(msg_firstTime)

        msg_session = Time()
        session = rospy.Time.now()
        msg_session.data = session
        temp.append(msg_session)

        msg_sessionSet = Bool()
        sessionSet = True
        msg_sessionSet.data = sessionSet
        temp.append(msg_sessionSet)

        msg_success = Int32()
        success = int(1000*np.random.random())
        msg_success.data = success
        temp.append(msg_success)

        msg_userTag = String()
        userTag = 'Employee_FR'
        msg_userTag.data = userTag
        temp.append(msg_userTag)

        msg_username = String()
        username = 'User: ' + str(N)
        msg_username.data = username
        temp.append(msg_username)

        msg_userPhoto = CompressedImage()
        userPhoto = cv2.imread('testImg.jpg')
        image_message = bridge.cv2_to_compressed_imgmsg(userPhoto, dst_format='jpg')
        msg_userPhoto = image_message
        temp.append(msg_userPhoto)

        msg_viewFlow = String()
        viewFlow = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(20))
        msg_viewFlow.data = viewFlow
        temp.append(msg_viewFlow)

        msg_actualPoleHeightPercentage = Float32()
        actualPoleHeightPercentage = 100*np.random.random()
        msg_actualPoleHeightPercentage.data = actualPoleHeightPercentage
        temp.append(msg_actualPoleHeightPercentage)

        msg_actualkickStandState = Int32()
        actualkickStandState = int(4*np.random.random())
        msg_actualkickStandState.data = actualkickStandState
        temp.append(msg_actualkickStandState)

        msg_batteryFullyCharged = Bool()
        batteryFullyCharged = False
        msg_batteryFullyCharged.data = batteryFullyCharged
        temp.append(msg_batteryFullyCharged)

        msg_batteryPercentage = Float32()
        batteryPercentage = 100*np.random.random()
        msg_batteryPercentage.data = batteryPercentage
        temp.append(msg_batteryPercentage)

        msg_firmwareVersion = String()
        firmwareVersion = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10))
        msg_firmwareVersion.data = firmwareVersion
        temp.append(msg_firmwareVersion)

        msg_location = NavSatFix()
        msg_location.latitude = 180*np.random.random()
        msg_location.longitude = 180*np.random.random()
        temp.append(msg_location)

        msg_motionDetection = Bool()
        motionDetection = False
        msg_motionDetection.data = motionDetection
        temp.append(msg_motionDetection)

        msg_serial = String()
        serial = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(15))
        msg_serial.data = serial
        temp.append(msg_serial)

        msg_status = Bool()
        status = True
        msg_status.data = status
        temp.append(msg_status)

        msg_camera = CompressedImage()
        camera = cv2.imread('testImg.jpg')
        image_message = bridge.cv2_to_compressed_imgmsg(camera, dst_format='jpg')
        msg_camera = image_message
        temp.append(msg_camera)

        messages.append(temp)

    return messages

def callback(data):
    #rospy.loginfo(rospy.get_caller_id() + "This message came from {}".format(data.comeFrom))
    try:
        cv2.destroyAllWindows()
        br = CvBridge()
        image = br.compressed_imgmsg_to_cv2(data, desired_encoding='passthrough')
        print("MESSAGE RECEIVED: " + rospy.get_caller_id() + " \t Picture \t\t {}\n".format(datetime.datetime.now()))
        cv2.imshow('Image from ROS',image)
        cv2.waitKey(0)

    except Exception as e:
        try:
            print("MESSAGE RECEIVED: " + rospy.get_caller_id() + " \nLocation: \n{}\n{} \t\t {}\n".format(data.latitude,data.longitude, datetime.datetime.now()))
        except Exception as e:
            print("MESSAGE RECEIVED: " + rospy.get_caller_id() + " \n {} \t\t {}\n".format(data.data, datetime.datetime.now()))

def createListeners(N):
    for listener_n in range(1, N+1):
        #print('Creating listener_{}'.format(listener_n))

        rospy.Subscriber("/Application_" + str(listener_n) + "/facialRecognitionMessage", String, callback)
        rospy.Subscriber("/Application_" + str(listener_n) + "/fails", Int32, callback)
        rospy.Subscriber("/Application_" + str(listener_n) + "/firstTime", Bool, callback)
        rospy.Subscriber("/Application_" + str(listener_n) + "/session", Time, callback)
        rospy.Subscriber("/Application_" + str(listener_n) + "/sessionSet", Bool, callback)
        rospy.Subscriber("/Application_" + str(listener_n) + "/success", Int32, callback)
        rospy.Subscriber("/Application_" + str(listener_n) + "/userTag", String, callback)
        rospy.Subscriber("/Application_" + str(listener_n) + "/username", String, callback)
        rospy.Subscriber("/Application_" + str(listener_n) + "/userPhoto", CompressedImage, callback)
        rospy.Subscriber("/Application_" + str(listener_n) + "/viewFlow", String, callback)

        rospy.Subscriber("/Double_" + str(listener_n) + "/actualPoleHeightPercentage", Float32, callback)
        rospy.Subscriber("/Double_" + str(listener_n) + "/actualkickStandState", Int32, callback)
        rospy.Subscriber("/Double_" + str(listener_n) + "/batteryFullyCharged", Bool, callback)
        rospy.Subscriber("/Double_" + str(listener_n) + "/batteryPercentage", Float32, callback)
        rospy.Subscriber("/Double_" + str(listener_n) + "/camera", CompressedImage, callback)
        rospy.Subscriber("/Double_" + str(listener_n) + "/firmwareVersion", String, callback)
        rospy.Subscriber("/Double_" + str(listener_n) + "/location", NavSatFix, callback)
        rospy.Subscriber("/Double_" + str(listener_n) + "/motionDetection", Bool, callback)
        rospy.Subscriber("/Double_" + str(listener_n) + "/serial", String, callback)
        rospy.Subscriber("/Double_" + str(listener_n) + "/status", Bool, callback)

def checkMessages():
    print('Starting checkMessages...')

def main(args):

print('''
--------------------------------------------
TEST: Simuleer N Double’s die op het ROS
netwerk aangesloten zijn. Wat gebeurt er?

TEST: Simulate N Double's which are
connected to the ROS network at once.
What happens?
--------------------------------------------
This script will generate N Double's which try to connect to the ROS network simultaniously.
The total time to create all the publishers will be shown at the end of the program.

    ''')

    N = raw_input("How many Double's would you like to publish?\n")

    # Parameters:
    verbose = False

    # Program:
    print('''
----------------------------------------------------------------------------

    Test ROS N Doubles
        {}

    Settings:
        N = {}
        verbose = {}

----------------------------------------------------------------------------
    '''.format(datetime.datetime.now(), N, verbose))

    publishers = []
    publishers_Readable = []

    queue = Queue.Queue()

    for x in range(1, N+1):
        publishers_Readable.append(givePublisherNames(N))

    rospy.init_node('Test_ROS_N_Double', anonymous=True)

    t_1 = Thread(target=check_connections, args=(publishers_Readable, False))
    t_1.start()

    t_2 = Thread(target=startPublishers, args=(N, verbose, queue))
    t_2.start()

    #createListeners(N)

    #messages = prepareMessages(N)

    #print(messages)

    #publishers = queue.get()

    # t_3 = Thread(target=publishMessages, args=(messages, publishers, 15, 5, publishers_Readable))
    # t_3.start()

    rospy.spin()

	#-------------------------------------------------#

'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                                    PROGRAM                                  ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''

if __name__ == '__main__':
    main(sys.argv)
