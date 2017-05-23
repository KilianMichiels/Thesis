//
//  FacialRecognitionViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 7/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "FacialRecognitionViewController.h"
#import "IDViewController.h"
#import "constants.h"
#import "ViewController.h"
#import "ErrorViewController.h"
#import "TextToSpeech.h"
#import "KairosSDK.h"
#import "CorrectViewController.h"

UIImage * photoTakenByKairos_Image;

@interface FacialRecognitionViewController ()
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation FacialRecognitionViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [KairosSDK setMinimumSessionFrames: 80];
    [KairosSDK setProgressViewTransitionType:KairosTransitionTypeSpinner];
    
    [KairosSDK setShowImageCaptureViewTransitionType:KairosTransitionTypeAlphaFade];
    [KairosSDK setHideImageCaptureViewTransitionType:KairosTransitionTypeAlphaFade];
    
    [KairosSDK setErrorMessageMoveCloser:@"Please move closer to the camera."];
    [KairosSDK setErrorMessageFaceScreen:@"Please make sure your face is visible."];
    [KairosSDK setErrorMessageHoldStill:@"Please hold the iPad still."];
    
    //-------------------------------------------------------------------------//
    //                              OTHER UI SETTINGS                          //
    //-------------------------------------------------------------------------//
    
    [TextToSpeech continueTalking];
    
    if(TESTING_VARIABLES){
        
        [TextToSpeech initializeTalker];
        
    }
    
}

///////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated{
    
    [self recognizePerson];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_FACIAL_RECOGNITION + 1 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    
}

//-------------------------------------------------------------------------//
//                                  TIMER                                  //
//-------------------------------------------------------------------------//

- (void)resetTimer{
    NSLog(@"\n---------------------\n   Canceling timer\n---------------------\n");
    [_timer invalidate];
    _timer = nil;
}

///////////////////////////////////////////////////////////////

- (void)timerFireMethod:(NSTimer *)timer{
    NSLog(@"\n---------------------\n   Timer expired\n---------------------\n");
    [self performSegueToStart];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"\n--------------------\nDone Pressed\n--------------------\n");
    if(![textField.text  isEqual: @""]){
        [TextToSpeech talkText:[NSString stringWithFormat:@"Hello %@, I will fetch your information now.", textField.text]];
    }
    else{
        [TextToSpeech talkText:@"Please write your name in the textfield."];
    }
    return YES;
}

//-------------------------------------------------------------------------//
//                            FACIAL RECOGNITION                           //
//-------------------------------------------------------------------------//

// Try to recognise the person in front of the camera.
- (void)recognizePerson
{
    
    [TextToSpeech talkText:@"Please look straight into the camera. You will see a green box around your head if everything goes well."];
    
    NSString * MyGallery = @"MyFaces";
    
    [KairosSDK imageCaptureRecognizeWithThreshold:@".75"
                                      galleryName:MyGallery
                                          success:^(NSDictionary *response, UIImage *image) {
                                              
                                              NSLog(@"\n------------------------\nResponse: \n%@\n------------------------\n", response);
                                              
                                              // Fetch the message.
                                              NSString * transaction = [response valueForKeyPath:@"images.transaction"];
                                              
                                              // If the message contained information then check this info.
                                              if(transaction != NULL) {
                                                  
                                                  NSLog(@"\n------------------------\nThe transaction was: %@\n------------------------\n", transaction);
                                                  NSString *message = [[transaction valueForKey:@"message"] componentsJoinedByString:@""];
                                                  
                                                  if([message isEqual:@"No match found"]){
                                                      
                                                      _facialRecognitionMessage = message;
                                                      [self performSegueToError];
                                                      
                                                  }
                                                  else{
                                                      // Get the names of the person.
                                                      NSString *temp = [[transaction valueForKey:@"subject_id"] componentsJoinedByString:@""];;
                                                      temp = [temp stringByReplacingOccurrencesOfString:@")" withString:@""];
                                                      temp = [temp stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                                      temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                                      temp = [temp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                                      temp = [temp stringByReplacingOccurrencesOfString:@"  " withString:@""];
                                                      _facialRecognitionMessage = temp;
                                                      
                                                      NSLog(@"\n_facialRecognitionMessage: %@\n",_facialRecognitionMessage);
                                                      
                                                      if(_facialRecognitionMessage == NULL){
                                                          
                                                          [TextToSpeech talkText:[NSString stringWithFormat:@"I did not receive any faces from the database."]];
                                                          [self performSegueToError];
                                                      }
                                                      else{
                                                          NSLog(@"\n------------------------FETCHED NAME(S):\n%@\n------------------------\n", _facialRecognitionMessage);
                                                          [TextToSpeech talkText:[NSString stringWithFormat:@"Hello %@! This is your name, right?", _facialRecognitionMessage]];
                                                          
                                                          _username = _facialRecognitionMessage;
                                                          [self performSegueToCorrect];
                                                          
                                                      }
                                                  }
                                              }
                                              // If there were only errors, check the errors.
                                              else{
                                                  NSString *errors = [response valueForKeyPath:@"Errors"];
                                                  NSString *error = [[errors valueForKey:@"Message"] componentsJoinedByString:@""];
                                                  error = [error stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                                  error = [error stringByReplacingOccurrencesOfString:@")" withString:@""];
                                                  error = [error stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                                  NSLog(@"%@", error);
                                                  
                                                  //                                                  [TextToSpeech talkText:error];
                                                  _facialRecognitionMessage = error;
                                                  
                                                  [self performSegueToError];
                                                  
                                                  
                                              }
                                          } failure:^(NSDictionary *response, UIImage *image) {
                                              
                                              NSLog(@"%@", response);
                                              
                                          }];
}

///////////////////////////////////////////////////////////////

// Notifications from the SDK kit, used to notify the user.
- (void)kairosNotificationsPhotoTaken:(id)sender
{
    NSLog(@"KairosDidCaptureImageNotification");
    [TextToSpeech talk:1];
}

///////////////////////////////////////////////////////////////

- (void)kairosNotificationsHideImage:(id)sender
{
    NSLog(@"KairosDidHideImageCaptureViewNotification");
    [TextToSpeech talk:2];
    
}

///////////////////////////////////////////////////////////////

- (void)kairosNotificationsShowImage:(id)sender
{
    NSLog(@"KairosDidShowImageCaptureViewNotification");
    [TextToSpeech talk:3];
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

///////////////////////////////////////////////////////////////

-(void)performSegueToError{
    if(SEGUES_ENABLED){
        @try {
            [self performSegueWithIdentifier:@"toError" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

///////////////////////////////////////////////////////////////

-(void)performSegueToCorrect{
    if(SEGUES_ENABLED){
        @try {
            [self performSegueWithIdentifier:@"toCorrect" sender:self];
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
        NSLog(@"Going to start.");
        ViewController *controller = (ViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = @"";
    }
    
    if([segue.identifier isEqualToString:@"toError"]){
        NSLog(@"Going to error.");
        ErrorViewController *controller = (ErrorViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        controller.username = @"";
    }
    
    if([segue.identifier isEqualToString:@"toCorrect"]){
        NSLog(@"Going to correct.");
        CorrectViewController *controller = (CorrectViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        controller.username = _username;
        
        controller.photoTakenByKairos_Image = photoTakenByKairos_Image;
        
    }
    
}

@end
