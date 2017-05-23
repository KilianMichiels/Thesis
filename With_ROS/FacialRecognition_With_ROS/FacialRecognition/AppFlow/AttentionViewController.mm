//
//  AttentionViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 3/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "AttentionViewController.h"
#import "TextToSpeech.h"
#import "constants.h"
#import "ViewController.h"
#import "ChoiceViewController.h"
#import "NameInputViewController.h"
#import "IDViewController.h"

@interface AttentionViewController ()
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *attentionTimer;
@end

@implementation AttentionViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_Introduction setAlpha:0.0f];
    
    [_notNowButton setEnabled:NO];
    [_tryItOutButton setEnabled:NO];
    [_notNowButton setAlpha:0.0f];
    [_tryItOutButton setAlpha:0.0f];
    
    [_tapToSkipLabel setAlpha:0.0f];
    
    if(TESTING_VARIABLES){
        [TextToSpeech initializeTalker];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    // Give the choice to the user.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:3.5f animations:^{
            
            [_tapToSkipLabel setAlpha:1.0f];
            
        } completion:nil];
        
    });
    
    NSString * string_0 = @"Hello there. Let me introduce myself.";
    NSString * string_1 = @"My name is Double. I was created by Double Robotics and I am here to make your life much better!";
    NSString * string_2 = @"I work with a student, Kilian Michiels, to help him graduate this year.";
    NSString * string_3 = @"My goal is to recognize you and try to help you as much as possible.";
    NSString * string_4 = @"Hopefully you want to use me. You can give me some tips on how I could help you or leave other feedback.";
    NSString * string_5 = @"Kilian and I thank you for your cooperation!";
    NSString * string_6 = @"Just choose one of the options and you will see what I mean!";
    NSString * string_7 = @"Enjoy!";
    
    NSString * all_sentences = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@", string_0, string_1,string_2,string_3,string_4,string_5,string_6,string_7];
    
    // Start fade in of the 'Hello!' elements
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.5f animations:^{
            
            [_Introduction setAlpha:1.0f];
            
        } completion:nil];
    });
    
    // Read out loud.
    [TextToSpeech talkText:all_sentences];
    
    // Initiate self introduction
    [self InformWithDelay:string_0 time:0.0];
    [self InformWithDelay:string_1 time:3.0];
    [self InformWithDelay:string_2 time:8.5];
    [self InformWithDelay:string_3 time:13.0];
    [self InformWithDelay:string_4 time:17.0];
    [self InformWithDelay:string_5 time:23.0];
    [self InformWithDelay:string_6 time:24.5];
    [self InformWithDelay:string_7 time:28.0];
    
    // Give the choice to the user.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 24.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [_notNowButton setEnabled:YES];
        [_tryItOutButton setEnabled:YES];
        [_tapToSkipLabel setAlpha:0.0f];
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_tryItOutButton setAlpha:1.0f];
            [_notNowButton setAlpha:1.0f];
            
        } completion:nil];
        
    });
    
    //SET Attention timer:
    _attentionTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(attentionButtons) userInfo:nil repeats:YES];
    
    // !!! IMPORTANT: TIMER !!! //
    // If there is no activity in the next TIMER_TIME_GREETING_UNKNOWN seconds, go back to the main screen.
    if(TIMERS_ENABLED){
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_ATTENTION
                                                  target:self
                                                selector:@selector(timerFireMethod:)
                                                userInfo:nil
                                                 repeats:NO];
        
        NSLog(@"\n---------------------\n   Starting timer\n---------------------\n");
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"\n-------------------------------------------------------------\n-------------------------------------------------------------\n-------------------------------------------------------------\n                  STARTING THE PROGRAM                  \n-------------------------------------------------------------\n-------------------------------------------------------------\n-------------------------------------------------------------\n");
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
    
    [[_tryItOutButton backgroundColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_tryItOutButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_tryItOutButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
            
        }completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5f animations:^{
                    [_notNowButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
                    
            }completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5f animations:^{
                    [_notNowButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
                    
                }];
                
            }];
            
        }];
    }];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (void)InformWithDelay:(NSString *)text time:(double)time{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        // Change Text.
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.75;
        [_explanation.layer addAnimation:animation forKey:@"kCATransitionFade"];
        
        _explanation.text = text;
    });
    
}

- (IBAction)skipTapped:(id)sender {
    
    [TextToSpeech stopTalking];
    [_tryItOutButton setAlpha:1.0f];
    [_notNowButton setAlpha:1.0f];
    [_tryItOutButton setEnabled:YES];
    [_notNowButton setEnabled:YES];
    
}

///////////////////////////////////////////////////////////////

- (IBAction)tryItOutWithButtonPressed:(id)sender {
    _user_tag = @"FR";
    [self performSegueToID];
    
}

///////////////////////////////////////////////////////////////

- (IBAction)tryItOutWithoutPressed:(id)sender {
    _user_tag = @"No_FR";
    [self performSegueToNameInput];
    
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

-(void) performSegueToNameInput{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to NameInput..."];
            [self performSegueWithIdentifier:@"toNameInput" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

-(void) performSegueToChoice{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to Choice..."];
            [self performSegueWithIdentifier:@"toChoice" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

-(void) performSegueToID{
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    // !!! IMPORTANT: TIMER !!! //
    // Stop the timer before continuing to the next view
    [self resetTimer];
    
    if([segue.identifier isEqualToString:@"toStart"]){
        ViewController *controller = (ViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        controller.ROSController = _ROSController;
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        
    controller.ROSController = _ROSController;
    }
    
    if([segue.identifier isEqualToString:@"toNameInput"]){
        NameInputViewController *controller = (NameInputViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        controller.ROSController = _ROSController;
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        
        controller.ROSController = _ROSController;
    }
    
    
    // Deprecated
    if([segue.identifier isEqualToString:@"toChoice"]){
        ChoiceViewController *controller = (ChoiceViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        controller.ROSController = _ROSController;
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        
        controller.ROSController = _ROSController;
        
    
    }
    
    if([segue.identifier isEqualToString:@"toID"]){
        IDViewController *controller = (IDViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        controller.ROSController = _ROSController;
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
    
    controller.ROSController = _ROSController;
    }
    
}


@end
