//
//  ErrorViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 6/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface ErrorViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *tryAgainButton;
@property (strong, nonatomic) IBOutlet UIButton *notTryAgainButton;
@property (strong, nonatomic) IBOutlet UITextField *notTryAgainTextField;
@property (strong, nonatomic) IBOutlet UIButton *firstTimeButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;
@property NSString * user_tag;
@property NSString * username;
@property BOOL firsttime;


// ROS Variables:
@property MainROSDoubleControl * ROSController;

@end
