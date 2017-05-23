//
//  PersonalViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 5/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OIDAuthState;

@class OIDServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PersonalViewController : UIViewController

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;
@property NSString * user_tag;
@property NSString * username;
@property BOOL firsttime;

//////////////////////////////////////////////

@property (strong, nonatomic) IBOutlet UIView *informationView;
@property (strong, nonatomic) IBOutlet UILabel *PersonalisedViewNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *meetingRoomNumber;
@property (strong, nonatomic) IBOutlet UILabel *timendateLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;

@property(nullable) IBOutlet UIButton *authAutoButton;
@property(nullable) IBOutlet UIButton *authManual;
@property(nullable) IBOutlet UIButton *codeExchangeButton;
@property(nullable) IBOutlet UIButton *userinfoButton;
@property(nullable) IBOutlet UIButton *clearAuthStateButton;
@property(nullable) IBOutlet UITextView *logTextView;
@property (strong, nonatomic) IBOutlet UILabel *logLabel;
@property (strong, nonatomic) IBOutlet UILabel *thenLabel;
@property (strong, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) IBOutlet UIButton *clearLogButton;

///*! @brief The authorization state. This is the AppAuth object that you should keep around and
// serialize to disk.
// */
//@property(nonatomic, readonly, nullable) OIDAuthState *authState;
//
///*! @brief Authorization code flow using @c OIDAuthState automatic code exchanges.
// @param sender IBAction sender.
// */
//- (IBAction)authWithAutoCodeExchange:(nullable id)sender;
//
///*! @brief Authorization code flow without a the code exchange (need to call @c codeExchange:
// manually)
// @param sender IBAction sender.
// */
//- (IBAction)authNoCodeExchange:(nullable id)sender;
//
///*! @brief Performs the authorization code exchange at the token endpoint.
// @param sender IBAction sender.
// */
//- (IBAction)codeExchange:(nullable id)sender;
//
///*! @brief Performs a Userinfo API call using @c OIDAuthState.performActionWithFreshTokens.
// @param sender IBAction sender.
// */
//- (IBAction)userinfo:(nullable id)sender;
//
///*! @brief Nils the @c OIDAuthState object.
// @param sender IBAction sender.
// */
//- (IBAction)clearAuthState:(nullable id)sender;
//
///*! @brief Clears the UI log.
// @param sender IBAction sender.
// */
//- (IBAction)clearLog:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
