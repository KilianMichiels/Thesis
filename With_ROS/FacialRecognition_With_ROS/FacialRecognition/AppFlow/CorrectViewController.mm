//
//  CorrectViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 6/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "CorrectViewController.h"
#import "constants.h"
#import "ViewController.h"
#import "ErrorViewController.h"
#import "TextToSpeech.h"
#import "PersonalViewController.h"
#import "KairosSDK.h"
#import "KairosSDKViewController.h"

UIImage * screenshot_correct;

@interface CorrectViewController ()
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *attentionTimer;
@end

@implementation CorrectViewController

//-------------------------------------------------------------------------//
//                                 GENERAL                                 //
//-------------------------------------------------------------------------//

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_titleLabel setAlpha:0.0f];
    [_IDlabel setAlpha:0.0f];
    [_correctButton setAlpha:0.0f];
    [_notCorrectButton setAlpha:0.0f];
    
    [_IDlabel setText:[NSString stringWithFormat:@"I recognized you as:\n%@", _facialRecognitionMessage]];
    
}

///////////////////////////////////////////////////////////////

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////

- (void)viewDidAppear:(BOOL)animated{
    
    [UIView animateWithDuration:1.5f animations:^{
        
        [_titleLabel setAlpha:1.0f];
        [_IDlabel setAlpha:1.0f];
        
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.5f animations:^{
            
            [_correctButton setAlpha:1.0f];
            [_notCorrectButton setAlpha:1.0f];
            
        } completion:nil];
        
    });
    
    //SET Attention timer:
    _attentionTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(attentionButtons) userInfo:nil repeats:YES];
    
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
    
    [[_correctButton backgroundColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_correctButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_correctButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
            
        }completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5f animations:^{
                [_notCorrectButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
                
            }completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5f animations:^{
                    [_notCorrectButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
                    
                }];
                
            }];
            
        }];
    }];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//
- (IBAction)correctButtonPushed:(id)sender {
    
    _username = _facialRecognitionMessage;
    
    _firsttime = NO;
    
    _success = _success + 1;
    
    [_ROSController publishFirstTime:_firsttime];
    [_ROSController publishUsername:_username];
    
    // If the photo was correct, let's add it to the database for a better recognition in the future.
    
    NSString * MyGallery = @"MyFaces";
    
    NSLog(@"\nAPI Parameters are:\nImage: %@\nsubjectId: %@\ngalleryName: %@\n",_photoTakenByKairos_Image,_username,MyGallery);
    
    NSLog(@"Enrolling user in the DB");
    [KairosSDK enrollWithImage:_photoTakenByKairos_Image subjectId:_username galleryName:MyGallery success:^(NSDictionary *response) {
        
        NSLog(@"%@", response);
        
    } failure:^(NSDictionary *response) {
        
        NSLog(@"%@", response);
        
    }];
    
    // Send image to ROS:
    NSData *compressedImageData = UIImageJPEGRepresentation(_photoTakenByKairos_Image, 1.0f);
    
    _photoTakenByKairos = [compressedImageData base64EncodedStringWithOptions:kNilOptions];
    
    [_ROSController publishImage:_photoTakenByKairos];
    
    // Go to the personal view.
    
    [self performSegueToPersonalView];
    
}

- (IBAction)notCorrectButtonPushed:(id)sender {
    
    _fail = _fail + 1;
    
    [self performSegueToError];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self performSegueToStart];
    
}

- (IBAction)removeFaceButtonPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!"
                                                    message:@"Please enter your name and it will be removed from the database."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete my face.", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
    
}

///////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1){
        NSString *input = [[alertView textFieldAtIndex:0] text];
        NSLog(@"\nEntered: %@ \n",input);
        
        NSString * MyGallery = @"MyFaces";
        
        [KairosSDK galleryRemoveSubject:input
                            fromGallery:MyGallery
                                success:^(NSDictionary *response) {
                                    
                                    NSLog(@"\n\n--- SUCCESSFULLY REMOVED FACE! ---\n");
                                    // API Response object (JSON)
                                    NSLog(@"\n%@", response);
                                    
                                    
                                    UIAlertController * alert = [UIAlertController
                                                                 alertControllerWithTitle:@"Done!"
                                                                 message:@"Your face has been deleted!"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction* continueButton = [UIAlertAction
                                                                     actionWithTitle:@"Continue"
                                                                     style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         
                                                                     }];
                                    
                                    [alert addAction:continueButton];
                                    
                                    [self presentViewController:alert animated: YES completion:nil];
                                    
                                    
                                } failure:^(NSDictionary *response) {
                                    
                                    NSLog(@"\n\n--- FAILED TO REMOVE FACE! ---\n");
                                    NSLog(@"\n%@", response);
                                    
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                                    message:@"Your face has not been deleted. Something went wrong. Try again!"
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"Continue"
                                                                          otherButtonTitles:nil];
                                    [alert show];
                                    
                                }];
    }
}

//-------------------------------------------------------------------------//
//                                  IMAGE                                  //
//-------------------------------------------------------------------------//

static inline double radians (double degrees) {return degrees * M_PI/180;}
-(UIImage*) rotate:(UIImage*) src orientation:(UIImageOrientation) orientation{
    
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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

///////////////////////////////////////////////////////////////

-(void)performSegueToError{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to Error..."];
            [self performSegueWithIdentifier:@"toError" sender:self];
        }
        @catch (NSException *exception) {
            NSLog(@"Segue not found: %@", exception);
        }
    }
}

///////////////////////////////////////////////////////////////

-(void)performSegueToPersonalView{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to PersonalView..."];
            [self performSegueWithIdentifier:@"toPersonalView" sender:self];
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
        controller.user_tag = @"";
        
        controller.ROSController = _ROSController;
    }
    
    if([segue.identifier isEqualToString:@"toError"]){
        ErrorViewController *controller = (ErrorViewController *)segue.destinationViewController;
        
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        controller.username = @"";
        controller.firsttime = _firsttime;
        
        controller.ROSController = _ROSController;
    }
    
    if([segue.identifier isEqualToString:@"toPersonalView"]){
        PersonalViewController *controller = (PersonalViewController *)segue.destinationViewController;
        
        controller.facialRecognitionMessage = _facialRecognitionMessage;
        
        // Statistic Variables
        controller.fail = _fail;
        controller.success = _success;
        controller.session = _session;
        controller.sessionSet = _sessionSet;
        controller.user_tag = _user_tag;
        controller.username = _username;
        controller.firsttime = _firsttime;
        
        controller.ROSController = _ROSController;
    }
    
    
}

@end
