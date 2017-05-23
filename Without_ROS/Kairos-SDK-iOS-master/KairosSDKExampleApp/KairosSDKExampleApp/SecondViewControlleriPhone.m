//
//  SecondViewController.m
//  KairosSDKExampleApp
//
//  Created by Kilian Michiels on 27/03/17.
//  Copyright © 2017 Kairos. All rights reserved.
//

#import "SecondViewControlleriPhone.h"

@interface SecondViewControlleriPhone ()

@end

@implementation SecondViewControlleriPhone

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _greetingText.text = [NSString stringWithFormat: @"%@", _name];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBackPushed:(id)sender {
    
    [self.navigationController performSegueWithIdentifier:@"toWelcome" sender:self];
    
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
