//
//  ApresRecognitionViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 6/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface ApresRecognitionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property UIImage *screenshot;
@property (strong, nonatomic) IBOutlet UIImageView *vImagePreview;
@property (strong, nonatomic) IBOutlet UIView *vImage;
@property (strong, nonatomic) IBOutlet UIButton *yesButton;
@property (strong, nonatomic) IBOutlet UIButton *noButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *yesWithPhotosButton;

@property BOOL alreadyBeenHere;

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
