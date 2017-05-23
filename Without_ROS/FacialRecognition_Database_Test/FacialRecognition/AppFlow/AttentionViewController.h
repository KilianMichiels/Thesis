//
//  AttentionViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 3/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextToSpeech.h"
#import "constants.h"
#import "ViewController.h"
#import "ChoiceViewController.h"
#import "NameInputViewController.h"
#import "IDViewController.h"

@interface AttentionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *Introduction;
@property (strong, nonatomic) IBOutlet UILabel *explanation;
@property (strong, nonatomic) IBOutlet UIButton *notNowButton;
@property (strong, nonatomic) IBOutlet UIButton *tryItOutButton;
@property (strong, nonatomic) IBOutlet UILabel *tapToSkipLabel;

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;
@property NSString * user_tag;

@end
