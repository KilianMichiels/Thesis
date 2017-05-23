//
//  CameraViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 4/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, CALayerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) AVCaptureSession * captureSession;

@property (strong, nonatomic) IBOutlet UIView *vImagePreview;
@property (strong, nonatomic) IBOutlet UIImageView *vImage;

@property (strong, nonatomic) IBOutlet UIButton *moveUpButton;
@property (strong, nonatomic) IBOutlet UIButton *moveDownButton;
@property (strong, nonatomic) IBOutlet UIButton *takePictureButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) IBOutlet UIImageView *good;
@property (strong, nonatomic) IBOutlet UIImageView *bad;

@property UIImage *screenshot;
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
