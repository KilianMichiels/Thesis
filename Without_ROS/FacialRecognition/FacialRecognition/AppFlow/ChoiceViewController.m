//
//  ChoiceViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 6/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "ChoiceViewController.h"
#import "constants.h"
#import "ViewController.h"
#import "IDViewController.h"
#import "TextToSpeech.h"
#import "NameInputViewController.h"

@interface ChoiceViewController ()
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation ChoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_titleLabel setAlpha:0.0f];
    
    [_YesButton setAlpha:0.0f];
    
    [_NoButton setAlpha:0.0f];
    
    [_cancelButton setAlpha:0.0f];
    
    if(TESTING_VARIABLES){
        [TextToSpeech initializeTalker];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [TextToSpeech talkText:@"Would you like to perform the facial recognition?"];
    
    [UIView animateWithDuration:1.5f animations:^{
        
        [_titleLabel setAlpha:1.0f];
        
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_YesButton setAlpha:1.0f];
            [_NoButton setAlpha:1.0f];
            
            [_cancelButton setAlpha:1.0f];
            
        } completion:nil];
        
    });
    
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
}

///////////////////////////////////////////////////////////////

- (void)timerFireMethod:(NSTimer *)timer{
    // [TextToSpeech talkText:@"Timeout, returning to home."];
    NSLog(@"\n---------------------\n   Timer expired\n---------------------\n");
    [self performSegueToStart];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (IBAction)yesButtonPressed:(id)sender {
    
    _user_tag = @"FR";
    [self performSegueToID];
    
}

- (IBAction)noButtonPressed:(id)sender {
    
    _user_tag = @"No_FR";
    [self performSegueToNameInput];
    
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

///////////////////////////////////////////////////////////////

-(void) performSegueToID{
    if(SEGUES_ENABLED){
        @try {
            [self performSegueWithIdentifier:@"toID" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

///////////////////////////////////////////////////////////////

-(void) performSegueToNameInput{
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
    
    if([segue.identifier isEqualToString:@"toNameInput"]){
        NameInputViewController *controller = (NameInputViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
    }
    
    if([segue.identifier isEqualToString:@"toID"]){
        IDViewController *controller = (IDViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
    }
}

@end
