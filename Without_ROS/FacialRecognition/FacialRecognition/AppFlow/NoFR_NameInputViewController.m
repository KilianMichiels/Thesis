//
//  NoFR_NameInputViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 6/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "NoFR_NameInputViewController.h"
#import "ViewController.h"
#import "TextToSpeech.h"
#import "constants.h"
#import "PersonalViewController.h"

@interface NoFR_NameInputViewController ()
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *attentionTimer;
@end

@implementation NoFR_NameInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_titleLabel setAlpha:0.0f];
    [_nameInputTextField setAlpha:0.0f];
    [_nextButton setAlpha:0.0f];
    [_cancelButton setAlpha:0.0f];
    
    [_nextButton setEnabled:NO];
    
    self.nameInputTextField.delegate = self;
    
    
    if(TESTING_VARIABLES){
        [TextToSpeech initializeTalker];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    
    // Add event listener for the textfield (notify when changed)
    [_nameInputTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    
    [TextToSpeech talkText:@"Please insert your name. I will then try to find your personalized information for today."];
    
    [UIView animateWithDuration:1.5f animations:^{
        
        [_titleLabel setAlpha:1.0f];
        
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_nameInputTextField becomeFirstResponder];
            [_nameInputTextField setAlpha:1.0f];
            
        } completion:nil];
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_nextButton setAlpha:0.5f];
            
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
    
    [[_nextButton backgroundColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_nextButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_nextButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
            
        }];
    }];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (BOOL)textFieldDidChange:(UITextField *)textField{
    
    if(textField.text && textField.text.length > 0){
        _user_tag = @"No_FR_Name";
        _nextButton.enabled = YES;
        _nextButton.alpha = 1.0f;
        // SET Attention timer:
        _attentionTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                           target:self
                                                         selector:@selector(attentionButtons)
                                                         userInfo:nil
                                                          repeats:YES];
        
    }
    else
    {
        _nextButton.enabled = NO;
        _nextButton.alpha = 0.5f;
        
        [_attentionTimer invalidate];
    }
    return YES;
}

- (IBAction)nextButtonPressed:(id)sender {
    
    _username = _nameInputTextField.text;
    [self performSegueToPersonalView];
    
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

-(void)performSegueToPersonalView{
    if(SEGUES_ENABLED){
        @try {
            [self performSegueWithIdentifier:@"toPersonalView" sender:self];
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
    
    if([segue.identifier isEqualToString:@"toPersonalView"]){
        PersonalViewController *controller = (PersonalViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        controller.username = _username;
    }
}

@end
