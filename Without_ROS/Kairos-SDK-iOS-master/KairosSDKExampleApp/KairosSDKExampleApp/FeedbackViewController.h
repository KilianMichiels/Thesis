//
//  FeedbackViewController.h
//  KairosSDKExampleApp
//
//  Created by Kilian Michiels on 28/03/17.
//  Copyright © 2017 Kairos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FeedbackViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *feedbackTextBox;
@property (strong, nonatomic) IBOutlet UITextField *inputTextfield;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property int fail;
@property int success;
@end
