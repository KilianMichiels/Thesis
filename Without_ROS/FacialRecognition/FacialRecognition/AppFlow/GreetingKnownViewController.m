//
//  GreetingKnownViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 1/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "GreetingKnownViewController.h"
#import "FeedbackViewController.h"
#import "ViewController.h"
#import "KairosSDK.h"
#import "TextToSpeech.h"
#import "constants.h"

@interface GreetingKnownViewController ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation GreetingKnownViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Activate delegate for Enter button
    self.inputNameTextField.delegate = self;
    
    // Hide the UI to make it fade in.
    [_helloTextBox setAlpha:0.0f];
    
    [_correctButton setAlpha:0.0f];
    [_falseButton setAlpha:0.0f];
    [_removeFaceButton setAlpha:0.0f];
    [_cancelButton setAlpha:0.0f];
    
    [_inputNameTextField setAlpha:0.0f];
    
    [_secondCancelButton setAlpha:0.0f];
    [_secondCancelButton setEnabled:NO];
    
}

///////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated{
    
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
        
        //fade in
        [UIView animateWithDuration:1.5f animations:^{
            
            [_titleLabel setAlpha:1.0f];
            [_helloTextBox setAlpha:1.0f];
            [_correctButton setAlpha:1.0f];
            [_falseButton setAlpha:1.0f];
            [_removeFaceButton setAlpha:1.0f];
            [_cancelButton setAlpha:1.0f];
            
            
        } completion:nil];
    });
    
    // !!! IMPORTANT: TIMER !!! //
    // If there is no activity in the next TIMER_TIME_GREETING_KNOWN seconds, go back to the main screen.
    if(TIMERS_ENABLED){
     
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_GREETING_KNOWN
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

- (void)timerFireMethod:(NSTimer *)timer{
    NSLog(@"\n---------------------\n   Timer expired\n---------------------\n");
    [self performSegueToStart];
}

//-------------------------------------------------------------------------//
//                                GREETING                                 //
//-------------------------------------------------------------------------//


- (void)performProperGreeting{
    if([_facialRecognitionMessage isEqual: @"No match found"]){
        _helloTextBox.text = @"No match found. Please enter your name.";
    }
    else{
        _helloTextBox.text = [NSString stringWithFormat: @"Hello %@!", _facialRecognitionMessage];
        
        NSString *text = [NSString stringWithFormat: @"Hello %@! This is your name, right?", _facialRecognitionMessage];
        
        [TextToSpeech talkText:text];
    }
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (IBAction)correctButtonPressed:(id)sender {
    
    [self incrementSucces];
    
    [_correctButton setEnabled:NO];
    [_falseButton setEnabled:NO];
    
    [_correctButton setAlpha:0.0f];
    [_falseButton setAlpha:0.0f];
    
    [TextToSpeech talkText:@"I'm so happy that I'm correct. If you want, you can leave some feedback for me."];
    [self performSegueToFeedback];
    
}

///////////////////////////////////////////////////////////////

- (IBAction)notCorrectButtonPressed:(id)sender {
    
    [self incrementFail];
    
    [TextToSpeech talkText:@"Oh no. Too bad I'm wrong. Please enter your name so that I can recognise you correctly in the future."];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        //fade in textfield
        [UIView animateWithDuration:1.5f animations:^{
            
            [_inputNameTextField setAlpha:1.0f];
            
        } completion:^(BOOL finished){
            
            NSLog(@"Done animations");
            
        }];
        
        [_correctButton setEnabled:NO];
        [_falseButton setEnabled:NO];
        
        //fade out buttons
        [UIView animateWithDuration:0.5f animations:^{
            
            [_correctButton setAlpha:0.0f];
            [_falseButton setAlpha:0.0f];
            
        } completion:^(BOOL finished){
            
            NSLog(@"Done animations");
            
        }];
        
    });
    
    [self.inputNameTextField becomeFirstResponder];
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(![textField.text  isEqual: @""]){
        [TextToSpeech talkText:@"I will take your picture now to add it to my database."];
        
        [KairosSDK imageCaptureEnrollWithSubjectId:textField.text
                                       galleryName:@"MyGallery"
                                           success:^(NSDictionary *response, UIImage * image) {
                                               
                                               NSLog(@"%@", response);
                                               [TextToSpeech talkText:@"Successfully added your face."];
                                               [self performSegueToFeedback];
                                               
                                           } failure:^(NSDictionary *response, UIImage * image) {
                                               
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                               message:@"Your face has not been added. Something went wrong. Try again later!"
                                                                                              delegate:self
                                                                                     cancelButtonTitle:@"Continue"
                                                                                     otherButtonTitles:nil];
                                               [alert show];
                                               
                                               [_secondCancelButton setAlpha:1.0f];
                                               [_secondCancelButton setEnabled:YES];
                                               
                                               NSLog(@"%@", response);
                                               
                                           }];
    }
    else{
        [TextToSpeech talkText:@"Please write your name in the textfield."];
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
//                               STATISTICS                                //
//-------------------------------------------------------------------------//

- (void)incrementSucces{
    _success++;
}

///////////////////////////////////////////////////////////////

- (void)incrementFail{
    _fail++;
}

//-------------------------------------------------------------------------//
//                                  SEGUE                                  //
//-------------------------------------------------------------------------//

-(void)performSegueToFeedback{
    @try {
        [self performSegueWithIdentifier:@"toFeedback" sender:self];
    }
    @catch (NSException *exception) {
        NSLog(@"Segue not found: %@", exception);
    }
}

///////////////////////////////////////////////////////////////

-(void)performSegueToStart{
    @try {
        [self performSegueWithIdentifier:@"toStart" sender:self];
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
    
    if([segue.identifier isEqualToString:@"toFeedback"]){
        FeedbackViewController *controller = (FeedbackViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
    }
    
    if([segue.identifier isEqualToString:@"toStart"]){
        FeedbackViewController *controller = (FeedbackViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
    }
    
}

@end
