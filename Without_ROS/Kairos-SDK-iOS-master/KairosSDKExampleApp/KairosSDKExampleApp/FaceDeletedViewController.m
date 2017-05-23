//
//  FaceDeletedViewController.m
//  KairosSDKExampleApp
//
//  Created by Kilian Michiels on 28/03/17.
//  Copyright © 2017 Kairos. All rights reserved.
//

#import "FaceDeletedViewController.h"
#import "ViewController.h"

@interface FaceDeletedViewController ()

@end

@implementation FaceDeletedViewController

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
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
