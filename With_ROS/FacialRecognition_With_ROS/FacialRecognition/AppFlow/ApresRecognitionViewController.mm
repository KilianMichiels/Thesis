//
//  ApresRecognitionViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 6/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "ApresRecognitionViewController.h"
#import "KairosSDK.h"
#import "constants.h"
#import "ViewController.h"
#import "PersonalViewController.h"
#import "CameraViewController.h"
#import "UIImage-Extensions.h"
#import "TextToSpeech.h"

@interface ApresRecognitionViewController ()
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *attentionTimer;
@property BOOL morePhotos;
@end

@implementation ApresRecognitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [TextToSpeech continueTalking];
    
    [_yesButton setEnabled:YES];
    [_noButton setEnabled:YES];
    [_cancelButton setEnabled:YES];
    [_yesWithPhotosButton setEnabled:YES];
    
    [_titleLabel setAlpha:0.0f];
    [_vImagePreview setAlpha:0.0f];
    [_yesButton setAlpha:0.0f];
    [_yesWithPhotosButton setAlpha:0.0f];
    [_noButton setAlpha:0.0f];
    [_cancelButton setAlpha:0.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    
    [TextToSpeech talkText:@"Would you like to use this photo for your facial recognition?"];
    
    [UIView animateWithDuration:2.0f animations:^{
        
        [_titleLabel setAlpha:1.0f];
        [_vImagePreview setAlpha:1.0f];
        
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.0f animations:^{
            
            [_yesButton setAlpha:1.0f];
            [_yesWithPhotosButton setAlpha:1.0f];
            [_noButton setAlpha:1.0f];
            [_cancelButton setAlpha:1.0f];
            
        } completion:nil];
        
    });
    
    _screenshot = [UIImage imageWithCGImage:_screenshot.CGImage
                                      scale:_screenshot.scale
                                orientation:UIImageOrientationRightMirrored];
    
    _screenshot = [_screenshot imageByScalingProportionallyToSize:_vImagePreview.frame.size];
    
    [_vImagePreview setImage:_screenshot];
    
    //SET Attention timer:
    _attentionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(attentionButtons) userInfo:nil repeats:YES];
    
    // !!! IMPORTANT: TIMER !!! //
    // If there is no activity in the next TIMER_TIME_STANDARD seconds, go back to the main screen.
    if(TIMERS_ENABLED){
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_STANDARD
                                                  target:self
                                                selector:@selector(timerFireMethod:)
                                                userInfo:nil
                                                 repeats:NO];
        
        NSLog(@"\n---------------------\n   Starting timer\n---------------------\n");
    }
}

//-------------------------------------------------------------------------//
//                                  TIMER                                  //
//-------------------------------------------------------------------------//

- (void)resetTimer{
    NSLog(@"\n---------------------\n   Canceling timer\n---------------------\n");
    [_timer invalidate];
    _timer = nil;
    
    [_attentionTimer invalidate];
    _attentionTimer = nil;
}

///////////////////////////////////////////////////////////////

- (void)timerFireMethod:(NSTimer *)timer{
    // [TextToSpeech talkText:@"Timeout, returning to home."];
    NSLog(@"\n---------------------\n   Timer expired\n---------------------\n");
    [self performSegueToStart];
}

///////////////////////////////////////////////////////////////

- (void)attentionButtons{
    
    CGFloat h, s, b, a;
    
    [[_yesButton backgroundColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_yesButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_yesButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
            
        }completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5f animations:^{
                [_noButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
                
            }completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5f animations:^{
                    [_noButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
                    
                }];
                
            }];
            
        }];
    }];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (IBAction)yesButtonPressed:(id)sender {
    [_yesButton setEnabled:NO];
    [_yesWithPhotosButton setEnabled:NO];
    [_noButton setEnabled:NO];
    [_cancelButton setEnabled:NO];
    
    [_yesWithPhotosButton setAlpha:0.5f];
    [_yesButton setAlpha:0.5f];
    [_noButton setAlpha:0.5f];
    [_cancelButton setAlpha:0.5f];
    
    NSData * sendImage = UIImageJPEGRepresentation(_screenshot, 1.0);
    
    NSString * base64 = [sendImage base64EncodedStringWithOptions:kNilOptions];
    
    [_ROSController publishImage:base64];
    
    _morePhotos = NO;
    
    [self enrollPerson];
}

- (IBAction)yesWithPhotosPressed:(id)sender {
    [_yesButton setEnabled:NO];
    [_yesWithPhotosButton setEnabled:NO];
    [_noButton setEnabled:NO];
    [_cancelButton setEnabled:NO];
    
    [_yesButton setAlpha:0.5f];
    [_yesWithPhotosButton setAlpha:0.5f];
    [_noButton setAlpha:0.5f];
    [_cancelButton setAlpha:0.5f];
    
    NSData * sendImage = UIImageJPEGRepresentation(_screenshot, 1.0);
    
    NSString * base64 = [sendImage base64EncodedStringWithOptions:kNilOptions];
    
    [_ROSController publishImage:base64];
    
    _morePhotos = YES;
    
    [self enrollPerson];
}

- (IBAction)noButtonPressed:(id)sender {
    
    [_yesButton setEnabled:NO];
    [_yesWithPhotosButton setEnabled:NO];
    [_noButton setEnabled:NO];
    
    [_yesButton setAlpha:0.5f];
    [_yesWithPhotosButton setAlpha:0.5f];
    [_noButton setAlpha:0.5f];
    
    [self performSegueToCamera];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self performSegueToStart];
    
}

//-------------------------------------------------------------------------//
//                            FACIAL RECOGNITION                           //
//-------------------------------------------------------------------------//

// Try to recognise the person in front of the camera.
- (void)recognizePerson
{
    NSString * MyGallery = @"MyFaces";
    
    NSLog(@"Trying to match the user with the DB");
    
    [KairosSDK recognizeWithImage:_screenshot threshold:@"0.75" galleryName:MyGallery maxResults:@"10" success:^(NSDictionary *response) {
        
        NSLog(@"%@", response);
        [_ROSController publishFacialRecogntionMessage:[NSString stringWithFormat:@"%@", response]];
        
    } failure:^(NSDictionary *response) {
        
        [_ROSController publishFacialRecogntionMessage:[NSString stringWithFormat:@"%@", response]];
        NSLog(@"%@", response);
        
    }];
    
}



// Try to recognise the person in front of the camera.
- (void)enrollPerson
{
    [TextToSpeech talkText:@"Please wait."];
    NSString * MyGallery = @"MyFaces";
    
    NSLog(@"Enrolling user in the DB");
    [KairosSDK enrollWithImage:_screenshot subjectId:_username galleryName:MyGallery success:^(NSDictionary *response) {
        
        NSLog(@"%@", response);
        [_ROSController publishFacialRecogntionMessage:[NSString stringWithFormat:@"%@", response]];
        
        if(_morePhotos){
            if(_firsttime){
                [TextToSpeech talkText:@""];
            }
            else{
                [TextToSpeech talkText:@"The more photos the better!"];
            }
            [self performSegueToCamera];
        }
        else{
            if(_firsttime){
                [TextToSpeech talkText:@"You are successfully registered. I will start recognizing you the next time you use this application."];
            }
            else{
                [TextToSpeech talkText:@"I successfully added your photo to your profile. I'm certain I will recognize you the next time!"];
            }
            [self performSegueToPersonalView];
        }
        
    } failure:^(NSDictionary *response) {
        
        [TextToSpeech talkText:@"It looks like something went wrong with your photo. Please try again."];
        [self performSegueToCamera];
        NSLog(@"%@", response);
        [_ROSController publishFacialRecogntionMessage:[NSString stringWithFormat:@"%@", response]];
        
    }];
}

//-------------------------------------------------------------------------//
//                                  SEGUE                                  //
//-------------------------------------------------------------------------//

-(void)performSegueToStart{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to Start..."];
            [self performSegueWithIdentifier:@"toStart" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

- (void)performSegueToCamera{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to Camera..."];
            [self performSegueWithIdentifier:@"toCamera" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

- (void) performSegueToPersonalView{
    if(SEGUES_ENABLED){
        @try {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_ROSController publishViewFlow:@"Going to PersonalView..."];
                [self performSegueWithIdentifier:@"toPersonalView" sender:self];
            });
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

///////////////////////////////////////////////////////////////

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    // !!! IMPORTANT: TIMER !!! //
    // Stop the timer before continuing to the next view
    [self resetTimer];
    
    if([segue.identifier isEqualToString:@"toStart"]){
        ViewController *controller = (ViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        
        controller.ROSController = _ROSController;
    }
    
    if([segue.identifier isEqualToString:@"toCamera"]){
        
        [TextToSpeech stopTalking];
        
        CameraViewController *controller = (CameraViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = @"";
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.username = _username;
        controller.user_tag = _user_tag;
        controller.firsttime = _firsttime;
        controller.alreadyBeenHere = _alreadyBeenHere;
        
        controller.ROSController = _ROSController;
    }
    
    if([segue.identifier isEqualToString:@"toPersonalView"]){
        
        PersonalViewController *controller = (PersonalViewController *)segue.destinationViewController;
        
        // Reset temporal message from the facial recognition software
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.username = _username;
        controller.user_tag = _user_tag;
        controller.firsttime = _firsttime;
        
        controller.ROSController = _ROSController;
    }
    
}

@end
