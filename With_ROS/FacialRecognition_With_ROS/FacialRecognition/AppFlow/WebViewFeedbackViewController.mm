//
//  WebViewFeedbackViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 3/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "WebViewFeedbackViewController.h"
#import "EndViewController.h"
#import "constants.h"
#import "TextToSpeech.h"

@interface WebViewFeedbackViewController ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation WebViewFeedbackViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(TESTING_VARIABLES){
        [TextToSpeech initializeTalker];
    }
    
    [TextToSpeech continueTalking];
    [TextToSpeech talk:5];
    
    [_titleLabel setAlpha:0.0f];
    [_extraInfo setAlpha:0.0f];
    
    [_webView setAlpha:0.0f];
    
    [_submitButton setAlpha:0.0f];
    
    self.webView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    
    NSString *urlString = @"";
    
    if([_user_tag  isEqual: @"Visitor_FR"] && _firsttime){
        urlString = Visitor_FR_first_time_form;
    }
    else if([_user_tag  isEqual: @"Visitor_FR"] && !_firsttime){
        urlString = Visitor_FR_not_first_time_form;
    }
    else if([_user_tag  isEqual: @"Employee_FR"] && _firsttime){
        urlString = Employee_FR_first_time_form;
    }
    else if([_user_tag  isEqual: @"Employee_FR"] && !_firsttime){
        urlString = Employee_FR_not_first_time_form;
    }
    else if([_user_tag  isEqual: @"Employee_No_FR_Name"]){
        urlString = Employee_No_FR_form;
    }
    else if([_user_tag  isEqual: @"Visitor_No_FR_Name"]){
        urlString = Visitor_No_FR_form;
    }
    else if([_user_tag  isEqual: @"No_FR_No_Name"]){
        urlString = No_FR_No_Name_form;
    }
    else{
        urlString = @"https://www.google.com";
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.5f animations:^{
            
            [_titleLabel setAlpha:1.0f];
            
        } completion:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_extraInfo setAlpha:1.0f];
            [_webView setAlpha:1.0f];
            
            //            [_submitButton setAlpha:1.0f];
            
        } completion:^(BOOL finished){
            
            NSLog(@"Done animations");
            
        }];
    });
    
    
    // !!! IMPORTANT: TIMER !!! //
    // If there is no activity in the next TIMER_TIME_FEEDBACK seconds, go back to the main screen.
    if(TIMERS_ENABLED){
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_FEEDBACK
                                                  target:self
                                                selector:@selector(timerFireMethod:)
                                                userInfo:nil
                                                 repeats:NO];
        
        NSLog(@"\n---------------------\n   Starting timer\n---------------------\n");
        
    }
    
    if(TESTING_VARIABLES){
        [self performSegueToEnd];
    }
    
}

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
    // [TextToSpeech talkText:@"Timeout, returning to home."];
    NSLog(@"\n---------------------\n   Timer expired\n---------------------\n");
    [self performSegueToEnd];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"----------------------\nURL:\n%@\n----------------------", [request URL]);
    
    if([[request URL].absoluteString isEqual: Employee_FR_not_first_time_response] || [[request URL].absoluteString isEqual: Employee_No_FR_response] || [[request URL].absoluteString isEqual: Visitor_FR_not_first_time_response] || [[request URL].absoluteString isEqual: Visitor_No_FR_response] || [[request URL].absoluteString isEqual: No_FR_No_Name_response] || [[request URL].absoluteString isEqual: Employee_FR_first_time_response] || [[request URL].absoluteString isEqual: Visitor_FR_first_time_response]){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            [self performSegueToEnd];
            
        });
    }
    
    return YES;
}


//-------------------------------------------------------------------------//
//                                  SEGUE                                  //
//-------------------------------------------------------------------------//

-(void)performSegueToEnd{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to End..."];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self performSegueWithIdentifier:@"toEnd" sender:self];
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
    
    if([segue.identifier isEqualToString:@"toEnd"]){
        EndViewController *controller = (EndViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        
        controller.ROSController = _ROSController;
    }
}


@end
