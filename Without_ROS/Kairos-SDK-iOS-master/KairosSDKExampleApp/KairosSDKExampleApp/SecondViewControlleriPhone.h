//
//  SecondViewController.h
//  KairosSDKExampleApp
//
//  Created by Kilian Michiels on 27/03/17.
//  Copyright © 2017 Kairos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewControlleriPhone : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *goBack;
@property (strong, nonatomic) IBOutlet UILabel *greetingText;

@property(nonatomic) NSString *name;

@end
