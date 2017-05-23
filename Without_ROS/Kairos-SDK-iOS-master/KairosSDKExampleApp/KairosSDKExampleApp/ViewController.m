//
//  ViewController.m
//  KairosSDKExampleApp
//
//  Created by Eric Turner on 7/27/14.
//  Copyright (c) 2014 Kairos. All rights reserved.
//

#import "ViewController.h"
#import "KairosSDK.h"
#import "SecondViewController.h"
#import "NewFaceViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>

NSString *fetchedName;
NSData *prev_img;
NSData *new_img;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //-------------------------------------------------------------------------//
    //                             AUTHENTIFICATION                            //
    //-------------------------------------------------------------------------//
    
    
    [KairosSDK initWithAppId:@"acabd481" appKey:@"335225fb385fe1cc0dcc4230025448cf"];
    
    
    //-------------------------------------------------------------------------//
    //                            PARAMETER SETTINGS                           //
    //-------------------------------------------------------------------------//
    
    
    [KairosSDK setPreferredCameraType:KairosCameraFront];
    [KairosSDK setEnableFlash:NO];
    [KairosSDK setEnableShutterSound:NO];
    [KairosSDK setStillImageTintColor:@"DBDB4D"];
    [KairosSDK setProgressBarTintColor:@"FFFF00"];
    [KairosSDK setMinimumSessionFrames: 50];
    [KairosSDK setErrorMessageMoveCloser:@"Please make sure your face is visible."];
    [KairosSDK setErrorMessageFaceScreen:@"Please make sure your face is visible."];
    [KairosSDK setErrorMessageHoldStill:@"Please hold the iPad still."];
    
    //-------------------------------------------------------------------------//
    //                                 COUNTER                                 //
    //-------------------------------------------------------------------------//
    
    int total = _fail + _success;
    
    if(total > 1){
        _footnoteText.text = [NSString stringWithFormat: @"(So far %d people have participated.)", total];
    }
    else if(total == 1){
        _footnoteText.text = [NSString stringWithFormat: @"(So far %d person has participated.)", total];
    }
    
    //-------------------------------------------------------------------------//
    //                                 TALKING                                 //
    //-------------------------------------------------------------------------//
    
    /*
     
     NSString *text = @"Hello, this is the iPad talking. If you want, I can recognize you.";
     
     AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
     AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
     [syn speakUtterance:utterance];
     
     */
    
    //[self kairosSDKExampleMethod];
    
    //-------------------------------------------------------------------------//
    //                                  MOTION                                 //
    //-------------------------------------------------------------------------//
    
    videoMotionDetector = [[MotionDetectingVideoOutputAnalizer alloc] init];
    [videoMotionDetector setMotionDetectingDelegate:self];
    captureSession = [[AVCaptureSession alloc] init];
    BOOL initializingSuccess = [self initializeVideoCapturing];
    if (initializingSuccess)
    {
        [captureSession startRunning];
    }
    else
    {
        NSLog(@"Can not initialize video capturing");
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-------------------------------------------------------------------------//
//                             TESTING BUTTON                              //
//-------------------------------------------------------------------------//

- (IBAction)tappedStartButton:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!"
                                                    message:@"Is this the first time you use this application? :)\nIf so, please insert your name for our database and press continue!"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Continue", @"I've seen this before", @"Delete my face (first type your name)",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];

    
//    [self kairosSDKExampleMethod];
    
}

//-------------------------------------------------------------------------//
//                            MOTION DETECTION                             //
//-------------------------------------------------------------------------//

-(BOOL)initializeVideoCapturing
{
    if (![captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])
    {
        return NO;
    }
    
    [captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    NSArray * videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if ([videoDevices count] <= 0)
    {
        return NO;
    }
    
    AVCaptureDevice * cameraDevice = [self frontCamera];
    
    AVCaptureDeviceInput * cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:NULL];
    if (![captureSession canAddInput:cameraInput])
    {
        return NO;
    }
    [captureSession addInput:cameraInput];
    
    AVCaptureVideoPreviewLayer * previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setDelegate:self];
    
    previewLayer.frame = self.vImagePreview.bounds;
    [self.vImagePreview.layer addSublayer:previewLayer];
    
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
    
    [videoOutput setSampleBufferDelegate:videoMotionDetector queue:videoDataOutputQueue];
    
    [captureSession addOutput:videoOutput];
    
    return YES;
}


- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

-(void) videoMotionStartOccuring
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = @"Hello";
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
        AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
        [syn speakUtterance:utterance];
        _motionWarning.text = @"Motion detected.";
    });
    
}

-(void) videoMotionStopOccuring
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _motionWarning.text = @"No motion detected.";
    });
}

//-------------------------------------------------------------------------//
//                                  MAIN                                   //
//-------------------------------------------------------------------------//

- (void)kairosSDKExampleMethod
{
    [KairosSDK imageCaptureRecognizeWithThreshold:@".75"
                                      galleryName:@"MyGallery"
                                          success:^(NSDictionary *response, UIImage *image) {
                                              
                                              NSLog(@"%@", response);
                                              NSString * transaction = [response valueForKeyPath:@"images.transaction"];
                                              NSString * message = [[transaction valueForKey:@"message"] componentsJoinedByString:@""];
                                              message = [message stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                              message = [message stringByReplacingOccurrencesOfString:@")" withString:@""];
                                              message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                              
                                              NSLog(@"\n\nTHE MESSAGE WAS: %@\n", message);
                                              // Fetch the message.
                                              if(message != NULL) {
                                                  
                                                  if([message isEqual:@"No match found"]){
                                                      NSString *text = @"It looks like I could not recognize you. Have you been here before?";
                                                      
                                                      AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
                                                      AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
                                                      [syn speakUtterance:utterance];
                                                      
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!"
                                                                                                      message:@"Is this the first time you use this application? :)\nIf so, please insert your name for our database and press continue!"
                                                                                                     delegate:self
                                                                                            cancelButtonTitle:@"Cancel"
                                                                                            otherButtonTitles:@"Continue", @"I've seen this before",nil];
                                                      alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                                                      
                                                      [alert show];

                                                  }
                                                  else{
                                                      // Get the names of the person.
                                                      fetchedName = [response valueForKeyPath:@"images.candidates"];
                                                      
                                                      if(fetchedName == NULL){
                                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                                          message:@"It looks like I could not recognize you.\nPlease try again!"
                                                                                                         delegate:self
                                                                                                cancelButtonTitle:@"Continue"
                                                                                                otherButtonTitles:nil];
                                                          
                                                          [alert show];
                                                      }
                                                      else{
                                                          
                                                          NSLog(@"\nFETCHED NAME(S):\n%@\n\n", fetchedName);
                                                          
                                                          [self performSegueWithIdentifier:@"toHello" sender:self];
                                                      }
                                                  }
                                                  
                                              } else{
                                                  NSString *errors = [response valueForKeyPath:@"Errors"];
                                                  NSString *error = [[errors valueForKey:@"Message"] componentsJoinedByString:@""];
                                                  error = [error stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                                  error = [error stringByReplacingOccurrencesOfString:@")" withString:@""];
                                                  error = [error stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                                  
                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                                  message:[NSString stringWithFormat:@"The error was: %@", error]
                                                                                                 delegate:self
                                                                                        cancelButtonTitle:@"Continue"
                                                                                        otherButtonTitles:nil];
                                                  
                                                  [alert show];
                                              }
                                          } failure:^(NSDictionary *response, UIImage *image) {
                                              
                                              NSLog(@"\n\n--- FAILED TO RECOGNISE! ---\n");
                                              NSLog(@"%@", response);
                                              
                                          }];
    
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!"
//                                                        message:@"Is this the first time you use this application? :)\nIf so, please insert your name for our database and press continue!"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                              otherButtonTitles:@"Continue", @"I've seen this before", @"Delete my face (first type your name)",nil];
//        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    
//        [alert show];
    
    
}

//-------------------------------------------------------------------------//
//                               FUNCTIONS                                 //
//-------------------------------------------------------------------------//

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    NSLog(@"\n\nFinished speaking.\n\n");
    [self kairosSDKExampleMethod];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *input = [[alertView textFieldAtIndex:0] text];
    NSLog(@"\nEntered: %@ \n",input);
    
    if(buttonIndex == 0){
        @try {
            [self performSegueWithIdentifier:@"toWelcome" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
    
    if(buttonIndex == 1){
        printf("Button 1 pressed\n");
        
        /************ Image Capture Enroll *************
         * This /enroll call will display an image     *
         * capture view, and send the captured image   *
         * to the API to enroll the image.             *
         ***********************************************/
        
        if([input  isEqual: @""]){
            [self kairosSDKExampleMethod];
        }
        else{
            [KairosSDK imageCaptureEnrollWithSubjectId:input
                                           galleryName:@"MyGallery"
                                               success:^(NSDictionary *response, UIImage *image) {
                                                   
                                                   NSLog(@"\n\n--- SUCCESFULLY SAVED! ---\n");
                                                   // API Response object (JSON)
                                                   NSLog(@"\n%@", response);
                                                   
                                                   NSString *images = [response valueForKeyPath:@"images"];
                                                   
                                                   if(images == NULL){
                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                                       message:@"We were not able to process the photo correctly. Please try again!"
                                                                                                      delegate:self
                                                                                             cancelButtonTitle:@"Continue"
                                                                                             otherButtonTitles:nil];
                                                       
                                                       [alert show];
                                                   }
                                                   else{
                                                       [self performSegueWithIdentifier:@"toNewFace" sender:self];
                                                   }
                                                   
                                               } failure:^(NSDictionary *response, UIImage *image) {
                                                   
                                                   NSLog(@"\n\n--- FAILED TO SAVE! ---\n");
                                                   NSLog(@"\n%@", response);
                                                   
                                               }];
        }
    }
    else if (buttonIndex == 2){
        printf("Button 2 pressed\n");
        
        /********* Image Capture Recognize *************
         * This /recognize call will display an image  *
         * capture view, and send the captured image   *
         * to the API to match against your galleries  *
         ***********************************************/
        [KairosSDK imageCaptureRecognizeWithThreshold:@".75"
                                          galleryName:@"MyGallery"
                                              success:^(NSDictionary *response, UIImage *image) {
                                                  
                                                  NSLog(@"%@", response);
                                                  NSString * transaction = [response valueForKeyPath:@"images.transaction"];
                                                  NSString * message = [[transaction valueForKey:@"message"] componentsJoinedByString:@""];
                                                  message = [message stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                                  message = [message stringByReplacingOccurrencesOfString:@")" withString:@""];
                                                  message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                                  
                                                  NSLog(@"\n\nTHE MESSAGE WAS: %@\n", message);
                                                  // Fetch the message.
                                                  if(message != NULL) {
                                                      
                                                      if([message isEqual:@"No match found"]){
                                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                                          message:@"It looks like I could not recognize you. There was no match found.\nPlease try again."
                                                                                                         delegate:self
                                                                                                cancelButtonTitle:@"Continue"
                                                                                                otherButtonTitles:nil];
                                                          [alert show];
                                                      }
                                                      else{
                                                          // Get the names of the person.
                                                          fetchedName = [response valueForKeyPath:@"images.candidates"];
                                                          
                                                          if(fetchedName == NULL){
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                                              message:@"It looks like I could not recognize you.\nPlease try again!"
                                                                                                             delegate:self
                                                                                                    cancelButtonTitle:@"Continue"
                                                                                                    otherButtonTitles:nil];
                                                              
                                                              [alert show];
                                                          }
                                                          else{
                                                              
                                                              NSLog(@"\nFETCHED NAME(S):\n%@\n\n", fetchedName);
                                                              
                                                              [self performSegueWithIdentifier:@"toHello" sender:self];
                                                          }
                                                      }
                                                      
                                                  } else{
                                                      NSString *errors = [response valueForKeyPath:@"Errors"];
                                                      NSString *error = [[errors valueForKey:@"Message"] componentsJoinedByString:@""];
                                                      error = [error stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                                      error = [error stringByReplacingOccurrencesOfString:@")" withString:@""];
                                                      error = [error stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                                      
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                                      message:[NSString stringWithFormat:@"The error was: %@", error]
                                                                                                     delegate:self
                                                                                            cancelButtonTitle:@"Continue"
                                                                                            otherButtonTitles:nil];
                                                      
                                                      [alert show];
                                                  }
                                                  
                                                  
                                                  
                                                  
                                                  
                                              } failure:^(NSDictionary *response, UIImage *image) {
                                                  
                                                  NSLog(@"\n\n--- FAILED TO RECOGNISE! ---\n");
                                                  NSLog(@"%@", response);
                                                  
                                              }];
    }
    else if (buttonIndex == 3){
        printf("Button 3 pressed\n");
        
        [KairosSDK galleryRemoveSubject:input
                            fromGallery:@"MyGallery"
                                success:^(NSDictionary *response) {
                                    
                                    NSLog(@"\n\n--- SUCCESFULLY REMOVED FACE! ---\n");
                                    // API Response object (JSON)
                                    NSLog(@"\n%@", response);
                                    
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!"
                                                                                    message:@"Your face has been deleted!"
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"Continue"
                                                                          otherButtonTitles:nil];
                                    [alert show];
                                    
                                    
                                } failure:^(NSDictionary *response) {
                                    
                                    NSLog(@"\n\n--- FAILED TO REMOVE FACE! ---\n");
                                    NSLog(@"\n%@", response);
                                    
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                    message:@"Your face has not been deleted. Something went wrong. Try again!"
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"Continue"
                                                                          otherButtonTitles:nil];
                                    [alert show];
                                    
                                }];
        
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toHello"]){
        SecondViewController *controller = (SecondViewController *)segue.destinationViewController;
        controller.name = fetchedName;
        controller.fail = _fail;
        controller.success = _success;
    }
    if([segue.identifier isEqualToString:@"toNewFace"]){
        NewFaceViewController *controller = (NewFaceViewController *)segue.destinationViewController;
        controller.fail = _fail;
        controller.success = _success;
    }
}

- (void)kairosNotifications:(id)sender
{
    // For testing notifications
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
