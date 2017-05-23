//
//  FeedbackViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 30/03/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MailCore/MailCore.h>

@interface FeedbackViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *extraLabel;
@property (strong, nonatomic) IBOutlet UITextView *feedbackTextBox;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

// Question variables
@property (strong, nonatomic) IBOutlet UILabel *q1;
@property (strong, nonatomic) IBOutlet UISlider *s1;
@property (strong, nonatomic) IBOutlet UILabel *l1;

@property (strong, nonatomic) IBOutlet UILabel *q2;
@property (strong, nonatomic) IBOutlet UISlider *s2;
@property (strong, nonatomic) IBOutlet UILabel *l2;

@property (strong, nonatomic) IBOutlet UILabel *q3;
@property (strong, nonatomic) IBOutlet UISlider *s3;
@property (strong, nonatomic) IBOutlet UILabel *l3;

@property (strong, nonatomic) IBOutlet UILabel *q4;
@property (strong, nonatomic) IBOutlet UISlider *s4;
@property (strong, nonatomic) IBOutlet UILabel *l4;

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;

@end
