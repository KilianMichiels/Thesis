//
//  MainROSDoubleControl.h
//  FacialRecognition
//
//  Created by Kilian on 14/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//
/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/
/*------------------------------------------------------------------------*/
/*                     ROS MAIN CONTROLLER HEADER FILE                    */
/*------------------------------------------------------------------------*/
/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/

#import <Foundation/Foundation.h>

#import "Constants.h"

#import "RBManager.h"
#import "RBMessage.h"
#import "RBPublisher.h"
#import "RBSubscriber.h"

#import "IntMessage.h"
#import "NavSatFixMessage.h"
#import "FloatMessage.h"
#import "StringMessage.h"
#import "CompressedImage.h"
#import "TimeMessage.h"

#import <opencv2/videoio/cap_ios.h>

/*
 Notifications:
 */

extern NSString * const MainROSDoubleControlNotification;


/*
 Delegates from MainROSControl:
 */

@protocol MainROSControlDelegate <NSObject>
@optional

- (void) MainROSControlDidConnect                                  ;
- (void) MainRosControlLostConnection:(NSString * ) reason         ;
- (void) MainRosControlAlreadyConnected;

- (void) messageUpdate_poleHeightPercentage :(FloatMessage*)   message;
- (void) messageUpdate_kickStandState       :(IntMessage*)   message;
- (void) messageUpdate_Controls             :(TwistMessage*)   message;
- (void) messageUpdate_MotionDetection      :(BoolMessage*)   message;

@end

@interface MainROSDoubleControl : NSObject <RBManagerDelegate, CvVideoCameraDelegate>{
    
    CvVideoCamera *camera;
    
}

/*
 Main Control Parameters.
 - Connection status
 - session_IP
 - connectionTimer
 */
@property BOOL connectionStatus;
@property NSString * session_IP;
@property NSTimer * connectionTimer;

@property (nonatomic, weak) id<MainROSControlDelegate> delegate;

/*
 Here are all the parameters the Double can have:
    int kickStandState;
    NSString * firmwareVersion;
    float batteryPercentage;
    BOOL batteryIsFullyCharged;
    NSString * serial;
    float poleHeightPercentage;
 
 So for each parameter we have to add a subscriber and/or publisher:
 */

@property RBPublisher * kickStandStatePublisher;
@property RBSubscriber * kickStandStateSubscriber;

@property RBPublisher * firmwareVersionPublisher;

@property RBPublisher * batteryPercentagePublisher;

@property RBPublisher * batteryIsFullyChargedPublisher;

@property RBPublisher * serialPublisher;

@property RBPublisher * poleHeightPercentagePublisher;
@property RBSubscriber * poleHeightPercentageSubscriber;

/*      Other parameters:       */
@property RBPublisher * statusPublisher;

@property RBSubscriber * controlsSubscriber;
@property RBPublisher * controlsPublisher;

@property RBPublisher * locationPublisher;

@property RBSubscriber * motionDetectionSubscriber;
@property RBPublisher * motionDetectionPublisher;

@property RBPublisher * imagePublisher;


/*       Application publishers        */
/*                                     
 Possible publishing topics are:
  int fail; -------------------------------> Number of failed recognitions
  
  int success; ----------------------------> Number of succeeded recognitions
  
  NSObject *facialRecognitionMessage; -----> Facial recognition message from Kairos

  BOOL sessionSet; ------------------------> If there is a session started
  
  NSDate* session; ------------------------> Which session is currently running
  
  NSString * user_tag; --------------------> User tag (FR, Employee, Visitor, No FR,...)
  
  NSString * username; --------------------> Username of the current user
  
  BOOL firsttime; -------------------------> Is this their first time using this application?
 */
@property RBPublisher * failPublisher;

@property RBPublisher * succesPublisher;

@property RBPublisher * facialRecognitionMessagePublisher;

@property RBPublisher * sessionSetPublisher;

@property RBPublisher * sessionPublisher;

@property RBPublisher * user_tagPublisher;

@property RBPublisher * usernamePublisher;

@property RBPublisher * firsttimePublisher;

@property RBPublisher * viewFlowPublisher;


/*       Other possible messages       */
@property RBPublisher * stringPublisher;
@property RBPublisher * stringSubscriber;


/*
 Extra variables for RBManager control:
 */
@property RBManager * manager;

/*!
 Start the Main Control. Choose your own IP.
 */
- (BOOL)initialiseMainROSDoubleControl:(NSString * )ip_adres;

/*!
 End the Main Control.
 */
- (BOOL)disconnectMainROSDoubleControl;

/*------------------------------------------------------------------------*/
/*                              ROS PUBLISHERS                            */
/*------------------------------------------------------------------------*/

/*!
 Publish if the iPad is connected to the Double 1.
 */
- (BOOL)initPublishStatus;
- (void)publishStatus:(BOOL)status;

/*!
 Publish the height of the Double 1 pole in percentages.
 */
- (BOOL)initPublishPoleHeightPercentage;
- (void)publishPoleHeight:(float)heightPercentage;

/*!
 Publish the battery percentage of the Double 1.
 */
- (BOOL)initPublishBatteryPercentage;
- (void)publishBatteryPercentage:(float)batteryPercentage;

/*!
 Publish the serial number of the Double 1.
 */
- (BOOL)initPublishSerial;
- (void)publishSerial:(NSString *)serial;

/*!
 Publish the kickstandstate of the Double 1.
 */
- (BOOL)initPublishKickStandState;
- (void)publishKickStandState:(int)kickStandState;

/*!
 Publish if the battery of the Double 1 is fully charged.
 */
- (BOOL)initPublishBatteryIsFullyCharged;
- (void)publishBatteryIsFullyCharged:(BOOL)batteryIsFullyCharged;
/*!
 Publish the firmware version of the Double 1.
 */
- (BOOL)initPublishFirmwareVersion;
- (void)publishFirmwareVersion:(NSString *)firmwareVersion;
/*!
 Publish the Double 1's current location.
 */
- (BOOL)initPublishLocation;
- (void)publishLocation:(CLLocation * )location;
/*!
 Publish motion detection.
 */
- (BOOL)initPublishMotionDetection;
- (void)publishMotionDetection:(BOOL)motionDetection;
/*!
 Publish the cameraview.
 */
- (BOOL)initPublishImage;
- (void)publishImage:(NSString*)image;

/////////////////////////////////////////////////////////

/*!
 Publish the number of failed recognitions.
 */
- (BOOL)initPublishFail;
- (void)publishFail:(int)fails;

/*!
 Publish the number of succeeded recognitions
 */
- (BOOL)initPublishSuccess;
- (void)publishSuccess:(int)success;

/*!
 Publish the facial recognition message from Kairos.
 */
- (BOOL)initPublishFacialRecognitionMessage;
- (void)publishFacialRecogntionMessage:(NSString*)message;

/*!
 Publish the sessionSet parameter.
 */
- (BOOL)initPublishSessionSet;
- (void)publishSessionSet:(BOOL)sessionSet;

/*!
 Publish the current session.
 */
- (BOOL)initPublishSession;
- (void)publishSession:(NSDate*)session;

/*!
 Publish the user_tag parameter.
 */
- (BOOL)initPublishUserTag;
- (void)publishUserTag:(NSString*)user_tag;

/*!
 Publish the username.
 */
- (BOOL)initPublishUsername;
- (void)publishUsername:(NSString*)username;

/*!
 Publish the firsttime paramter.
 */
- (BOOL)initPublishFirstTime;
- (void)publishFirstTime:(BOOL)firsttime;

/*!
 Publish a string of choice.
 */
- (BOOL)initPublishString;
- (void)publishString:(NSString*)phrase;

/*!
 Publish the view flow of the application.
 */
- (BOOL)initPublishViewFlow;
- (void)publishViewFlow:(NSString*)viewFlow;

/*------------------------------------------------------------------------*/
/*                              ROS SUBSCRIBERS                           */
/*------------------------------------------------------------------------*/

/*!
 Listen to the pole height percentage of the ROS control center.
 */
- (BOOL)subscribeToPoleHeightPercentage;

/*!
 Subscribe to the kickstandstate of the ROS control center.
 */
- (BOOL)subscribeToKickStandState;

/*!
 Listen to controls from ROS control center.
 Possible controls are:
 - Forward
 - Backward
 - Left
 - Right
 */
- (BOOL)subscribeToControls;

/*!
 Listen to the motion detection channel.
 */
- (BOOL)subscribeToMotionDetection;

////////////////////////////////// FOR TESTING ////////////////////////////////
- (void)sendTestObjects;

// Camera with ROS:
@property CvVideoCamera *camera;
@property (strong, nonatomic) NSTimer * updateTimer;
@property (strong, nonatomic) NSString * base64;
////////////////////////////////// FOR TESTING ////////////////////////////////

@end
