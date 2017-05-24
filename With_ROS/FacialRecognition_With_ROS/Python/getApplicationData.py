# -*- coding: utf-8 -*-
'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                        Thesis: getApplicationData.py                        ║
╠═════════════════════════════════════ By ════════════════════════════════════╣
║                               Michiels Kilian                               ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''
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
║                                   IMPORTS                                   ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''
import sys
import rospy
import numpy as np
import os
from std_msgs.msg import Int32, Bool, String, Time
from sensor_msgs.msg import CompressedImage
import cv2
'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                                  CONSTANTS                                  ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''
'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                                  VARIABLES                                  ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''
applicationParameters = {
        'facialRecognitionMessage': None,
        'fails': None,
        'success': None,
        'firstTime': None,
        'session': None,
        'sessionSet': None,
        'userTag': None,
        'username': None,
        'viewFlow': None
        }
'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                                   CLASSES                                   ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                                  FUNCTIONS                                  ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''

def getFacialRecognitionMessage():
    print('Starting: facialRecognitionMessage')
    return rospy.Subscriber('/Application/facialRecognitionMessage', String, updateFacialRecognitionMessage, queue_size=1)


def getFails():
    print('Starting: fails')
    return rospy.Subscriber('/Application/fails', Int32, updateFails, queue_size=1)


def getSuccess():
    print('Starting: success')
    return rospy.Subscriber('/Application/success', Int32, updateSuccess, queue_size=1)


def getFirstTime():
    print('Starting: firstTime')
    return rospy.Subscriber('/Application/firstTime', Bool, updateFirstTime, queue_size=1)


def getSession():
    print('Starting: session')
    return rospy.Subscriber('/Application/session', Time, updateSession, queue_size=1)


def getSessionSet():
    print('Starting: sessionSet')
    return rospy.Subscriber('/Application/sessionSet', Bool, updateSessionSet, queue_size=1)


def getUserTag():
    print('Starting: userTag')
    return rospy.Subscriber('/Application/userTag', String, updateUserTag, queue_size=1)


def getUsername():
    print('Starting: username')
    return rospy.Subscriber('/Application/username', String, updateUsername, queue_size=1)

def getUserPhoto():
    print('Starting: userPhoto')
    return rospy.Subscriber('/Application/userPhoto', CompressedImage, updateUserPhoto, queue_size=1)

def getViewFlow():
    print('Starting: viewFlow')
    return rospy.Subscriber('/Application/viewFlow', String, updateViewFlow, queue_size=1)

#------------------------------------------------------------------------------#

def updateFacialRecognitionMessage(ros_data):
    applicationParameters['facialRecognitionMessage'] = ros_data.data
    updateConsole()


def updateFails(ros_data):
    applicationParameters['fails'] = ros_data.data
    updateConsole()


def updateSuccess(ros_data):
    applicationParameters['success'] = ros_data.data
    updateConsole()


def updateFirstTime(ros_data):
    applicationParameters['firstTime'] = ros_data.data
    updateConsole()


def updateSession(ros_data):
    applicationParameters['session'] = ros_data.data
    updateConsole()


def updateSessionSet(ros_data):
    applicationParameters['sessionSet'] = ros_data.data
    updateConsole()


def updateUserTag(ros_data):
    applicationParameters['userTag'] = ros_data.data
    updateConsole()


def updateUsername(ros_data):
    applicationParameters['username'] = ros_data.data
    updateConsole()

def updateUserPhoto(ros_data):
    np_arr = np.fromstring(ros_data.data, np.uint8)
    image_np = cv2.imdecode(np_arr, 1)
    cv2.destroyAllWindows()
    cv2.imshow('User Photo', image_np)
    cv2.waitKey(0)

def updateViewFlow(ros_data):
    applicationParameters['viewFlow'] = ros_data.data
    updateConsole()

#------------------------------------------------------------------------------#


def updateConsole():
    os.system("clear")
    if(applicationParameters['sessionSet'] is True):
        print('''\n    ------------------------- SESSION: {} -------------------------'''.format(applicationParameters['session']))
    else:
        print(bcolors.FAIL + '''\n    ----------------------- NOT CONNECTED -----------------------''' + bcolors.ENDC)
    print('''
    ------------------- Application Parameters: -----------------
    |   success:                    \t{}
    -------------------------------------------------------------
    |   fails:                      \t{}
    -------------------------------------------------------------
    |   username:                   \t{}
    -------------------------------------------------------------
    |   userTag:                    \t{}
    -------------------------------------------------------------
    |   firstTime:                  \t{}
    -------------------------------------------------------------
    |   facialRecognitionMessage:   \t{}
    -------------------------------------------------------------
    |   viewFlow:                   \t{}
    -------------------------------------------------------------
    '''.format(applicationParameters['success'],
    applicationParameters['fails'],
    applicationParameters['username'],
    applicationParameters['userTag'],
    applicationParameters['firstTime'],
    applicationParameters['facialRecognitionMessage'],
    applicationParameters['viewFlow']
               )
        )

def main(args):
    print('Initializing application data receiver...')
    #-------------------------------------------------#
    session = getSession()
    sessionSet = getSessionSet()
    success=getSuccess()
    fails=getFails()
    username=getUsername()
    userTag=getUserTag()
    firstTime=getFirstTime()
    facialRecognitionMessage=getFacialRecognitionMessage()
    userPhoto=getUserPhoto()
    viewFlow=getViewFlow()
    #-------------------------------------------------#

    rospy.init_node('applicationDataReceiver', anonymous=True)

    try:
        print("Running...")
        rospy.spin()

	#-------------------------------------------------#
    except KeyboardInterrupt:
        pass
'''
╔═════════════════════════════════════════════════════════════════════════════╗
║                                    PROGRAM                                  ║
╚═════════════════════════════════════════════════════════════════════════════╝
'''
if __name__ == '__main__':
    main(sys.argv)
