//
//  NewFaceViewController.m
//  KairosSDKExampleApp
//
//  Created by Kilian Michiels on 28/03/17.
//  Copyright © 2017 Kairos. All rights reserved.
//

#import "NewFaceViewController.h"
#import "KairosSDK.h"
#import "ViewController.h"
#import "FaceDeletedViewController.h"

@interface NewFaceViewController ()

@end

@implementation NewFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goBackPushed:(id)sender {
    [self performSegueWithIdentifier:@"toWelcome" sender:self];
}
- (IBAction)removeButtonPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove your face?"
                                                    message:@"Please insert your name and I will delete your photo from the database."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Remove my face",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *input = [[alertView textFieldAtIndex:0] text];
    NSLog(@"\nEntered: %@ \n",input);
    
    if(buttonIndex == 0){
        printf("Button 0 pressed\n");
        [self performSegueWithIdentifier:@"toWelcome" sender:self];
        
    }
    else if (buttonIndex == 1){
        printf("Button 1 pressed\n");
        [KairosSDK galleryRemoveSubject:input
                            fromGallery:@"MyGallery"
                                success:^(NSDictionary *response) {
                                    
                                    NSLog(@"\n\n--- SUCCESFULLY REMOVED FACE! ---\n");
                                    // API Response object (JSON)
                                    NSLog(@"\n%@", response);
                                    
                                    [self performSegueWithIdentifier:@"toFaceDeleted" sender:self];
                                    
                                } failure:^(NSDictionary *response) {
                                    
                                    NSLog(@"\n\n--- FAILED TO REMOVE FACE! ---\n");
                                    NSLog(@"\n%@", response);
                                    
                                }];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toFaceDeleted"]){
        FaceDeletedViewController *controller = (FaceDeletedViewController *)segue.destinationViewController;
        controller.fail = _fail;
        controller.success = _success;
    }
    if([segue.identifier isEqualToString:@"toWelcome"]){
        ViewController *controller = (ViewController *)segue.destinationViewController;
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
