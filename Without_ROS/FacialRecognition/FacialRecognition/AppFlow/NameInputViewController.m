//
//  NameInputViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 6/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "NameInputViewController.h"
#import "TextToSpeech.h"
#import "constants.h"
#import "ViewController.h"
#import "NoFR_NameInputViewController.h"
#import "WebViewFeedbackViewController.h"

@interface NameInputViewController ()
@property (strong, nonatomic) NSTimer *timer;
@property (strong,nonatomic) NSTimer *attentionTimer;
@end

@implementation NameInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(TESTING_VARIABLES){
        [TextToSpeech initializeTalker];
    }
    [_titleLabel setAlpha:0.0f];
    [_noButton setAlpha:0.0f];
    [_yesButton setAlpha:0.0f];
    [_cancelButton setAlpha:0.0f];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [TextToSpeech talkText:@"Would you like to insert your name and see your personalised view for today?"];
    
    [UIView animateWithDuration:1.0f animations:^{
        
        [_titleLabel setAlpha:1.0f];
        
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.0f animations:^{
            
            [_yesButton setAlpha:1.0f];
            [_noButton setAlpha:1.0f];
            
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
    
    [[_yesButton backgroundColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_yesButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_yesButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
            
        }completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5f animations:^{
                [_noButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
                
            }completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5f animations:^{
                    [_noButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
                    
                }];
                
            }];
            
        }];
    }];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (IBAction)yesButtonPressed:(id)sender {
    
    [self performSegueToNameInput];
    
}

- (IBAction)noButtonPressed:(id)sender {
    
    [self performSegueToFeedback];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self performSegueToStart];
    
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

-(void)performSegueToNameInput{
    if(SEGUES_ENABLED){
        @try {
            [self performSegueWithIdentifier:@"toNameInput" sender:self];
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
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = @"No_FR_No_Name";
    }
    
    if([segue.identifier isEqualToString:@"toNoFRNameInput"]){
        NoFR_NameInputViewController *controller = (NoFR_NameInputViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = @"";
    }
    
}

@end
