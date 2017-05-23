//
//  SecondViewController.h
//  KairosSDKExampleApp
//
//  Created by Kilian Michiels on 27/03/17.
//  Copyright © 2017 Kairos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *greetingText;

// To pass the data around:
@property(nonatomic) NSString *name;
@property(nonatomic) int success;
@property(nonatomic) int fail;

@end
