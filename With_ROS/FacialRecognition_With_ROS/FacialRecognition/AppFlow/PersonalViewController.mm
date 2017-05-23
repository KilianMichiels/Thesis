//
//  PersonalViewController.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 5/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "PersonalViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AppAuth.h"

#import "AppDelegate.h"

#import "TextToSpeech.h"

#import "constants.h"

#import "ViewController.h"

#import "IDViewController.h"

/////////////////////////////////// TESTING GOOGLE ///////////////////////////////////

//typedef void (^PostRegistrationCallback)(OIDServiceConfiguration *configuration,
//OIDRegistrationResponse *registrationResponse);
//
//static NSString *const kIssuer = @"https://accounts.google.com";
//
//static NSString *const kClientID = @"1064482184867-1fitqpelb46ovl7qn2vv5jhl4guanmij.apps.googleusercontent.com";
//
//static NSString *const kRedirectURI = @"com.googleusercontent.apps.1064482184867-1fitqpelb46ovl7qn2vv5jhl4guanmij:/oauth2redirect/google";
//static NSString *const kAppAuthExampleAuthStateKey = @"authState";

///////////////////////////////////////////////////////////////////////////////////////

@interface PersonalViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timeTimer;
@property (nonatomic, strong) NSTimer *attentionTimer;
@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_authAutoButton setAlpha:0.0f];
    [_authManual setAlpha:0.0f];
    [_codeExchangeButton setAlpha:0.0f];
    [_userinfoButton setAlpha:0.0f];
    [_clearAuthStateButton setAlpha:0.0f];
    [_logTextView setAlpha:0.0f];
    [_clearLogButton setAlpha:0.0f];
    [_orLabel setAlpha:0.0f];
    [_thenLabel setAlpha:0.0f];
    [_logLabel setAlpha:0.0f];
    
    
    
    [_informationView setAlpha:0.0f];
    [_PersonalisedViewNameLabel setText:[NSString stringWithFormat:@"Hello %@", _username]];
    
    NSLocale* currentLocale = [NSLocale currentLocale];
    _timendateLabel.text = [[NSDate date] descriptionWithLocale:currentLocale];
    
    if(TESTING_VARIABLES){
        
        [TextToSpeech initializeTalker];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [TextToSpeech talkText:@"Great! In the future you will be able to see your personalized information such as your schedule with your appointments of the day. For now this is just a template to give you an idea of what is possible. Please proceed by pressing 'Continue'."];
    
    [UIView animateWithDuration:1.5f animations:^{
        
        [_titleLabel setAlpha:1.0f];
        [_informationView setAlpha:1.0];
        [_continueButton setAlpha:1.0];
        
    } completion:nil];
    
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(updateLabel)
                                                      userInfo:nil
                                                       repeats:YES];
    
    // SET Attention timer:
    _attentionTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                  target:self
                                                selector:@selector(attentionButtons)
                                                userInfo:nil
                                                 repeats:YES];
    
    // !!! IMPORTANT: TIMER !!! //
    // If there is no activity in the next TIMER_TIME_FEEDBACK seconds, go back to the main screen.
    if(TIMERS_ENABLED){
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIME_FEEDBACK
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
    
    [_timeTimer invalidate];
    _timeTimer = nil;
    
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

- (void)updateLabel{
    NSLocale* currentLocale = [NSLocale currentLocale];
    _timendateLabel.text = [[NSDate date] descriptionWithLocale:currentLocale];
    
    // Determine next meeting.
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    [components setYear:2000];
    [components setDay:1];
    [components setMonth:1];
    
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSDate *currentTime = [calendar dateFromComponents:components];
    
    NSDate *meeting_1 = [formatter dateFromString:@"11:00"];
    NSDate *meeting_2 = [formatter dateFromString:@"13:45"];
    NSDate *meeting_3 = [formatter dateFromString:@"15:15"];
    
//    NSLog(@"Date currentTime: %@", currentTime);
//    NSLog(@"Date meeting_1: %@", meeting_1);
    
    if([meeting_1 compare:currentTime] == NSOrderedDescending){
//        NSLog(@"Meeting 1 is later than now.");
        _meetingRoomNumber.text = @"Meeting room 10.02 at 11.00 am.";
    }
    else if ([meeting_2 compare:currentTime] == NSOrderedDescending){
//        NSLog(@"Meeting 2 is later than now.");
        _meetingRoomNumber.text = @"Meeting room 11.04 at 1.45 pm.";
    }
    else if([meeting_3 compare:currentTime] == NSOrderedDescending){
//        NSLog(@"Meeting 3 is later than now.");
        _meetingRoomNumber.text = @"Meeting with Mr. X at 3.15 pm in 9.12.";
    }
    else{
//        NSLog(@"No more meetings today.");
        _meetingRoomNumber.text = @"You have no more appointments for the day.\nHave a nice day!";
    }
}

///////////////////////////////////////////////////////////////

- (void)attentionButtons{
    
    CGFloat h, s, b, a;
    
    [[_continueButton backgroundColor] getHue:&h saturation:&s brightness:&b alpha:&a];
    
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_continueButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.70]];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [_continueButton setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:0.15]];
            
        }];
    }];
}

//-------------------------------------------------------------------------//
//                                    UI                                   //
//-------------------------------------------------------------------------//

- (IBAction)nextPressed:(id)sender {
    
    [TextToSpeech stopTalking];
    [self performSegueToID];
    
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

-(void)performSegueToID{
    if(SEGUES_ENABLED){
        @try {
            [_ROSController publishViewFlow:@"Going to ID..."];
            [self performSegueWithIdentifier:@"toID" sender:self];
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
    
    if([segue.identifier isEqualToString:@"toID"]){
        IDViewController *controller = (IDViewController *)segue.destinationViewController;
        
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

/////////////////////////////////// TESTING GOOGLE ///////////////////////////////////

//- (void)verifyConfig {
//#if !defined(NS_BLOCK_ASSERTIONS)
//
//    // The example needs to be configured with your own client details.
//    // See: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
//
//    NSAssert(![kIssuer isEqualToString:@"https://issuer.example.com"],
//             @"Update kIssuer with your own issuer. "
//             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md");
//
//    NSAssert(![kClientID isEqualToString:@"YOUR_CLIENT_ID"],
//             @"Update kClientID with your own client ID. "
//             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md");
//
//    NSAssert(![kRedirectURI isEqualToString:@"com.example.app:/oauth2redirect/example-provider"],
//             @"Update kRedirectURI with your own redirect URI. "
//             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md");
//
//    // verifies that the custom URI scheme has been updated in the Info.plist
//    NSArray __unused* urlTypes =
//    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
//    NSAssert([urlTypes count] > 0, @"No custom URI scheme has been configured for the project.");
//    NSArray *urlSchemes =
//    [(NSDictionary *)[urlTypes objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"];
//    NSAssert([urlSchemes count] > 0, @"No custom URI scheme has been configured for the project.");
//    NSString *urlScheme = [urlSchemes objectAtIndex:0];
//
//    NSAssert(![urlScheme isEqualToString:@"com.example.app"],
//             @"Configure the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) "
//             "with the scheme of your redirect URI. Full instructions: "
//             "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md");
//
//#endif // !defined(NS_BLOCK_ASSERTIONS)
//}
//
///*! @brief Saves the @c OIDAuthState to @c NSUSerDefaults.
// */
//- (void)saveState {
//    // for production usage consider using the OS Keychain instead
//    NSData *archivedAuthState = [ NSKeyedArchiver archivedDataWithRootObject:_authState];
//    [[NSUserDefaults standardUserDefaults] setObject:archivedAuthState
//                                              forKey:kAppAuthExampleAuthStateKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
///*! @brief Loads the @c OIDAuthState from @c NSUSerDefaults.
// */
//- (void)loadState {
//    // loads OIDAuthState from NSUSerDefaults
//    NSData *archivedAuthState =
//    [[NSUserDefaults standardUserDefaults] objectForKey:kAppAuthExampleAuthStateKey];
//    if ([[[NSUserDefaults standardUserDefaults] dictionaryRepresentation].allKeys containsObject:@"keyForNonMandatoryObject"]) {
//        OIDAuthState *authState = [NSKeyedUnarchiver unarchiveObjectWithData:archivedAuthState];
//        [self setAuthState:authState];
//    }
//}
//
//- (void)setAuthState:(nullable OIDAuthState *)authState {
//    if (_authState == authState) {
//        return;
//    }
//    _authState = authState;
//    _authState.stateChangeDelegate = self;
//    [self stateChanged];
//}
//
///*! @brief Refreshes UI, typically called after the auth state changed.
// */
//- (void)updateUI {
//    _userinfoButton.enabled = [_authState isAuthorized];
//    _clearAuthStateButton.enabled = _authState != nil;
//    _codeExchangeButton.enabled = _authState.lastAuthorizationResponse.authorizationCode
//    && !_authState.lastTokenResponse;
//    // dynamically changes authorize button text depending on authorized state
//    if (!_authState) {
//        [_authAutoButton setTitle:@"Authorize" forState:UIControlStateNormal];
//        [_authAutoButton setTitle:@"Authorize" forState:UIControlStateHighlighted];
//        [_authManual setTitle:@"Authorize (Manual)" forState:UIControlStateNormal];
//        [_authManual setTitle:@"Authorize (Manual)" forState:UIControlStateHighlighted];
//    } else {
//        [_authAutoButton setTitle:@"Re-authorize" forState:UIControlStateNormal];
//        [_authAutoButton setTitle:@"Re-authorize" forState:UIControlStateHighlighted];
//        [_authManual setTitle:@"Re-authorize (Manual)" forState:UIControlStateNormal];
//        [_authManual setTitle:@"Re-authorize (Manual)" forState:UIControlStateHighlighted];
//    }
//}
//
//- (void)stateChanged {
//    [self saveState];
//    [self updateUI];
//}
//
//- (void)didChangeState:(OIDAuthState *)state {
//    [self stateChanged];
//}
//
//- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(nonnull NSError *)error {
//    [self logMessage:@"Received authorization error: %@", error];
//}
//
//- (void)doClientRegistration:(OIDServiceConfiguration *)configuration
//                    callback:(PostRegistrationCallback)callback {
//    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
//
//    OIDRegistrationRequest *request =
//    [[OIDRegistrationRequest alloc] initWithConfiguration:configuration
//                                             redirectURIs:@[ redirectURI ]
//                                            responseTypes:nil
//                                               grantTypes:nil
//                                              subjectType:nil
//                                  tokenEndpointAuthMethod:@"client_secret_post"
//                                     additionalParameters:nil];
//    // performs registration request
//    [self logMessage:@"Initiating registration request"];
//
//    [OIDAuthorizationService performRegistrationRequest:request
//                                             completion:^(OIDRegistrationResponse *_Nullable regResp, NSError *_Nullable error) {
//                                                 if (regResp) {
//                                                     [self setAuthState:[[OIDAuthState alloc] initWithRegistrationResponse:regResp]];
//                                                     [self logMessage:@"Got registration response: [%@]", regResp];
//                                                     callback(configuration, regResp);
//                                                 } else {
//                                                     [self logMessage:@"Registration error: %@", [error localizedDescription]];
//                                                     [self setAuthState:nil];
//                                                 }
//                                             }];
//}
//
//- (void)doAuthWithAutoCodeExchange:(OIDServiceConfiguration *)configuration
//                          clientID:(NSString *)clientID
//                      clientSecret:(NSString *)clientSecret {
//    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
//    // builds authentication request
//    OIDAuthorizationRequest *request =
//    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
//                                                  clientId:clientID
//                                              clientSecret:clientSecret
//                                                    scopes:@[ OIDScopeOpenID, OIDScopeProfile ]
//                                               redirectURL:redirectURI
//                                              responseType:OIDResponseTypeCode
//                                      additionalParameters:nil];
//    // performs authentication request
//    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
//    [self logMessage:@"Initiating authorization request with scope: %@", request.scope];
//
//    appDelegate.currentAuthorizationFlow =
//    [OIDAuthState authStateByPresentingAuthorizationRequest:request
//                                   presentingViewController:self
//                                                   callback:^(OIDAuthState *_Nullable authState, NSError *_Nullable error) {
//                                                       if (authState) {
//                                                           [self setAuthState:authState];
//                                                           [self logMessage:@"Got authorization tokens. Access token: %@",
//                                                            authState.lastTokenResponse.accessToken];
//                                                       } else {
//                                                           [self logMessage:@"Authorization error: %@", [error localizedDescription]];
//                                                           [self setAuthState:nil];
//                                                       }
//                                                   }];
//}
//
//- (void)doAuthWithoutCodeExchange:(OIDServiceConfiguration *)configuration
//                         clientID:(NSString *)clientID
//                     clientSecret:(NSString *)clientSecret {
//    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
//
//    // builds authentication request
//    OIDAuthorizationRequest *request =
//    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
//                                                  clientId:clientID
//                                              clientSecret:clientSecret
//                                                    scopes:@[ OIDScopeOpenID, OIDScopeProfile ]
//                                               redirectURL:redirectURI
//                                              responseType:OIDResponseTypeCode
//                                      additionalParameters:nil];
//    // performs authentication request
//    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
//    [self logMessage:@"Initiating authorization request %@", request];
//    appDelegate.currentAuthorizationFlow =
//    [OIDAuthorizationService presentAuthorizationRequest:request
//                                presentingViewController:self
//                                                callback:^(OIDAuthorizationResponse *_Nullable authorizationResponse,
//                                                           NSError *_Nullable error) {
//                                                    if (authorizationResponse) {
//                                                        OIDAuthState *authState =
//                                                        [[OIDAuthState alloc] initWithAuthorizationResponse:authorizationResponse];
//                                                        [self setAuthState:authState];
//
//                                                        [self logMessage:@"Authorization response with code: %@",
//                                                         authorizationResponse.authorizationCode];
//                                                        // could just call [self tokenExchange:nil] directly, but will let the user initiate it.
//                                                    } else {
//                                                        [self logMessage:@"Authorization error: %@", [error localizedDescription]];
//                                                    }
//                                                }];
//}
//
//- (IBAction)authWithAutoCodeExchange:(nullable id)sender {
//    [self verifyConfig];
//
//    NSURL *issuer = [NSURL URLWithString:kIssuer];
//
//    [self logMessage:@"Fetching configuration for issuer: %@", issuer];
//
//    // discovers endpoints
//    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
//                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
//                                                            if (!configuration) {
//                                                                [self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
//                                                                [self setAuthState:nil];
//                                                                return;
//                                                            }
//
//                                                            [self logMessage:@"Got configuration: %@", configuration];
//
//                                                            if (!kClientID) {
//                                                                [self doClientRegistration:configuration
//                                                                                  callback:^(OIDServiceConfiguration *configuration,
//                                                                                             OIDRegistrationResponse *registrationResponse) {
//                                                                                      [self doAuthWithAutoCodeExchange:configuration
//                                                                                                              clientID:registrationResponse.clientID
//                                                                                                          clientSecret:registrationResponse.clientSecret];
//                                                                                  }];
//                                                            } else {
//                                                                [self doAuthWithAutoCodeExchange:configuration clientID:kClientID clientSecret:nil];
//                                                            }
//                                                        }];
//}
//
//- (IBAction)authNoCodeExchange:(nullable id)sender {
//    [self verifyConfig];
//
//    NSURL *issuer = [NSURL URLWithString:kIssuer];
//
//    [self logMessage:@"Fetching configuration for issuer: %@", issuer];
//
//    // discovers endpoints
//    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
//                                                        completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
//
//                                                            if (!configuration) {
//                                                                [self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
//                                                                return;
//                                                            }
//
//                                                            [self logMessage:@"Got configuration: %@", configuration];
//
//                                                            if (!kClientID) {
//                                                                [self doClientRegistration:configuration
//                                                                                  callback:^(OIDServiceConfiguration *configuration,
//                                                                                             OIDRegistrationResponse *registrationResponse) {
//                                                                                      [self doAuthWithoutCodeExchange:configuration
//                                                                                                             clientID:registrationResponse.clientID
//                                                                                                         clientSecret:registrationResponse.clientSecret];
//                                                                                  }];
//                                                            } else {
//                                                                [self doAuthWithoutCodeExchange:configuration clientID:kClientID clientSecret:nil];
//                                                            }
//                                                        }];
//}
//
//- (IBAction)codeExchange:(nullable id)sender {
//    // performs code exchange request
//    OIDTokenRequest *tokenExchangeRequest =
//    [_authState.lastAuthorizationResponse tokenExchangeRequest];
//
//    [self logMessage:@"Performing authorization code exchange with request [%@]",
//     tokenExchangeRequest];
//
//    [OIDAuthorizationService performTokenRequest:tokenExchangeRequest
//                                        callback:^(OIDTokenResponse *_Nullable tokenResponse,
//                                                   NSError *_Nullable error) {
//
//                                            if (!tokenResponse) {
//                                                [self logMessage:@"Token exchange error: %@", [error localizedDescription]];
//                                            } else {
//                                                [self logMessage:@"Received token response with accessToken: %@", tokenResponse.accessToken];
//                                            }
//
//                                            [_authState updateWithTokenResponse:tokenResponse error:error];
//                                        }];
//}
//
//- (IBAction)clearAuthState:(nullable id)sender {
//    [self setAuthState:nil];
//}
//
//- (IBAction)clearLog:(nullable id)sender {
//    _logTextView.text = @"";
//}
//
//- (IBAction)userinfo:(nullable id)sender {
//    NSURL *userinfoEndpoint =
//    _authState.lastAuthorizationResponse.request.configuration.discoveryDocument.userinfoEndpoint;
//    if (!userinfoEndpoint) {
//        [self logMessage:@"Userinfo endpoint not declared in discovery document"];
//        return;
//    }
//    NSString *currentAccessToken = _authState.lastTokenResponse.accessToken;
//
//    [self logMessage:@"Performing userinfo request"];
//
//    [_authState performActionWithFreshTokens:^(NSString *_Nonnull accessToken,
//                                               NSString *_Nonnull idToken,
//                                               NSError *_Nullable error) {
//        if (error) {
//            [self logMessage:@"Error fetching fresh tokens: %@", [error localizedDescription]];
//            return;
//        }
//
//        // log whether a token refresh occurred
//        if (![currentAccessToken isEqual:accessToken]) {
//            [self logMessage:@"Access token was refreshed automatically (%@ to %@)",
//             currentAccessToken,
//             accessToken];
//        } else {
//            [self logMessage:@"Access token was fresh and not updated [%@]", accessToken];
//        }
//
//        // creates request to the userinfo endpoint, with access token in the Authorization header
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userinfoEndpoint];
//        NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
//        [request addValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
//
//        NSURLSessionConfiguration *configuration =
//        [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
//                                                              delegate:nil
//                                                         delegateQueue:nil];
//
//        // performs HTTP request
//        NSURLSessionDataTask *postDataTask =
//        [session dataTaskWithRequest:request
//                   completionHandler:^(NSData *_Nullable data,
//                                       NSURLResponse *_Nullable response,
//                                       NSError *_Nullable error) {
//                       dispatch_async(dispatch_get_main_queue(), ^() {
//                           if (error) {
//                               [self logMessage:@"HTTP request failed %@", error];
//                               return;
//                           }
//                           if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
//                               [self logMessage:@"Non-HTTP response"];
//                               return;
//                           }
//
//                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//                           id jsonDictionaryOrArray =
//                           [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
//
//                           if (httpResponse.statusCode != 200) {
//                               // server replied with an error
//                               NSString *responseText = [[NSString alloc] initWithData:data
//                                                                              encoding:NSUTF8StringEncoding];
//                               if (httpResponse.statusCode == 401) {
//                                   // "401 Unauthorized" generally indicates there is an issue with the authorization
//                                   // grant. Puts OIDAuthState into an error state.
//                                   NSError *oauthError =
//                                   [OIDErrorUtilities resourceServerAuthorizationErrorWithCode:0
//                                                                                 errorResponse:jsonDictionaryOrArray
//                                                                               underlyingError:error];
//                                   [_authState updateWithAuthorizationError:oauthError];
//                                   // log error
//                                   [self logMessage:@"Authorization Error (%@). Response: %@", oauthError, responseText];
//                               } else {
//                                   [self logMessage:@"HTTP: %d. Response: %@",
//                                    (int)httpResponse.statusCode,
//                                    responseText];
//                               }
//                               return;
//                           }
//
//                           // success response
//                           [self logMessage:@"Success: %@", jsonDictionaryOrArray];
//                       });
//                   }];
//
//        [postDataTask resume];
//    }];
//}
//
///*! @brief Logs a message to stdout and the textfield.
// @param format The format string and arguments.
// */
//- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
//    // gets message as string
//    va_list argp;
//    va_start(argp, format);
//    NSString *log = [[NSString alloc] initWithFormat:format arguments:argp];
//    va_end(argp);
//
//    // outputs to stdout
//    NSLog(@"%@", log);
//
//    // appends to output log
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"hh:mm:ss";
//    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
//    _logTextView.text = [NSString stringWithFormat:@"%@%@%@: %@",
//                         _logTextView.text,
//                         ([_logTextView.text length] > 0) ? @"\n" : @"",
//                         dateString,
//                         log];
//}

@end
