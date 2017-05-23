//
//  CameraViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 4/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "CameraViewController.h"
#import "ViewController.h"
#import "constants.h"
#import "KairosSDK.h"
#import "TextToSpeech.h"
#import "DoubleRoboticsControl.h"
#import "ApresRecognitionViewController.h"

@interface CameraViewController ()
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *attentionTimer;
@end

@implementation CameraViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if(TESTING_VARIABLES){
        [KairosSDK initWithAppId:@"acabd481" appKey:@"335225fb385fe1cc0dcc4230025448cf"];
        
        [TextToSpeech initializeTalker];
    }
    
    //-------------------------------------------------------------------------//
    //                             DOUBLE CONTROL                              //
    //-------------------------------------------------------------------------//
    
    [DoubleRoboticsControl initializeDRConnection];
    
    
    //-------------------------------------------------------------------------//
    //                           OTHER UI SETTINGS                             //
    //-------------------------------------------------------------------------//
    
    [_titleLabel setAlpha:0.0f];
    [_vImagePreview setAlpha:0.0f];
    [_moveUpButton setAlpha:0.0f];
    [_moveDownButton setAlpha:0.0f];
    [_takePictureButton setAlpha:0.0f];
    [_cancelButton setAlpha:0.0f];
    [_good setAlpha:0.0f];
    [_bad setAlpha:0.0f];
    
    [TextToSpeech continueTalking];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated{
    
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
    
    [UIView animateWithDuration:2.0f animations:^{
        
        [_titleLabel setAlpha:1.0f];
        [_vImagePreview setAlpha:1.0f];
        
    } completion:nil];
    
    NSString *text = @"";
    
    if(!_alreadyBeenHere){
        text = @"Here you can prepare your photo by adjusting the height of the robot with the 2 move buttons. When you are ready to take your picture, press 'Take Picture'. Don't worry if you moved, you will have the chance to retake your picture in the next step.";
    }
    
    [TextToSpeech talkText:[NSString stringWithFormat:@"%@ Please make sure you stand close enough to the camera like the the image on the left.", text]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:5.0f animations:^{
            
            [_good setAlpha:1.0f];
            [_bad setAlpha:1.0];
            
            [_moveDownButton setAlpha:1.0f];
            [_moveUpButton setAlpha:1.0f];
            [_takePictureButton setAlpha:1.0f];
            [_cancelButton setAlpha:1.0f];
            
        } completion:nil];
        
    });
    
    //SET Attention timer:
    _attentionTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(attentionButtons) userInfo:nil repeats:YES];
    
    // !!! IMPORTANT: TIMER !!! //
    // If there is no activity in the next TIMER_TIME_CAMERA seconds, go back to the main screen.
    if(TIMERS_ENABLED){
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_CAMERA
                                                  target:self
                                                selector:@selector(timerFireMethod:)
                                                userInfo:nil
                                                 repeats:NO];
        
        NSLog(@"\n---------------------\n   Starting timer\n---------------------\n");
    }
}

//-------------------------------------------------------------------------//
//                                  TIMER                                  //
//-------------------------------------------------------------------------//

- (void)resetTimer{
    NSLog(@"\n---------------------\n   Canceling timer\n---------------------\n");
    [_timer invalidate];
    _timer = nil;
    
    [_attentionTimer invalidate];
    _attentionTimer = nil;
}

///////////////////////////////////////////////////////////////

- (void)timerFireMethod:(NSTimer *)timer{
    // [TextToSpeech talkText:@"Timeout, returning to home."];
    NSLog(@"\n---------------------\n   Timer expired\n---------------------\n");
    [self performSegueToStart];
}

///////////////////////////////////////////////////////////////


- (void)attentionButtons{
    
    CGFloat h, s, b, a;
    
    [[_moveUpButton backgroundColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_moveUpButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_moveUpButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
            
        }completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5f animations:^{
                [_moveDownButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
                
            }completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5f animations:^{
                    [_moveDownButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
                    
                }completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:0.5f animations:^{
                        [_takePictureButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
                        
                    }completion:^(BOOL finished) {
                        
                        [UIView animateWithDuration:0.5f animations:^{
                            [_takePictureButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
                            
                        }];
                        
                    }];
                }];
                
            }];
            
        }];
    }];
}

//-------------------------------------------------------------------------//
//                                 PREVIEW                                 //
//-------------------------------------------------------------------------//


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
    
    [self.captureSession addOutput:videoOutput];
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [videoOutput setSampleBufferDelegate:self queue:queue];
    
    return YES;
}

///////////////////////////////////////////////////////////////

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    _screenshot = image;
    
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
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

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (IBAction)moveUpPressed:(id)sender {
    [_attentionTimer invalidate];
    NSLog(@"Moving up");
    [DoubleRoboticsControl poleUp];
    
}

- (IBAction)moveDownPressed:(id)sender {
    [_attentionTimer invalidate];
    NSLog(@"Moving down");
    [DoubleRoboticsControl poleDown];
    
}

- (IBAction)takePicturePressed:(id)sender {
    [_attentionTimer invalidate];
    _alreadyBeenHere = YES;
    [self performSegueToApresFR];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self performSegueToStart];
    
}

- (IBAction)moveStop:(id)sender {
    
    NSLog(@"Stop moving");
    [DoubleRoboticsControl poleStop];
    
}

//-------------------------------------------------------------------------//
//                                  SEGUE                                  //
//-------------------------------------------------------------------------//

-(void)performSegueToStart{
    if(SEGUES_ENABLED){
        @try {
            [self performSegueWithIdentifier:@"toStart" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

-(void)performSegueToApresFR{
    if(SEGUES_ENABLED){
        @try {
            [self performSegueWithIdentifier:@"toApresFR" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

///////////////////////////////////////////////////////////////

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    // !!! IMPORTANT: TIMER !!! //
    // Stop the timer before continuing to the next view
    [self resetTimer];
    
    if([segue.identifier isEqualToString:@"toStart"]){
        ViewController *controller = (ViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
    }
    
    if([segue.identifier isEqualToString:@"toApresFR"]){
        
        [TextToSpeech stopTalking];
        
        ApresRecognitionViewController *controller = (ApresRecognitionViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.username = _username;
        controller.user_tag = _user_tag;
        controller.firsttime = _firsttime;
        controller.screenshot = _screenshot;
        controller.alreadyBeenHere = _alreadyBeenHere;
        
    }
}

@end
