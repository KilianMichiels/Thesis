//
//  SecondViewController.m
//  KairosSDKExampleApp
//
//  Created by Kilian Michiels on 27/03/17.
//  Copyright © 2017 Kairos. All rights reserved.
//

#import "SecondViewController.h"
#import "FeedbackViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString * new_name = [[_name valueForKey:@"subject_id"] componentsJoinedByString:@""];
    new_name = [new_name stringByReplacingOccurrencesOfString:@"(" withString:@""];
    new_name = [new_name stringByReplacingOccurrencesOfString:@")" withString:@""];
    new_name = [new_name stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    _greetingText.text = [NSString stringWithFormat: @"I recognised: %@\n\nIs this correct?", new_name];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)YesPushed:(id)sender {
    _success = _success + 1;
    
    NSLog(@"Number of successes: %d", _success);
    NSLog(@"Number of fails: %d", _fail);
    
    [self performSegueWithIdentifier:@"toFeedback" sender:self];
}

- (IBAction)NoPushed:(id)sender {
    _fail = _fail + 1;
    
    NSLog(@"Number of successes: %d", _success);
    NSLog(@"Number of fails: %d", _fail);
    
    [self performSegueWithIdentifier:@"toFeedback" sender:self];
}

- (IBAction)goBackPushed:(id)sender {
    
    [self performSegueWithIdentifier:@"toWelcome" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toFeedback"]){
        FeedbackViewController *controller = (FeedbackViewController *)segue.destinationViewController;
        controller.fail = _fail;
        controller.success = _success;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
