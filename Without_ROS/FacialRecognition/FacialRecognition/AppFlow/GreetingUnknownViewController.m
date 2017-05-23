//
//  GreetingViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 30/03/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "GreetingUnknownViewController.h"
#import "ViewController.h"
#import "KairosSDK.h"
#import "TextToSpeech.h"
#import "FeedbackViewController.h"
#import "constants.h"

@interface GreetingUnknownViewController ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation GreetingUnknownViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Activate delegate for Submit button
    self.nameInputTextField.delegate = self;
    
    // Hide the UI to make it fade in.
    [_helloTextBox setAlpha:0.0f];
    [_titleLabel setAlpha:0.0f];
    [_nameInputTextField setAlpha:0.0f];
    [_submitButton setAlpha:0.0f];
    [_cancelButton setAlpha:0.0f];
    [_removeFaceButton setAlpha:0.0f];
    
    _submitButton.enabled = NO;
    
}

///////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated{
    
    // Add event listener for the textfield (notify when changed)
    [_nameInputTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    
    // Start fade in of the 'Hello!' elements
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.5f animations:^{
            
            [_helloTextBox setAlpha:1.0f];
            
        } completion:nil];
    });
    
    // Start voice greeting
    [self performProperGreeting];
    
    // Start fading in the other UI elements
    double delayInSeconds_1 = 2.0;
    dispatch_time_t popTime_1 = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds_1 * NSEC_PER_SEC);
    dispatch_after(popTime_1, dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_titleLabel setAlpha:1.0f];
            [_nameInputTextField setAlpha:1.0f];
            [_submitButton setAlpha:0.4f];
            [_cancelButton setAlpha:1.0f];
            [_removeFaceButton setAlpha:1.0f];
            
            
        } completion:^(BOOL finished){
            
            NSLog(@"Done animations");
            
        }];
        
        
    });
    
    double delayInSeconds_2 = 3.0;
    dispatch_time_t popTime_2 = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds_2 * NSEC_PER_SEC);
    dispatch_after(popTime_2, dispatch_get_main_queue(), ^(void){
        
        [_nameInputTextField becomeFirstResponder];
        
    });
    
    // !!! IMPORTANT: TIMER !!! //
    // If there is no activity in the next TIMER_TIME_GREETING_UNKNOWN seconds, go back to the main screen.
    if(TIMERS_ENABLED){
     
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_GREETING_UNKNOWN
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
}

///////////////////////////////////////////////////////////////

- (void)timerFireMethod:(NSTimer *)timer{
    NSLog(@"\n---------------------\n   Timer expired\n---------------------\n");
    [self performSegueToStart];
}

//-------------------------------------------------------------------------//
//                                GREETING                                 //
//-------------------------------------------------------------------------//

- (void)performProperGreeting{
    [TextToSpeech talk:4];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (IBAction)submitButtonPressed:(id)sender {
    NSString *input = _nameInputTextField.text;
    
    if(![input isEqual: @""]){
        [TextToSpeech talkText:@"I will take your picture now to add it to my database."];
        
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
                                                   [TextToSpeech talkText:@"Successfully saved your face in the database. See you next time!"];
                                                   [self performSegueToStart];
                                               }
                                               
                                           } failure:^(NSDictionary *response, UIImage *image) {
                                               
                                               NSLog(@"\n\n--- FAILED TO SAVE! ---\n");
                                               NSLog(@"\n%@", response);
                                               
                                           }];
    }
    
}

///////////////////////////////////////////////////////////////

- (IBAction)cancelButtonPressed:(id)sender {
    [self performSegueToStart];
}

///////////////////////////////////////////////////////////////

- (IBAction)removeFaceButtonPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!"
                                                    message:@"Please enter your name and it will be removed from the database."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Continue",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
    
}

///////////////////////////////////////////////////////////////

- (BOOL)textFieldDidChange:(UITextField *)textField{
    
    if (_nameInputTextField.text && _nameInputTextField.text.length > 0){
        _submitButton.enabled = YES;
        _submitButton.alpha = 1.0f;
    }
    else
    {
        _submitButton.enabled = NO;
        _submitButton.alpha = 0.4f;
    }
    
    return YES;
}


//-------------------------------------------------------------------------//
//                                ALERTVIEW                                //
//-------------------------------------------------------------------------//

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1){
        NSString *input = [[alertView textFieldAtIndex:0] text];
        NSLog(@"\nEntered: %@ \n",input);
        
        [KairosSDK galleryRemoveSubject:input
                            fromGallery:@"MyGallery"
                                success:^(NSDictionary *response) {
                                    
                                    NSLog(@"\n%@", response);
                                    
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!"
                                                                                    message:@"Your face has been deleted!"
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"Continue"
                                                                          otherButtonTitles:nil];
                                    [alert show];
                                    
                                    
                                } failure:^(NSDictionary *response) {
                                    
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
    @try {
        [self performSegueWithIdentifier:@"toStart" sender:self];
    }
    @catch (NSException *exception) {
        NSLog(@"Segue not found: %@", exception);
    }
}

///////////////////////////////////////////////////////////////

-(void)performSegueToFeedback{
    @try {
        [self performSegueWithIdentifier:@"toFeedback" sender:self];
    }
    @catch (NSException *exception) {
        NSLog(@"Segue not found: %@", exception);
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
    if([segue.identifier isEqualToString:@"toFeedback"]){
        FeedbackViewController *controller = (FeedbackViewController *)segue.destinationViewController;
        
        // Send the correct name forward to the FeedbackViewController
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
    }
}


@end
