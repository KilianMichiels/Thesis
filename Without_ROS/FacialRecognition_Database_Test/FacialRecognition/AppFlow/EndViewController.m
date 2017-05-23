//
//  EndViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 1/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "EndViewController.h"
#import "ViewController.h"
#import "TextToSpeech.h"
#import "constants.h"

@interface EndViewController ()

@end

@implementation EndViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(TESTING_VARIABLES){
        [TextToSpeech initializeTalker];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    
    [TextToSpeech talkText:@"Thank you very much for your cooperation. Recognise you later!"];
    [self showCredits];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showCredits{
    // Animate the end credits.
    double delayInSeconds_1 = 2.0;
    dispatch_time_t popTime_1 = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds_1 * NSEC_PER_SEC);
    dispatch_after(popTime_1, dispatch_get_main_queue(), ^(void){
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 1.5;
        [_creditsLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
        
        // This will fade:
        _creditsLabel.text = @"This application was\ncreated by\nKilian Michiels.";
    });
    
    double delayInSeconds_2 = 4.0;
    dispatch_time_t popTime_2 = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds_2 * NSEC_PER_SEC);
    dispatch_after(popTime_2, dispatch_get_main_queue(), ^(void){
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 1.5;
        [_creditsLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
        
        // This will fade:
        _creditsLabel.text = @"Special thanks to\nFemke Ongenae\n&\nJelle Nelis.";
    });
    
    // Return to the main screen after 6 seconds.
    double delayInSeconds_3 = 6.0;
    dispatch_time_t popTime_3 = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds_3 * NSEC_PER_SEC);
    dispatch_after(popTime_3, dispatch_get_main_queue(), ^(void){
        [self performSegueToStart];
    });
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
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
}

@end
