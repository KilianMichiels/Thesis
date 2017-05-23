//
//  IDViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 4/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "IDViewController.h"
#import "constants.h"
#import "ViewController.h"
#import "TextToSpeech.h"
#import "KairosSDK.h"
#import "WebViewFeedbackViewController.h"
#import "DataStorage.h"

@interface IDViewController ()
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *attentionTimer;
@end

@implementation IDViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //-------------------------------------------------------------------------//
    //                              OTHER UI SETTINGS                          //
    //-------------------------------------------------------------------------//
    
    [_titleLabel setAlpha:0.0f];
    
    [_visitorButton setAlpha:0.0f];
    [_employeeButton setAlpha:0.0f];
    
    [_cancelButton setAlpha:0.0f];
    [_removeFaceButton setAlpha:0.0f];
    
    if(TESTING_VARIABLES){
        [TextToSpeech initializeTalker];
        _firsttime = NO;
        _username = @"Kilian Michiels";
        _user_tag = @"FR";
    }
    
}

///////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated{
    
    NSLog(@"%@", [NSString stringWithFormat:@"\n---------------------------- User ----------------------------\n- USERNAME: %@\n- USER_TAG: %@\n--------------------------------------------------------------\n", _username, _user_tag]);
    
    [DataStorage showData];
    
    if(_firsttime){
        NSLog(@"This is the first time this user used this application.");
        
        [TextToSpeech talkText:@"Please choose one of the following options."];
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_titleLabel setAlpha:1.0f];
            
        } completion:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            
            [UIView animateWithDuration:1.5f animations:^{
                
                [_visitorButton setAlpha:1.0f];
                [_employeeButton setAlpha:1.0f];
                
                [_cancelButton setAlpha:1.0f];
                [_removeFaceButton setAlpha:1.0f];
                
            } completion:nil];
            
        });
    }
    else{
        
        // Get the right data about this user:
        if([DataStorage checkForUserExistance:_username]){
            NSLog(@"Username found in DB");
            
            NSDictionary * intel = [DataStorage getUserIntel:_username];
            NSString *job = [intel objectForKey: @"job"];
            
            if(job != nil){
                NSLog(@"\n---------------------- User job ----------------------\n%@\n------------------------------------------------------\n", job);
                
                if([job  isEqual: @"visitor"]){
                    if([_user_tag  isEqual: @"FR"]){
                        NSLog(@"Visitor did FR.");
                        _user_tag = @"Visitor_FR";
                    }
                    else{
                        NSLog(@"Visitor did no FR.");
                        _user_tag = @"Visitor_No_FR_Name";
                    }
                }
                else if([job  isEqual: @"employee"]){
                    if([_user_tag  isEqual: @"FR"]){
                        NSLog(@"Employee did FR.");
                        _user_tag = @"Employee_FR";
                    }
                    else{
                        NSLog(@"Employee did no FR.");
                        _user_tag = @"Employee_No_FR_Name";
                    }
                }
                else{
                    NSLog(@"user_tag == nil. (This should not happen.)");
                    _user_tag = nil;
                }
                // Go to the feedback form:
                [self performSegueToFeedback];
            }
            else{
                NSLog(@"job == nil. (This should not happen.)");
            }
        }
        else{
            NSLog(@"User does not exist in DB.");
            
            [TextToSpeech talkText:@"Please choose one of the following options."];
            
            [UIView animateWithDuration:1.5f animations:^{
                
                [_titleLabel setAlpha:1.0f];
                
            } completion:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                
                [UIView animateWithDuration:1.5f animations:^{
                    
                    [_visitorButton setAlpha:1.0f];
                    [_employeeButton setAlpha:1.0f];
                    
                    [_cancelButton setAlpha:1.0f];
                    [_removeFaceButton setAlpha:1.0f];
                    
                } completion:nil];
                
            });
            
         // SET Attention timer:
            _attentionTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                               target:self
                                                             selector:@selector(attentionButtons)
                                                             userInfo:nil
                                                              repeats:YES];
            
        }
    }
    
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
    
    [[_visitorButton backgroundColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_visitorButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_visitorButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
            
        }completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5f animations:^{
                [_employeeButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
                
            }completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5f animations:^{
                    [_employeeButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
                    
                }];
                
            }];
            
        }];
    }];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (IBAction)visitorButtonPressed:(id)sender {
    
    if([_user_tag  isEqual: @"FR"]){
        _user_tag = @"Visitor_FR";
    }
    else{
        _user_tag = @"Visitor_No_FR_Name";
    }
    
    
    [_visitorButton setEnabled:NO];
    [_employeeButton setEnabled:NO];
    
    [_visitorButton setAlpha:0.5f];
    [_employeeButton setAlpha:0.5f];
    
    // Save the user in the DB
    
    [DataStorage addUser:_username user_tag:_user_tag];
    
    // Go to feedback
    
    [self performSegueToFeedback];
    
}

///////////////////////////////////////////////////////////////

- (IBAction)employeeButtonPressed:(id)sender {
    
    if([_user_tag  isEqual: @"FR"]){
        _user_tag = @"Employee_FR";
    }
    else{
        _user_tag = @"Employee_No_FR_Name";
    }
    
    [_visitorButton setEnabled:NO];
    [_employeeButton setEnabled:NO];
    
    [_visitorButton setAlpha:0.5f];
    [_employeeButton setAlpha:0.5f];
    
    // Save the user in the DB
    
    [DataStorage addUser:_username user_tag:_user_tag];
    
    // Go to feedback
    
    [self performSegueToFeedback];
    
}

///////////////////////////////////////////////////////////////

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self performSegueToStart];
    
}

///////////////////////////////////////////////////////////////

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

///////////////////////////////////////////////////////////////

- (IBAction)removeFaceButtonPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!"
                                                    message:@"Please enter your name and it will be removed from the database."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete my face.", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
    
}

///////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1){
        NSString *input = [[alertView textFieldAtIndex:0] text];
        NSLog(@"\nEntered: %@ \n",input);
        
        NSString * MyGallery = @"MyFaces";
        
        [KairosSDK galleryRemoveSubject:input
                            fromGallery:MyGallery
                                success:^(NSDictionary *response) {
                                    
                                    NSLog(@"\n\n--- SUCCESSFULLY REMOVED FACE! ---\n");
                                    // API Response object (JSON)
                                    NSLog(@"\n%@", response);
                                    
                                    
                                    UIAlertController * alert = [UIAlertController
                                                                 alertControllerWithTitle:@"Done!"
                                                                 message:@"Your face has been deleted!"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction* continueButton = [UIAlertAction
                                                                     actionWithTitle:@"Continue"
                                                                     style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         
                                                                     }];
                                    
                                    [alert addAction:continueButton];
                                    
                                    [self presentViewController:alert animated: YES completion:nil];
                                    
                                    
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

-(void)performSegueToFeedback{
    if(SEGUES_ENABLED){
        @try {
            [self performSegueWithIdentifier:@"toFeedback" sender:self];
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
    }
    
    if([segue.identifier isEqualToString:@"toFeedback"]){
        WebViewFeedbackViewController *controller = (WebViewFeedbackViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        controller.firsttime = _firsttime;
    }
    
}

@end
