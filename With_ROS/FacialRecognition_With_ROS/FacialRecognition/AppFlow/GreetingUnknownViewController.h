//
//  GreetingUnknownViewController
//  Facial Recognition
//
//  Created by Kilian Michiels on 30/03/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GreetingUnknownViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *helloTextBox;
@property (strong, nonatomic) IBOutlet UITextField *nameInputTextField;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *removeFaceButton;

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;

@end
