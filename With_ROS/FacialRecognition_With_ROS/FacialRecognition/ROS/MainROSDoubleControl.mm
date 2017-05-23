//
//  MainROSDoubleControl.m
//  FacialRecognition
//
//  Created by Kilian on 14/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//
/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/
/*------------------------------------------------------------------------*/
/*                        ROS MAIN CONTROLLER M FILE                      */
/*------------------------------------------------------------------------*/
/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/

#import "MainROSDoubleControl.h"

//// FOR TESTING ////

/////////////////////

NSString *const MainROSDoubleControlNotification = @"MainROSDoubleControlNotification";


@implementation MainROSDoubleControl
@synthesize connectionStatus, session_IP, camera;

- (BOOL)initialiseMainROSDoubleControl:(NSString *)ip_adres{
    
    NSLog(@"\n-------------------------------------------------------------------------\n                MAIN ROS <-> DOUBLE CONTROL STARTUP \n-------------------------------------------------------------------------\n");
    _manager = [[RBManager defaultManager] init];
    _manager.delegate = self;
    
    session_IP = ip_adres;
    
    @try {
        [_manager connect:ip_adres];
        if(![_connectionTimer isValid]){
            [self startConnectionChecker];
        }
        return YES;
    } @catch (NSException *exception) {
        return NO;
    }
}

- (BOOL)disconnectMainROSDoubleControl{
    @try {
        [self cleanup];
        [_manager disconnect];
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not disconnect ROS MAIN CONTROL: %@", exception);
        return NO;
    }
}

-(void)managerDidConnect:(RBManager *)manager{
    // Initialize listeners and/or publishers
    connectionStatus = YES;
    
//    // Start camera:
//    camera = [[CvVideoCamera alloc] init];
//    camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
//    camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
//    camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
//    camera.defaultFPS = 30;
//    camera.grayscaleMode = NO;
//    camera.delegate = self;
//    
//    [camera start];
//    
//    NSLog(@"video camera running: %d", [camera running]);
//    
//    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:CAMERA_UPDATE_SPEED target:self selector:@selector(sendImage) userInfo:nil repeats:YES];
    
    // Send notification
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:1];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"Connection Status"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MainROSDoubleControlNotification object:self userInfo: dict];
    
//    [self.delegate MainROSControlDidConnect];
    [self initialise];
}

-(void)managerDidTimeout:(RBManager *)manager{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:2];
    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"Connection Status"];
    
    [dict setObject:@"Manager did timeout" forKey:@"reason"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MainROSDoubleControlNotification object:self userInfo: dict];

    connectionStatus = NO;
}

-(void)manager:(RBManager *)manager didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:2];
    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"Connection Status"];
    
    [dict setObject:[NSString stringWithFormat:@"Manager did close with code: %li -- reason: %@", (long)code, reason] forKey:@"reason"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MainROSDoubleControlNotification object:self userInfo: dict];

    connectionStatus = NO;
}

-(void)manager:(RBManager *)manager didFailWithError:(NSError *)error{
 
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:2];
    [dict setObject:[NSNumber numberWithBool:NO] forKey:@"Connection Status"];
    
    [dict setObject:[NSString stringWithFormat:@"Manager did fail with error: %@", error] forKey:@"reason"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MainROSDoubleControlNotification object:self userInfo: dict];

    connectionStatus = NO;
}

- (void)managerAlreadyConnected{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:1];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"Connection Status"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MainROSDoubleControlNotification object:self userInfo: dict];
    
    connectionStatus = YES;
}

-(void)startConnectionChecker{
    _connectionTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkConnection) userInfo:nil repeats:YES];
}

- (void)checkConnection{
    if(connectionStatus){
        NSLog(@"Main ROS Control -- Connection: OK");
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:1];
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"Connection Status"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MainROSDoubleControlNotification object:self userInfo: dict];

//        [self.delegate MainRosControlAlreadyConnected];
    }
    else{
        NSLog(@"Main ROS Control -- Connection: Not OK");
        
//        [self.delegate MainRosControlLostConnection:@""];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:1];
        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"Connection Status"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MainROSDoubleControlNotification object:self userInfo: dict];
        
        [self initialiseMainROSDoubleControl:session_IP];
    }
}

/*------------------------------------------------------------------------*/
/*                              ROS PUBLISHERS                            */
/*------------------------------------------------------------------------*/

/*
 Message Type: BoolMessage
 */
- (BOOL)initPublishStatus{
    NSLog(@"Publishing Status");
    
    @try {
        [_statusPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/status";
    
    _statusPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Bool"];
    
    @try {
        [_statusPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishStatus:(BOOL)status{
    NSNumber * messagedata = [NSNumber numberWithBool:status];
    
    BoolMessage * booldata = [[BoolMessage alloc] init];
    
    booldata.data = messagedata;
    
    if(_statusPublisher != nil){
        [_statusPublisher publish:booldata];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: FloatMessage
 */
- (BOOL)initPublishPoleHeightPercentage{
    NSLog(@"Publishing PoleHeightPercentage");
    
    @try {
        [_poleHeightPercentagePublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/actualPoleHeightPercentage";
    
    _poleHeightPercentagePublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Float32"];
    
    @try {
        [_poleHeightPercentagePublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishPoleHeight:(float)heightPercentage{
    NSNumber * messagedata = [NSNumber numberWithFloat:heightPercentage];
    
    FloatMessage * floatdata = [[FloatMessage alloc] init];
    
    floatdata.data = messagedata;
    
    if(_poleHeightPercentagePublisher != nil){
        [_poleHeightPercentagePublisher publish:floatdata];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: FloatMessage
 */
- (BOOL)initPublishBatteryPercentage{
    NSLog(@"Publishing BatteryPercentage");
    
    @try {
        [_batteryPercentagePublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/batteryPercentage";
    
    _batteryPercentagePublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Float32"];
    
    @try {
        [_batteryPercentagePublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishBatteryPercentage:(float)batteryPercentage{
    NSNumber * messagedata = [NSNumber numberWithFloat:batteryPercentage];
    
    FloatMessage * message = [[FloatMessage alloc] init];
    
    message.data = messagedata;
    
    if(_batteryPercentagePublisher != nil){
        [_batteryPercentagePublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: StringMessage
 */
- (BOOL)initPublishSerial{
    NSLog(@"Publishing Serial");
    
    @try {
        [_serialPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/serial";
    
    _serialPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/String"];
    
    @try {
        [_serialPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

-(void)publishSerial:(NSString *)serial{
    NSString * messagedata = serial;
    
    StringMessage * message = [[StringMessage alloc] init];
    
    message.data = messagedata;
    
    if(_serialPublisher != nil){
        [_serialPublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: IntMessage
 */
- (BOOL)initPublishKickStandState{
    NSLog(@"Publishing KickStandState");
    
    @try {
        [_kickStandStatePublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/actualkickStandState";
    
    _kickStandStatePublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Int32"];
    
    @try {
        [_kickStandStatePublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishKickStandState:(int)kickStandState{
    NSNumber * messagedata = [NSNumber numberWithInt:kickStandState];
    
    IntMessage * booldata = [[IntMessage alloc] init];
    
    booldata.data = messagedata;
    
    if(_kickStandStatePublisher != nil){
        [_kickStandStatePublisher publish:booldata];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: BoolMessage
 */
- (BOOL)initPublishBatteryIsFullyCharged{
    NSLog(@"Publishing BatteryIsFullyCharged");
    
    @try {
        [_batteryIsFullyChargedPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/batteryFullyCharged";
    
    _batteryIsFullyChargedPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Bool"];
    
    @try {
        [_batteryIsFullyChargedPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishBatteryIsFullyCharged:(BOOL)batteryIsFullyCharged{
    NSNumber * messagedata = [NSNumber numberWithBool:batteryIsFullyCharged];
    
    BoolMessage * booldata = [[BoolMessage alloc] init];
    
    booldata.data = messagedata;
    
    if(_batteryPercentagePublisher != nil){
        [_batteryPercentagePublisher publish:booldata];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: IntMessage
 */
- (BOOL)initPublishFirmwareVersion{
    NSLog(@"Publishing FirmwareVersion");
    
    @try {
        [_firmwareVersionPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/firmwareVersion";
    
    _firmwareVersionPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/String"];
    
    @try {
        [_firmwareVersionPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishFirmwareVersion:(NSString*)firmwareVersion{
    NSString * messagedata = firmwareVersion;
    
    StringMessage * stringdata = [[StringMessage alloc] init];
    
    stringdata.data = messagedata;
    
    if(_firmwareVersionPublisher != nil){
        [_firmwareVersionPublisher publish:stringdata];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: NavSatFixMessage
 */
- (BOOL)initPublishLocation{
    NSLog(@"Publishing Location");
    
    @try {
        [_locationPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/location";
    
    _locationPublisher = [_manager addPublisher:publisher messageType:@"sensor_msgs/NavSatFix"];
    
    @try {
        [_locationPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishLocation:(CLLocation *)location{
    NSNumber *latitude = [NSNumber numberWithFloat: location.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithFloat: location.coordinate.longitude];
    NSNumber *altitude = [NSNumber numberWithFloat: location.altitude];
    
    NSNumber * status;
    if (location.horizontalAccuracy < 0)
    {
        // No Signal
        status = [NSNumber numberWithInteger:-1];
    }
    else if (location.horizontalAccuracy > 163)
    {
        // Poor Signal
        status = [NSNumber numberWithInteger:0];
    }
    else if (location.horizontalAccuracy > 48)
    {
        // Average Signal
        status = [NSNumber numberWithInteger:1];
    }
    else
    {
        // Full Signal
        status = [NSNumber numberWithInteger:2];
    }
    
    NavSatStatusMessage * statusMessage = [[NavSatStatusMessage alloc] init];
    
    // Check how good the signal is.
    statusMessage.status = status;
    
    // Apple uses all the systems together so...just set to GPS.
    statusMessage.service = [NSNumber numberWithInteger:1];
    
    NavSatFixMessage * navMessage = [[NavSatFixMessage alloc] init];
    
    navMessage.status = statusMessage;
    
    navMessage.latitude = latitude;
    navMessage.longitude = longitude;
    navMessage.altitude = altitude;
    
    NSArray * position_covariance;
    navMessage.position_covariance = position_covariance;
    
    NSNumber * position_covariance_type = [NSNumber numberWithInteger:0];
    navMessage.position_covariance_type = position_covariance_type;
    
    if(_locationPublisher != nil){
        [_locationPublisher publish:navMessage];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: BoolMessage
 */
- (BOOL)initPublishMotionDetection{
    NSLog(@"Publishing MotionDetection");
    
    @try {
        [_motionDetectionPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/motionDetection";
    
    _motionDetectionPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Bool"];
    
    @try {
        [_motionDetectionPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishMotionDetection:(BOOL)motionDetection{
    NSNumber * messagedata = [NSNumber numberWithBool:motionDetection];
    
    BoolMessage * booldata = [[BoolMessage alloc] init];
    
    booldata.data = messagedata;
    
    if(_motionDetectionPublisher != nil){
        [_motionDetectionPublisher publish:booldata];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: CompressedImage
 */
- (BOOL)initPublishImage{
    NSLog(@"Publishing Image");
    
    @try {
        [_imagePublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/userPhoto";
    
    _imagePublisher = [_manager addPublisher:publisher messageType:@"sensor_msgs/CompressedImage"];
    
    @try {
        [_imagePublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishImage:(NSString*)image{
    
    CompressedImage *imgdata = [[CompressedImage alloc]init];
    imgdata.format = @"jpeg";
    imgdata.data = image;
    
    if(_imagePublisher != nil){
        [_imagePublisher publish:imgdata];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }}

/*
 Message Type: Int32
 */
- (BOOL)initPublishFail{
    NSLog(@"Publishing Fails");
    
    @try {
        [_failPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/fails";
    
    _failPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Int32"];
    
    @try {
        [_failPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishFail:(int)fails{
    
    IntMessage * message = [[IntMessage alloc] init];
    message.data = [NSNumber numberWithInt:fails];
    if(_failPublisher != nil){
        [_failPublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
}


/*
 Message Type: Int32
 */
- (BOOL)initPublishSuccess{
    NSLog(@"Publishing Success");
    
    @try {
        [_succesPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/success";
    
    _succesPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Int32"];
    
    @try {
        [_succesPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishSuccess:(int)success{
    
    IntMessage * message = [[IntMessage alloc] init];
    message.data = [NSNumber numberWithInt:success];
    if(_succesPublisher != nil){
        [_succesPublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
}


/*
 Message Type: String
 */
- (BOOL)initPublishFacialRecognitionMessage{
    NSLog(@"Publishing Facial Recognition Message");
    
    @try {
        [_facialRecognitionMessagePublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/facialRecognitionMessage";
    
    _facialRecognitionMessagePublisher = [_manager addPublisher:publisher messageType:@"std_msgs/String"];
    
    @try {
        [_facialRecognitionMessagePublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishFacialRecogntionMessage:(NSString *)message{
    
    StringMessage * FR_message = [[StringMessage alloc] init];
    FR_message.data = message;
    if(_facialRecognitionMessagePublisher != nil){
        [_facialRecognitionMessagePublisher publish:FR_message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
}


/*
 Message Type: BoolMessage
 */
- (BOOL)initPublishSessionSet{
    NSLog(@"Publishing SessionSet");
    
    @try {
        [_sessionSetPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/sessionSet";
    
    _sessionSetPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Bool"];
    
    @try {
        [_sessionSetPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishSessionSet:(BOOL)sessionSet{
    
    BoolMessage * message = [[BoolMessage alloc] init];
    message.data = [NSNumber numberWithBool:sessionSet];
    if(_sessionSetPublisher != nil){
        [_sessionSetPublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
}


/*
 Message Type: Time
 */
- (BOOL)initPublishSession{
    NSLog(@"Publishing Session");
    
    @try {
        [_sessionPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/session";
    
    _sessionPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Time"];
    
    @try {
        [_sessionPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishSession:(NSDate *)session{
    
    TimeMessage * message = [[TimeMessage alloc] init];
    message.data = [NSNumber numberWithDouble:[session timeIntervalSinceReferenceDate]];
    if(_sessionPublisher != nil){
        [_sessionPublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
}

/*
 Message Type: String
 */
- (BOOL)initPublishUserTag{
    NSLog(@"Publishing User Tag");
    
    @try {
        [_user_tagPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/userTag";
    
    _user_tagPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/String"];
    
    @try {
        [_user_tagPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishUserTag:(NSString *)user_tag{
    
    StringMessage * message = [[StringMessage alloc] init];
    message.data = user_tag;
    if(_user_tagPublisher != nil){
        [_user_tagPublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
    
}

/*
 Message Type: String
 */
- (BOOL)initPublishUsername{
    NSLog(@"Publishing Username");
    
    @try {
        [_usernamePublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/username";
    
    _usernamePublisher = [_manager addPublisher:publisher messageType:@"std_msgs/String"];
    
    @try {
        [_usernamePublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishUsername:(NSString *)username{
    
    StringMessage * message = [[StringMessage alloc] init];
    message.data = username;
    if(_usernamePublisher != nil){
        [_usernamePublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
}

/*
 Message Type: Bool
 */
- (BOOL)initPublishFirstTime{
    NSLog(@"Publishing First Time");
    
    @try {
        [_firsttimePublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/firstTime";
    
    _firsttimePublisher = [_manager addPublisher:publisher messageType:@"std_msgs/Bool"];
    
    @try {
        [_firsttimePublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishFirstTime:(BOOL)firsttime{
    
    BoolMessage * message = [[BoolMessage alloc] init];
    message.data = [NSNumber numberWithBool:firsttime];
    if(_firsttimePublisher != nil){
        [_firsttimePublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
}

/*
 Message Type: String
 */
- (BOOL)initPublishString{
    NSLog(@"Publishing String");
    
    @try {
        [_stringPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Double_1/stringChannel";
    
    _stringPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/String"];
    
    @try {
        [_stringPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishString:(NSString *)phrase{
    
    NSLog(@"Publishing: %@", phrase);
    
    NSString * messagedata = phrase;
    
    StringMessage * message = [[StringMessage alloc] init];
    
    message.data = messagedata;
    
    if(_stringPublisher != nil){
        [_stringPublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
}

/*
 Message Type: String
 */
- (BOOL)initPublishViewFlow{
    NSLog(@"Publishing View Flow");
    
    @try {
        [_viewFlowPublisher unadvertise];
        NSLog(@"Unadvertised! (Just to be sure)");
    } @catch (NSException *exception) {
        NSLog(@"Could not unadvertise.");
    }
    
    NSString * publisher =  @"/Application/viewFlow";
    
    _viewFlowPublisher = [_manager addPublisher:publisher messageType:@"std_msgs/String"];
    
    @try {
        [_viewFlowPublisher advertise];
        NSLog(@"Advertising!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not advertise.");
        return NO;
    }
}

- (void)publishViewFlow:(NSString *)viewFlow{
    
    NSLog(@"Publishing: %@", viewFlow);
    
    NSString * messagedata = viewFlow;
    
    StringMessage * message = [[StringMessage alloc] init];
    
    message.data = messagedata;
    if(_viewFlowPublisher != nil){
        [_viewFlowPublisher publish:message];
    }
    else{
        NSLog(@"!!!     Failed to publish     !!!");
    }
}

/*------------------------------------------------------------------------*/
/*                              ROS SUBSCRIBERS                           */
/*------------------------------------------------------------------------*/

/*
 Message Class: FloatMessage
 */
- (BOOL)subscribeToPoleHeightPercentage{
    NSLog(@"Subscribing PoleHeightPercentage");
    
    @try {
        [_poleHeightPercentageSubscriber unsubscribe];
        NSLog(@"Unsubscribed.");
    } @catch (NSException *exception) {
        NSLog(@"Could not unsubscribe.");
    }
    
    NSString * subscriber = @"/Double_1/desiredPoleHeightPercentage";
    _poleHeightPercentageSubscriber = [_manager addSubscriber:subscriber responseTarget:self selector:@selector(poleHeightMessageUpdate:) messageClass: [BoolMessage class]];
    
    _poleHeightPercentageSubscriber.throttleRate = 100;
    
    @try {
        [_poleHeightPercentageSubscriber subscribe];
        NSLog(@"Subscribed!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not subscribe.");
        return NO;
    }
}

/*
 Message Class: IntMessage
 */
- (BOOL)subscribeToKickStandState{
    NSLog(@"Subscribing KickStandState");
    
    @try {
        [_kickStandStateSubscriber unsubscribe];
        NSLog(@"Unsubscribed.");
    } @catch (NSException *exception) {
        NSLog(@"Could not unsubscribe.");
    }
    
    NSString * subscriber = @"/Double_1/desiredkickStandState";
    _kickStandStateSubscriber = [_manager addSubscriber:subscriber responseTarget:self selector:@selector(KickStandStateMessageUpdate:) messageClass: [IntMessage class]];
    
    _kickStandStateSubscriber.throttleRate = 100;
    
    @try {
        [_kickStandStateSubscriber subscribe];
        NSLog(@"Subscribed!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not subscribe.");
        return NO;
    }
}

/*
 Message Class: TwistMessage
 */
- (BOOL)subscribeToControls{
    NSLog(@"Subscribing Controls");
    
    @try {
        [_controlsSubscriber unsubscribe];
        NSLog(@"Unsubscribed.");
    } @catch (NSException *exception) {
        NSLog(@"Could not unsubscribe.");
    }
    
    NSString * subscriber = @"/Double_1/controls";
    _controlsSubscriber = [_manager addSubscriber:subscriber responseTarget:self selector:@selector(ControlsMessageUpdate:) messageClass: [TwistMessage class]];
    
    _controlsSubscriber.throttleRate = 100;
    
    @try {
        [_controlsSubscriber subscribe];
        NSLog(@"Subscribed!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not subscribe.");
        return NO;
    }
}

/*
 Message Class: BoolMessage
 */
- (BOOL)subscribeToMotionDetection{
    NSLog(@"Subscribing MotionDetection");
    
    @try {
        [_motionDetectionSubscriber unsubscribe];
        NSLog(@"Unsubscribed.");
    } @catch (NSException *exception) {
        NSLog(@"Could not unsubscribe.");
    }
    
    NSString * subscriber = @"/Double_1/motionDetection";
    _motionDetectionSubscriber = [_manager addSubscriber:subscriber responseTarget:self selector:@selector(MotionDetectionMessageUpdate:) messageClass: [BoolMessage class]];
    
    _motionDetectionSubscriber.throttleRate = 100;
    
    @try {
        [_motionDetectionSubscriber subscribe];
        NSLog(@"Subscribed!");
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not subscribe.");
        return NO;
    }
}


/*------------------------------------------------------------------------*/
/*                               ROS DELEGATES                            */
/*------------------------------------------------------------------------*/

/*
 Delegate function.
 Message Class: FloatMessage
 */
- (void)poleHeightMessageUpdate:(FloatMessage *)message{
    NSLog(@"\n--------------------------------------------\npoleHeightMessageUpdate: %@\n--------------------------------------------\n", message.data);
    if ([self.delegate respondsToSelector:@selector(messageUpdate_poleHeightPercentage:)] ){
        [self.delegate messageUpdate_poleHeightPercentage:message];
    }
}

/*
 Delegate function.
 Message Class: IntMessage
 */
- (void)KickStandStateMessageUpdate:(IntMessage *)message{
    NSLog(@"\n--------------------------------------------\nKickStandStateMessageUpdate: %@\n--------------------------------------------\n", message.data);
    if ([self.delegate respondsToSelector:@selector(messageUpdate_kickStandState:)] ){
        [self.delegate messageUpdate_kickStandState:message];
    }
}

/*
 Delegate function.
 Message Class: TwistMessage
 */
- (void)ControlsMessageUpdate:(TwistMessage *)message{
    NSLog(@"\n--------------------------------------------\n"
          "ControlsMessageUpdate: \n"
          "Linear x: %@\n"
          "Linear y: %@\n"
          "Linear z: %@\n"
          "Angular x: %@\n"
          "Angular y: %@\n"
          "Angular z: %@"
          "\n--------------------------------------------\n", message.linear.x,message.linear.y,message.linear.z,message.angular.x,message.angular.y,message.angular.z);
    if ([self.delegate respondsToSelector:@selector(messageUpdate_Controls:)] ){
        [self.delegate messageUpdate_Controls:message];
    }
}

/*
 Delegate function.
 Message Class: BoolMessage
 */
- (void)MotionDetectionMessageUpdate:(BoolMessage *)message{
    NSLog(@"\n--------------------------------------------\nMotionDetectionMessageUpdate: %@\n--------------------------------------------\n", message.data);
    if ([self.delegate respondsToSelector:@selector(messageUpdate_MotionDetection:)] ){
        [self.delegate messageUpdate_MotionDetection:message];
    }
}

/*------------------------------------------------------------------------*/
/*                                ROS CONTROL                             */
/*------------------------------------------------------------------------*/

- (BOOL)initialise
{
    NSLog(@"initializing init");
    if(![self initPublishStatus]){
        return NO;
    }
    if(![self initPublishPoleHeightPercentage]){
        return NO;
    }
    if(![self initPublishBatteryPercentage]){
        return NO;
    }
    if(![self initPublishSerial]){
        return NO;
    }
    if(![self initPublishKickStandState]){
        return NO;
    }
    if(![self initPublishBatteryIsFullyCharged]){
        return NO;
    }
    if(![self initPublishFirmwareVersion]){
        return NO;
    }
    if(![self initPublishLocation]){
        return NO;
    }
    if(![self initPublishMotionDetection]){
        return NO;
    }
    if(![self initPublishImage]){
        return NO;
    }
    if(![self initPublishFail]){
        return NO;
    }
    if(![self initPublishFacialRecognitionMessage]){
        return NO;
    }
    if(![self initPublishSuccess]){
        return NO;
    }
    if(![self initPublishSessionSet]){
        return NO;
    }
    if(![self initPublishSession]){
        return NO;
    }
    if(![self initPublishUserTag]){
        return NO;
    }
    if(![self initPublishUsername]){
        return NO;
    }
    if(![self initPublishFirstTime]){
        return NO;
    }
    if(![self initPublishString]){
        return NO;
    }
    if(![self initPublishViewFlow]){
        return NO;
    }
    if(![self subscribeToPoleHeightPercentage]){
        return NO;
    }
    if(![self subscribeToKickStandState]){
        return NO;
    }
    if(![self subscribeToControls]){
        return NO;
    }
    if(![self subscribeToMotionDetection]){
        return NO;
    }
    [self.delegate MainROSControlDidConnect];
    return YES;
}

- (void)cleanup{
    [_kickStandStatePublisher unadvertise];
    [_firmwareVersionPublisher unadvertise];
    [_batteryPercentagePublisher unadvertise];
    [_batteryIsFullyChargedPublisher unadvertise];
    [_serialPublisher unadvertise];
    [_poleHeightPercentagePublisher unadvertise];
    [_statusPublisher unadvertise];
    [_controlsPublisher unadvertise];
    [_locationPublisher unadvertise];
    [_motionDetectionPublisher unadvertise];
    [_imagePublisher unadvertise];
    [_stringPublisher unadvertise];
    [_failPublisher unadvertise];
    [_succesPublisher unadvertise];
    [_facialRecognitionMessagePublisher unadvertise];
    [_sessionSetPublisher unadvertise];
    [_sessionPublisher unadvertise];
    [_user_tagPublisher unadvertise];
    [_usernamePublisher unadvertise];
    [_firsttimePublisher unadvertise];
    [_viewFlowPublisher unadvertise];
}

////////////////////////////////// FOR TESTING ////////////////////////////////

- (void)sendTestObjects{
    for(int i = 0 ; i < 5 ; i++){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self publishStatus:YES];
            [self publishBatteryPercentage:arc4random_uniform(100)];
            [self publishBatteryIsFullyCharged:NO];
            [self publishPoleHeight:arc4random_uniform(100)];
            [self publishSerial:@"10.203 - 2038"];
            [self publishMotionDetection:YES];
            [self publishFirmwareVersion:@"firmware blabla"];
            [self publishKickStandState:arc4random_uniform(4)];
        });
    }
}

- (void)sendImage{
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.KM.ROSApplication.imageSender.bgqueue", NULL);
    
    dispatch_async(backgroundQueue, ^(void) {
        
        [self publishImage: _base64];
        
    });
}

- (void)processImage:(cv::Mat &)image{
    
    NSData *data = [NSData dataWithBytes:image.data length:image.elemSize()*image.total()];
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(image.cols,                                 //width
                                        image.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * image.elemSize(),                       //bits per pixel
                                        image.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    NSData * sendImage = UIImageJPEGRepresentation(finalImage, 1.0);
    
    _base64 = [sendImage base64EncodedStringWithOptions:kNilOptions];
    
}

////////////////////////////////// FOR TESTING ////////////////////////////////

@end
