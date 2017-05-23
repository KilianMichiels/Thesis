//
//  ViewController.h
//  KairosSDKExampleApp
//
//  Created by Eric Turner on 7/27/14.
//  Copyright (c) 2014 Kairos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MotionDetectingVideoOutputAnalizer.h"

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, VideoMotionDetectorDelegate>

{@private
    AVCaptureSession * captureSession;
    MotionDetectingVideoOutputAnalizer * videoMotionDetector;
}


- (IBAction)tappedStartButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *footnoteText;
@property (strong, nonatomic) IBOutlet UIView *vImagePreview;
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) IBOutlet UIImageView *vImage;
@property (strong, nonatomic) IBOutlet UILabel *motionWarning;



@property int fail;
@property int success;
@end
