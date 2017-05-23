//
//  FeedbackViewController.m
//  KairosSDKExampleApp
//
//  Created by Kilian Michiels on 28/03/17.
//  Copyright © 2017 Kairos. All rights reserved.
//

#import "FeedbackViewController.h"
#import "ViewController.h"


@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toWelcome"]){
        ViewController *controller = (ViewController *)segue.destinationViewController;
        controller.fail = _fail;
        controller.success = _success;
    }
}
- (IBAction)submitPressed:(id)sender {
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"%@", _inputTextfield.text];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"igenttower2@gmail.com"];
    // Email Subject
    NSString *emailSubject = @"Facial Recognition Feedback";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailSubject];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

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
    [self performSegueWithIdentifier:@"toWelcome" sender:self];
}


- (IBAction)cancelPressed:(id)sender {
    [self performSegueWithIdentifier:@"toWelcome" sender:self];
}

@end
