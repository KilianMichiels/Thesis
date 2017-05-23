//
//  AttentionViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 3/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AttentionViewController : UIViewController <MainROSControlDelegate>
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


// ROS Variables:
@property MainROSDoubleControl * ROSController;

@property (strong, nonatomic) IBOutlet UIImageView *connectionColor;
@property (strong, nonatomic) IBOutlet UILabel *connectionStatus;

@end
