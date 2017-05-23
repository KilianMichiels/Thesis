//
//  FeedbackViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 30/03/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "FeedbackViewController.h"
#import "GreetingKnownViewController.h"
#import "GreetingUnknownViewController.h"
#import "TextToSpeech.h"
#import "EndViewController.h"
#import "constants.h"

NSArray *scores = nil;

BOOL q1Done;
BOOL q2Done;
BOOL q3Done;
BOOL q4Done;

@interface FeedbackViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UITextView *firstRespondField;
@end

@implementation FeedbackViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];

    [TextToSpeech talk:5];
    self.feedbackTextBox.delegate = self;
    
    [_titleLabel setAlpha:0.0f];
    [_extraLabel setAlpha:0.0f];
    
    [_feedbackTextBox setAlpha:0.0f];
    
    [_q1 setAlpha:0.0f];
    [_q2 setAlpha:0.0f];
    [_q3 setAlpha:0.0f];
    [_q4 setAlpha:0.0f];
    
    [_s1 setAlpha:0.0f];
    [_s2 setAlpha:0.0f];
    [_s3 setAlpha:0.0f];
    [_s4 setAlpha:0.0f];
    
    [_l1 setAlpha:0.0f];
    [_l2 setAlpha:0.0f];
    [_l3 setAlpha:0.0f];
    [_l4 setAlpha:0.0f];
    
    [_submitButton setAlpha:0.0f];
    [_cancelButton setAlpha:0.0f];
    
    // Fill the scoresarray:
    scores = @[@"Definetly not", @"Not really", @"Maybe", @"Yes", @"Definetly yes"];
    
    // Set the Done parameters (only if all of them were edited, the submit button becomes enabled.
    _submitButton.enabled = NO;
    q1Done = NO;
    q2Done = NO;
    q3Done = NO;
    q4Done = NO;
    
}

///////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated{
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.5f animations:^{
            
            [_titleLabel setAlpha:1.0f];
            
        } completion:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_extraLabel setAlpha:1.0f];
            
        } completion:^(BOOL finished){
            
            NSLog(@"Done animations");
            
        }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_feedbackTextBox setAlpha:1.0f];
            
            [_q1 setAlpha:1.0f];
            [_q2 setAlpha:1.0f];
            [_q3 setAlpha:1.0f];
            [_q4 setAlpha:1.0f];
            
            [_s1 setAlpha:1.0f];
            [_s2 setAlpha:1.0f];
            [_s3 setAlpha:1.0f];
            [_s4 setAlpha:1.0f];
            
            [_l1 setAlpha:1.0f];
            [_l2 setAlpha:1.0f];
            [_l3 setAlpha:1.0f];
            [_l4 setAlpha:1.0f];
            
        } completion:^(BOOL finished){
            
            NSLog(@"Done animations");
            
        }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        //fade in
        [UIView animateWithDuration:1.5f animations:^{
            
            [_submitButton setAlpha:0.4f];
            [_cancelButton setAlpha:1.0f];
            
        } completion:^(BOOL finished){
            
            NSLog(@"Done animations");
            
        }];
    });
    
    // !!! IMPORTANT: TIMER !!! //
    // If there is no activity in the next TIMER_TIME_FEEDBACK seconds, go back to the main screen.
    _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_FEEDBACK
                                              target:self
                                            selector:@selector(timerFireMethod:)
                                            userInfo:nil
                                             repeats:NO];
    
    NSLog(@"\n---------------------\n   Starting timer\n---------------------\n");
    
}

///////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)submitButtonPressed:(id)sender {
    // Prevent the user from tapping more than once.
    [_submitButton setEnabled:NO];
    [_submitButton setAlpha:0.4f];
    
    // Email Content
    NSString *messageBody = [self getIntelFromForm];
    // To address
    NSString *toRecipents = @"igenttower2@gmail.com";
    // Email Subject
    NSString *emailSubject = @"Facial Recognition Feedback - Submitted";
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = @"igenttower@gmail.com";
    smtpSession.password = @"igenttower123";
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:@"iGent Tower"
                                                  mailbox:@"igenttower@gmail.com"];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                                mailbox:toRecipents];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:emailSubject];
    [builder setTextBody:messageBody];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"Error sending email: %@", error);
            
            [TextToSpeech talkText:@"Something went wrong. Please try again later. For now, you can press the 'Don't leave feedback' button."];
            
        } else {
            NSLog(@"Successfully sent email!");
            
            [self performSegueToStart];
        }
    }];
    
}

///////////////////////////////////////////////////////////////
- (NSString*) getSession{
    // Session
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:_session];
    
    return dateString;
}

- (NSString*) getIntelFromForm{

    NSString * text = [NSString stringWithFormat:
                       @"SESSION: %@ \n"
                       "Feedback: %@ \n"
                       "Question 1: %d\n"
                       "Question 2: %d\n"
                       "Question 3: %d\n"
                       "Question 4: %d\n"
                       "\nGreetings, \n"
                       "%@\n\n\n"
                       "Total: %d\n"
                       "Succes: %d\n"
                       "Failed: %d\n", [self getSession], _feedbackTextBox.text,(int)_s1.value,(int)_s2.value,(int)_s3.value,(int)_s4.value,
                       _facialRecognitionMessage, _success+_fail, _success, _fail];
    
    return text;
}

///////////////////////////////////////////////////////////////

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // Go to the end credits and back to start for the next person
    [self performSegueToStart];
}

///////////////////////////////////////////////////////////////

- (IBAction)cancelButtonPressed:(id)sender {
    
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"SESSION: %@ \n"
                             "Total: %d\n"
                             "Succes: %d\n"
                             "Failed: %d\n",[self getSession], _success+_fail, _success, _fail];
    
    // To address
    NSString *toRecipents = @"igenttower2@gmail.com";
    
    // Email Subject
    NSString *emailSubject = @"Facial Recognition Feedback - Not Submitted";
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = @"igenttower@gmail.com";
    smtpSession.password = @"igenttower123";
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:@"iGent Tower"
                                                  mailbox:@"igenttower@gmail.com"];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                                mailbox:toRecipents];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:emailSubject];
    [builder setTextBody:messageBody];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"Error sending email: %@", error);
            
            [self performSegueToStart];
            
        } else {
            NSLog(@"Successfully sent email!");
            
            [self performSegueToStart];
        }
    }];
    
}

///////////////////////////////////////////////////////////////

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    self.feedbackTextBox.text = @"";
    
    return YES;
}

///////////////////////////////////////////////////////////////

- (IBAction)s1dragged:(id)sender {
    // Set Done parameter
    q1Done = YES;
    
    // Snap to the closest score
    int roundedValue = roundf(_s1.value / 1.0f) * 1.0f;
    
    //    NSLog(@"%d", roundedValue);
    
    [_s1 setValue:roundedValue];
    
    // Set the score label
    [_l1 setText:scores[roundedValue]];
    
    // Check if the submit button can be enabled
    [self checkDones];
}

///////////////////////////////////////////////////////////////

- (IBAction)s2dragged:(id)sender {
    // Set Done parameter
    q2Done = YES;
    
    // Snap to the closest score
    int roundedValue = roundf(_s2.value / 1.0f) * 1.0f;
    [_s2 setValue:roundedValue];
    
    // Set the score label
    [_l2 setText:scores[roundedValue]];
    
    // Check if the submit button can be enabled
    [self checkDones];
}

///////////////////////////////////////////////////////////////

- (IBAction)s3dragged:(id)sender {
    // Set Done parameter
    q3Done = YES;
    
    // Snap to the closest score
    int roundedValue = roundf(_s3.value / 1.0f) * 1.0f;
    [_s3 setValue:roundedValue];
    
    // Set the score label
    [_l3 setText:scores[roundedValue]];
    
    // Check if the submit button can be enabled
    [self checkDones];
}

///////////////////////////////////////////////////////////////

- (IBAction)s4dragged:(id)sender {
    // Set Done parameter
    q4Done = YES;
    
    // Snap to the closest score
    int roundedValue = roundf(_s4.value / 1.0f) * 1.0f;
    [_s4 setValue:roundedValue];
    
    // Set the score label
    [_l4 setText:scores[roundedValue]];
    
    // Check if the submit button can be enabled
    [self checkDones];
}

///////////////////////////////////////////////////////////////

- (void)checkDones{
    if(q1Done && q2Done && q3Done && q4Done){
        [_submitButton setAlpha:1.0f];
        _submitButton.enabled = YES;
    }
}

//-------------------------------------------------------------------------//
//                                  SEGUE                                  //
//-------------------------------------------------------------------------//

-(void)performSegueToStart{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self performSegueWithIdentifier:@"toEnd" sender:self];
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
    
    
    if([segue.identifier isEqualToString:@"toEnd"]){
        EndViewController *controller = (EndViewController *)segue.destinationViewController;
        
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
