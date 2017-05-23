//
//  FacialRecognitionViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 7/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacialRecognitionViewController : UIViewController

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;
@property NSString * user_tag;
@property NSString * username;

@end
