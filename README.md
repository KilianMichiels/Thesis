# Application & Script Manual

- Author: Kilian Michiels
- Thesis: Smart Office: Een intelligente werkomgeving door gebruik te maken van Internet Of Things
- Date: 2017-06-02

## Table Of Contents
- [General Information](https://github.com/Michielskilian/Test/blob/master/README.md#general-information)
- [Ubuntu installation](https://github.com/Michielskilian/Test/blob/master/README.md#ubuntu-installation)
- [ROS installation](https://github.com/Michielskilian/Test/blob/master/README.md#ros-installation)
- [Pod installation](https://github.com/Michielskilian/Test/blob/master/README.md#pod-installation)
- [Applications](https://github.com/Michielskilian/Test/blob/master/README.md#applications)
- [How to run the tests](https://github.com/Michielskilian/Test/blob/master/README.md#how-to-run-the-tests)

## General information
To use all of the software, you will need:

1. [Python](https://www.python.org/) 2.7 or higher
2. [OpenCV](http://opencv.org/) 2.4.13.2 or higher
3. [XCode 8.3](https://developer.apple.com/download/) or higher (App Store)
4. Virtual Machine with Ubuntu 14.04 (see [Ubuntu installation](https://github.com/Michielskilian/Test/blob/master/README.md#ubuntu-installation)) and ROS indigo (see [ROS installation](https://github.com/Michielskilian/Test/blob/master/README.md#ros-installation)).
5. [ROSBridge](http://wiki.ros.org/rosbridge_suite) for Indigo.

## Ubuntu installation
If you don't have any virtual machine installed, do this first (https://www.virtualbox.org/wiki/Downloads).
Visit the following page to get Ubuntu 14.04: http://releases.ubuntu.com/14.04/

## ROS installation
Visit the following page to install ROS Indigo: http://wiki.ros.org/indigo/Installation/Ubuntu

## Pod installation
To run some of the applications, you will need Pods which are used to automatically install the right packages and frameworks.

How to install Pod:

1. Open Terminal.
2. Enter `sudo gem install cocoapods` command in terminal.

When using a project with a podfile, before opening any of the projects, navigate in the Terminal to the working directory and enter the command `pod install`.

When the installation was successful, you can open the workspace to run the project.

## Applications
Note 1: Every file is referenced from the root folder 'Masterproef'.

Note 2: Every app needs an iPad to run correctly.

Note 3: If this is your first time using Pods, please read [Pod installation](https://github.com/Michielskilian/Test/blob/master/README.md#pod-installation) first.

### Without ROS
#### /Double1_IOS/Without_ROS/Basic-Control-SDK-iOS-master/DoubleBasicHelloWorld:

- Open DoubleBasicHelloWorld.xcodeproj in XCode.
- Change the developer signing to your own Apple Developer Account (https://developer.apple.com/).
- If the DoubleControlSDK framework isn't in the project you can download it here: https://github.com/doublerobotics/Basic-Control-SDK-iOS
- Run DoubleBasicHelloWorld.xcodeproj with XCode.
- Make sure the Double and the iPad are close enough to each other AND they are connected through Bluetooth.

#### /Double1_IOS/Without_ROS/openCVTestApplication:
 
- Open openCVTestApplication.xcworkspace in XCode.
- Change the developer signing to your own Apple Developer Account (https://developer.apple.com/).
- Don't forget to run the 'pod install' command in Terminal before opening the workspace.
- You should be able to run the project on the iPad.

#### /Double1_IOS/Without_ROS/Kairos-SDK-iOS-master/KairosSDKExampleApp:

- Open KairosSDKExampleApp.xcodeproj.
- Change the developer signing to your own Apple Developer Account (https://developer.apple.com/).
- Run the application on the iPad.

#### /Double1_IOS/Without_ROS/FacialRecognition/:

- Run `pod install` in the working directory.
- Open FacialRecognition.xcworkspace in XCode.
- Change the developer signing to your own Apple Developer Account (https://developer.apple.com/).
- Run the application on the iPad.

#### /Double1_IOS/Without_ROS/FacialRecognition_Database_Test:

- Run `pod install` in the working directory.
- Open FacialRecognition.xcworkspace in XCode.
- Change the developer signing to your own Apple Developer Account (https://developer.apple.com/).
- Run the application on the iPad.

The only difference between FacialRecognition and FacialRecognition_Database_Test is the extra view to go to the testpage which corresponds to the test about the database on the iPad (see 'How to run tests').

### With ROS
For these applications you will need ROS running on your computer. To install this, check [ROS installation](https://github.com/Michielskilian/Test/blob/master/README.md#ros-installation).

#### /Double1_IOS/With_ROS/FacialRecognition_With_ROS:

- Run `pod install` in the working directory.
- Open FacialRecognition.xcworkspace in XCode. (Don't run it yet!)
- Start your virtual machine with Ubuntu and ROS.
- Open a terminal in Ubuntu and enter `roscore`.
- If you haven't installed [ROSBridge](http://wiki.ros.org/rosbridge_suite), do it now.
- Open another terminal and enter `roslaunch rosbridge_server rosbridge_websocket.launch`.
- On the same computer, in your virtual machine, check your IP with `hostname -I`.
- Replace the IP in the 'FacialRecognition/General/constants.h' file with your IP and add ':9090' at the end.
- Run the application. If the iPad is connected to the Double AND the ROS network, both bottom corners will be green.

To get the data from the application you can run 'getApplicationData.py'

#### /Double1_IOS/With_ROS/DoubleIOSWithROS:

- Run `pod install` in the working directory.
- Open ROSApplication.xcworkspace in XCode.
- At this point, you can already run the application.
- Start your virtual machine with Ubuntu and ROS.
- Open a terminal in Ubuntu and enter `roscore`.
- If you haven't installed [ROSBridge](http://wiki.ros.org/rosbridge_suite), do it now.
- Open another terminal and enter `roslaunch rosbridge_server rosbridge_websocket.launch`.
- On the same computer, in your virtual machine, check your IP with `hostname -I`.
- Insert this in the application while you are on the same network and add ':9090' at the end.
- Press 'Connect' and the application should connect to your ROS network.

## How to run the tests
These instructions are written for the 6 tests which can be done with the Python scripts or the applications.

Note 1: The folder 'faces95' has 7411 faces for the facial recognition test. Do not change this folder!

Note 2: All of the scripts are self explanatory. They provide a short introduction at the beginning of each script. Any additional things to do before you can run the script will be written with each title corresponding to the test.

### /python/Test_ROS_N_Doubles.py:
- You will need to run a virtual machine with [Ubuntu 14.04](https://github.com/Michielskilian/Test/blob/master/README.md#ubuntu-installation) and [ROS indigo](https://github.com/Michielskilian/Test/blob/master/README.md#ros-installation).
- Open a terminal in Ubuntu and enter `roscore`.
- If you haven't installed [ROSBridge](http://wiki.ros.org/rosbridge_suite), do it now.
- Open another terminal and enter `roslaunch rosbridge_server rosbridge_websocket.launch`.
- Run the script with `python Test_ROS_N_Doubles.py`.
- The script will ask you the necessary input.

### /python/Test_1_Double_N_Messages_Receive_On_Double.py


### /python/Test_1_Double_N_Messages.py


### /python/Test_Gezichtsherkenning.py


### /python/Test_ROS_1_Double_N_Messages.py


### /Double1_IOS/With_ROS/DoubleIOSWithROS/Python:



