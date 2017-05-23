//
//  DoubleRoboticsControl.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 5/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DoubleControlSDK/DoubleControlSDK.h>

extern NSString * const DoubleControlNotification;

@class DoubleRoboticsControl;

@protocol DoubleControlDelegate <NSObject>

@optional
- (void)DoubleControlConnected:(DoubleRoboticsControl*)DoubleControl;
- (void)DoubleControlDisconnected:(DoubleRoboticsControl*)DoubleControl;

@end

@interface DoubleRoboticsControl : NSObject <DRDoubleDelegate>

@property (nonatomic, assign) id<DoubleControlDelegate> delegate;

+ (id) sharedInstance;

- (void) initializeDRConnection;

- (void) poleUp;

- (void) poleDown;

- (void)poleStop;

@end
