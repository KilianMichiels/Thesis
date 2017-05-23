//
//  ViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 30/03/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MotionDetectingVideoOutputAnalizer.h"

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, VideoMotionDetectorDelegate>

@property (strong, nonatomic) MotionDetectingVideoOutputAnalizer * videoMotionDetector;
@property (strong, nonatomic) AVCaptureSession * captureSession;

@property (strong, nonatomic) IBOutlet UIView *vImagePreview;
@property (strong, nonatomic) IBOutlet UIImageView *vImage;
@property (strong, nonatomic) IBOutlet UILabel *motionWarning;
@property (strong, nonatomic) IBOutlet UILabel *footnoteText;
@property (strong, nonatomic) IBOutlet UILabel *counterLabel;

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;
@property NSString * user_tag;
@end

