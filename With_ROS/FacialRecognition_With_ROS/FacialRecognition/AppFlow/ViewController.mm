//
//  ViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 30/03/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "ViewController.h"
#import "KairosSDK.h"
#import <AVFoundation/AVFoundation.h>
#import "GreetingUnknownViewController.h"
#import "TextToSpeech.h"
#import "GreetingKnownViewController.h"
#import "AttentionViewController.h"

#import "constants.h"

BOOL startDetecting;

@interface ViewController ()
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) NSTimer * motionTimer;
@property double secondsToMotion;
@property (strong, nonatomic) NSTimer * connectionTimer;
@property (strong, nonatomic) UIImage * connectedImage;
@property (strong, nonatomic) UIImage * notConnectedImage;

@property (strong, nonatomic) UIImageView * statusDouble;
@property (strong, nonatomic) UIImageView * statusROS;
@end

@implementation ViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"\n\n--------------------------------------------------------\n                        NEW VIEW\n--------------------------------------------------------\n\n");
    
    _connectedImage = [UIImage imageNamed:@"Connected.png"];
    _notConnectedImage = [UIImage imageNamed:@"NotConnected.png"];
    
    if(!_connectedImage){
        NSLog(@"%@",@"Image Not Found");
    }
    if(!_notConnectedImage){
        NSLog(@"%@",@"Image Not Found");
    }
    
    //-------------------------------------------------------------------------//
    //                                   ROS                                   //
    //-------------------------------------------------------------------------//
    
    static dispatch_once_t onceToken_ROSControl;
    dispatch_once(&onceToken_ROSControl, ^{
        
        _ROSController = [[MainROSDoubleControl alloc] init];
        [_ROSController initialiseMainROSDoubleControl:IP_ROS_ROBOT];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateROSMainControlConnectionStatus:) name:MainROSDoubleControlNotification object:nil];
    
    _statusROS = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _connectionStatusROS.frame.size.width, _connectionStatusROS.frame.size.width)];
    
    _statusROS.image = _notConnectedImage;
    
    [_connectionStatusROS addSubview:_statusROS];
    
    //-------------------------------------------------------------------------//
    //                                 TALKING                                 //
    //-------------------------------------------------------------------------//
    
    [TextToSpeech initializeTalker];
    
    //-------------------------------------------------------------------------//
    //                         OTHER PARAMETER SETTINGS                        //
    //-------------------------------------------------------------------------//
    
    _session = [NSDate date];
    _sessionSet = YES;
    
    [_ROSController publishSession:_session];
    [_ROSController publishSessionSet:YES];
    
    
    //-------------------------------------------------------------------------//
    //                        MOTION DETECTION STARTUP                         //
    //-------------------------------------------------------------------------//
    
    startDetecting = NO;
    
    // Insert wait time before detection starts.
    // Gives time for the previous user to walk away.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DELAY_BEFORE_MOTION_DETECTION_STARTUP * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        startDetecting = YES;
    });
    
    [self startMotionDetection];
    
    //-------------------------------------------------------------------------//
    //                                 COUNTER                                 //
    //-------------------------------------------------------------------------//
    
    [self updateCounter];
    
    //-------------------------------------------------------------------------//
    //                             DOUBLE CONTROL                              //
    //-------------------------------------------------------------------------//

        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDoubleConnectionStatus:) name:DoubleControlNotification object:[DoubleRoboticsControl sharedInstance]];
    
    _statusDouble = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _connectionStatusDouble.frame.size.width, _connectionStatusDouble.frame.size.width)];
    
    _statusDouble.image = _notConnectedImage;
    
    [_connectionStatusDouble addSubview:_statusDouble];
    
    //-------------------------------------------------------------------------//
    //                                  TIMER                                  //
    //-------------------------------------------------------------------------//
    
    _secondsToMotion = DELAY_BEFORE_MOTION_DETECTION_STARTUP;
    
    _motionTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(updateCounterLabel) userInfo:nil repeats:YES];
    
}

///////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated{
    
    [[DoubleRoboticsControl sharedInstance] initializeDRConnection];
    
    
    
}

///////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-------------------------------------------------------------------------//
//                                   UI                                    //
//-------------------------------------------------------------------------//

- (void)updateCounterLabel{
    
    _secondsToMotion -= 0.005;
    
    if(_secondsToMotion > 1){
        _counterLabel.text = [NSString stringWithFormat:@"I will start my program in %0.2f seconds...", _secondsToMotion];
    }
    else if(_secondsToMotion > 0 && _secondsToMotion <= 1){
        _counterLabel.text = [NSString stringWithFormat:@"I will start my program in %0.2f second...", _secondsToMotion];
    }
    else{
        _counterLabel.text = @"Motion detection started...";
    }
}


//-------------------------------------------------------------------------//
//                            MOTION DETECTION                             //
//-------------------------------------------------------------------------//

- (void)startMotionDetection{
    
    NSLog(@"startMotionDetection");
    
    self.videoMotionDetector = [[MotionDetectingVideoOutputAnalizer alloc] init];
    [self.videoMotionDetector setMotionDetectingDelegate:self];
    self.captureSession = [AVCaptureSession new];
    BOOL initializingSuccess = [self initializeVideoCapturing];
    if (initializingSuccess)
    {
        [self.captureSession startRunning];
    }
    else
    {
        NSLog(@"Can not initialize video capturing");
    }
    
}

///////////////////////////////////////////////////////////////

-(BOOL)initializeVideoCapturing
{
    if (![self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])
    {
        return NO;
    }
    
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    NSArray * videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if ([videoDevices count] <= 0)
    {
        return NO;
    }
    
    AVCaptureDevice * cameraDevice = [self frontCamera];
    
    AVCaptureDeviceInput * cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:NULL];
    if (![self.captureSession canAddInput:cameraInput])
    {
        return NO;
    }
    [self.captureSession addInput:cameraInput];
    
    AVCaptureVideoPreviewLayer * previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setDelegate:self];
    
    previewLayer.frame = self.vImagePreview.bounds;
    [self.vImagePreview.layer addSublayer:previewLayer];
    
    self.vImagePreview.transform = CGAffineTransformMakeRotation(M_PI);
    
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    if (!videoDataOutputQueue)
    {
        return NO;
    }
    AVCaptureVideoDataOutput * videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSArray * aviablePixelFormates = [videoOutput availableVideoCVPixelFormatTypes];
    if (![aviablePixelFormates containsObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]])
    {
        return NO;
    }
    [videoOutput setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil]];
    
    [videoOutput setSampleBufferDelegate:self.videoMotionDetector queue:videoDataOutputQueue];
    
    [self.captureSession addOutput:videoOutput];
    
    return YES;
}

///////////////////////////////////////////////////////////////

- (AVCaptureDevice *)frontCamera {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

///////////////////////////////////////////////////////////////

-(void) videoMotionStartOccuring
{
    NSLog(@"Motion Detected\n");
    dispatch_async(dispatch_get_main_queue(), ^{
        if(startDetecting == YES){
            _motionWarning.text = @"Motion detected.";
            
            [_ROSController publishMotionDetection:YES];
            if([_ROSController connectionStatus]){
                [self performSegueToAttention];
            }
        }
    });
}

///////////////////////////////////////////////////////////////

-(void) videoMotionStopOccuring
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(startDetecting == YES){
            _motionWarning.text = @"No motion detected.";
        }
    });
}

-(void) stopMotionDetection{
    [self.captureSession stopRunning];
}

//-------------------------------------------------------------------------//
//                                 STATISTICS                              //
//-------------------------------------------------------------------------//

- (void)updateCounter{
    dispatch_async(dispatch_get_main_queue(), ^{
        int total = _fail + _success;
        
        if(total > 1){
            _footnoteText.text = [NSString stringWithFormat: @"(So far %d people have participated.)\n%d recognised + %d not recognised", total, _success, _fail];
        }
        else if(total == 1){
            _footnoteText.text = [NSString stringWithFormat: @"(So far %d person has participated.)\n%d recognised + %d not recognised", total, _success, _fail];
        }
    });
}

//-------------------------------------------------------------------------//
//                                  SEGUE                                  //
//-------------------------------------------------------------------------//

-(void)performSegueToAttention{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to Attention..."];
            [self performSegueWithIdentifier:@"toAttention" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

///////////////////////////////////////////////////////////////

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MainROSDoubleControlNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DoubleControlNotification object:nil];

    
    [self stopMotionDetection];
    
    if([segue.identifier isEqualToString:@"toAttention"]){
        AttentionViewController *controller = (AttentionViewController *)segue.destinationViewController;
        
        // Temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        controller.ROSController = _ROSController;
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
    }
}

//-------------------------------------------------------------------------//
//                                HANDLING                                 //
//-------------------------------------------------------------------------//

- (void)applicationDidEnterForeground:(UIApplication *)application {
    
    [self startMotionDetection];
    
}

///////////////////////////////////////////////////////////////

-(void)applicationWillTerminate:(NSNotification *)notification
{
    if ([self.captureSession isRunning])
    {
        [self.captureSession stopRunning];
    }
}

///////////////////////////////////////////////////////////////

- (void)updateROSMainControlConnectionStatus:(NSNotification*)notification{
    NSDictionary *dict = [notification userInfo];
    BOOL connectionStatusROS = [[dict valueForKey:@"Connection Status"] boolValue];
    if(connectionStatusROS){
        
        NSLog(@"ViewController -- updateROSMainControlConnectionStatus -- Connected to ROS");
        _statusROS.image = nil;
        [_statusROS setImage:_connectedImage];
    }
    else{
        
        NSString * reason = [dict valueForKey:@"reason"];
        NSLog(@"ViewController -- updateROSMainControlConnectionStatus -- Connection failed:\n \n%@\n \n", reason);
        _statusROS.image = nil;
        [_statusROS setImage:_notConnectedImage];
    }
}

///////////////////////////////////////////////////////////////

- (void) updateDoubleConnectionStatus: (NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    BOOL connectionStatusDouble = [[dict valueForKey:@"Connection Status"] boolValue];
    
    if(connectionStatusDouble){
        NSLog(@"ViewController -- updateDoubleConnectionStatus -- Double is Connected");
        _statusDouble.image = nil;
        [_statusDouble setImage:_connectedImage];
        _connectedToDouble = YES;
    }
    else{
        
        NSLog(@"ViewController -- updateDoubleConnectionStatus -- Double is not Connected");
        _statusDouble.image = nil;
        [_statusDouble setImage:_notConnectedImage];
        
        _connectedToDouble = NO;
    }
}

@end
