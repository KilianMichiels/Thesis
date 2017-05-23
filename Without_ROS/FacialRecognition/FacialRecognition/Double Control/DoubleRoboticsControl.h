//
//  DoubleRoboticsControl.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 5/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DoubleControlSDK/DoubleControlSDK.h>

@interface DoubleRoboticsControl : NSObject <DRDoubleDelegate>

+ (void) initializeDRConnection;

+ (void) poleUp;

+ (void) poleDown;

+ (void)poleStop;

// This method is used to receive the data which we get using post method.
+ (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data;

// This method receives the error report in case of connection is not made to server.
+ (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

// This method is used to process the data after connection has made successfully.
+ (void)connectionDidFinishLoading:(NSURLConnection *)connection;

#pragma mark - DRDoubleDelegate

+ (void)doubleDidConnect:(DRDouble *)theDouble;

+ (void)doubleDidDisconnect:(DRDouble *)theDouble;

+ (void)doubleStatusDidUpdate:(DRDouble *)theDouble;

@end
