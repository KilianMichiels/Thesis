//
//  ErrorViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 6/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "ErrorViewController.h"
#import "constants.h"
#import "IDViewController.h"
#import "CameraViewController.h"
#import "ViewController.h"
#import "TextToSpeech.h"
#import "ImproveFRViewController.h"

@interface ErrorViewController ()
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *attentionTimer;
@end

@implementation ErrorViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_titleLabel setAlpha:0.0f];
    [_tryAgainButton setAlpha:0.0f];
    [_notTryAgainButton setAlpha:0.0f];
    [_notTryAgainTextField setAlpha:0.0f];
    [_firstTimeButton setAlpha:0.0f];
    
    _notTryAgainTextField.tag = 2;
    
    // Activate delegate for Submit button
    self.notTryAgainTextField.delegate = self;
    
    if(TESTING_VARIABLES){
        [TextToSpeech initializeTalker];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated{
    
    NSString *speech;
    
    if([_facialRecognitionMessage  isEqual: @"No match found"]){
        //TODO: give option to add photo
        
        speech = @"It looks like I could not recognize you.";
    }
    else if([_facialRecognitionMessage  isEqual: @"no faces found in the image"]){
        speech = @"It looks like I could not see anyone in the photo.";
    }
    else{
        speech = @"Oh no, too bad I was not correct.";
    }
    
    
    
    [TextToSpeech talkText:[NSString stringWithFormat:@"%@ Is this your first time using this application or should you be recognised? You can also choose to just type your name and continue.", speech]];
    
    [UIView animateWithDuration:1.5f animations:^{
        
        [_titleLabel setAlpha:1.0f];
        
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_firstTimeButton setAlpha:1.0f];
            
            
        } completion:nil];
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_tryAgainButton setAlpha:1.0f];
            
            
        } completion:nil];
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_notTryAgainButton setAlpha:1.0f];
            
            [_cancelButton setAlpha:1.0f];
            
        } completion:nil];
        
    });
    
    //SET Attention timer:
    _attentionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(attentionButtons) userInfo:nil repeats:YES];
    
    // !!! IMPORTANT: TIMER !!! //
    // If there is no activity in the next TIMER_TIME_STANDARD seconds, go back to the main screen.
    if(TIMERS_ENABLED){
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_STANDARD
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
    
    [[_firstTimeButton backgroundColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_firstTimeButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_firstTimeButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
            
        }completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5f animations:^{
                [_tryAgainButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
                
            }completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5f animations:^{
                    [_tryAgainButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
                    
                }completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:0.5f animations:^{
                        [_notTryAgainButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
                        
                    }completion:^(BOOL finished) {
                        
                        [UIView animateWithDuration:0.5f animations:^{
                            [_notTryAgainButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
                            
                        }];
                        
                    }];
                }];
                
            }];
            
        }];
    }];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (IBAction)tryAgainPushed:(id)sender {
    
    [TextToSpeech talkText:@"Let's try again!"];
    _firsttime = NO;
    [_ROSController publishFirstTime:_firsttime];
    [self performSegueToID];
    
}

///////////////////////////////////////////////////////////////

- (IBAction)notTryAgainPushed:(id)sender {
    
    [_attentionTimer invalidate];
    
    [TextToSpeech talkText:@"Make sure you already used this application before. If not, please press 'This is my first time using this application'."];
    
    _firsttime = NO;
    [_ROSController publishFirstTime:_firsttime];
    
    [UIView animateWithDuration:1.5f animations:^{
        
        [_notTryAgainButton setAlpha:1.0f];
        
        [_notTryAgainTextField setAlpha:1.0f];
        [_notTryAgainTextField becomeFirstResponder];
        [_tryAgainButton setAlpha:0.4f];
        [_firstTimeButton setAlpha:0.4f];
        
    } completion:nil];
    
}

///////////////////////////////////////////////////////////////

-(IBAction)firstTimePushed:(id)sender {
    
    [_attentionTimer invalidate];
    
    [TextToSpeech talkText:@"Please insert your name."];
    
    _firsttime = YES;
    [_ROSController publishFirstTime:_firsttime];
    
    [UIView animateWithDuration:1.5f animations:^{
        
        [_firstTimeButton setAlpha:1.0f];
        
        [_notTryAgainTextField setAlpha:1.0f];
        [_notTryAgainTextField becomeFirstResponder];
        [_tryAgainButton setAlpha:0.4f];
        [_notTryAgainButton setAlpha:0.4f];
        
    } completion:nil];
    
}

///////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(![textField.text  isEqual: @""]){
        if(_firsttime == YES){
            _username = textField.text;
            [self performSegueToCamera];
        }
        else{
            _username = textField.text;
            [self performSegueToImprove];
        }
    }
    else{
        [TextToSpeech talkText:@"Please write your name in the textfield."];
    }
    
    [_ROSController publishUsername:_username];
    return YES;
}

///////////////////////////////////////////////////////////////

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self performSegueToStart];
    
}

//-------------------------------------------------------------------------//
//                                  SEGUE                                  //
//-------------------------------------------------------------------------//

-(void)performSegueToStart{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to Start..."];
            [self performSegueWithIdentifier:@"toStart" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

///////////////////////////////////////////////////////////////

-(void)performSegueToCamera{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to Camera..."];
            [self performSegueWithIdentifier:@"toCamera" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

///////////////////////////////////////////////////////////////

-(void)performSegueToID{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to ID..."];
            [self performSegueWithIdentifier:@"toID" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

///////////////////////////////////////////////////////////////

-(void)performSegueToImprove{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to Improve..."];
            [self performSegueWithIdentifier:@"toImprove" sender:self];
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
        controller.user_tag = @"";
        
        controller.ROSController = _ROSController;
    }
    
    if([segue.identifier isEqualToString:@"toCamera"]){
        [TextToSpeech stopTalking];
        CameraViewController *controller = (CameraViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        controller.username = _username;
        controller.firsttime = _firsttime;
        
        controller.ROSController = _ROSController;
    }
    
    if([segue.identifier isEqualToString:@"toID"]){
        [TextToSpeech stopTalking];
        IDViewController *controller = (IDViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        
        controller.ROSController = _ROSController;
        
    }
    
    if([segue.identifier isEqualToString:@"toImprove"]){
        [TextToSpeech stopTalking];
        ImproveFRViewController *controller = (ImproveFRViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        controller.username = _username;
        controller.firsttime = _firsttime;
        
        controller.ROSController = _ROSController;
    }
    
}

@end
