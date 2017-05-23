//
//  GreetingKnownViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 1/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GreetingKnownViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *helloTextBox;
@property (strong, nonatomic) IBOutlet UIButton *correctButton;
@property (strong, nonatomic) IBOutlet UIButton *falseButton;
@property (strong, nonatomic) IBOutlet UIButton *removeFaceButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *secondCancelButton;

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;

@property (strong, nonatomic) IBOutlet UITextField *inputNameTextField;

@end
