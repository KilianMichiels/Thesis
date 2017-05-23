//
//  WebViewFeedbackViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 3/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface WebViewFeedbackViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *extraInfo;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;
@property NSString * user_tag;
@property BOOL firsttime;

@end
