//
//  DoubleRoboticsControl.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 5/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "DoubleRoboticsControl.h"

@implementation DoubleRoboticsControl

+ (void) initializeDRConnection{
    [DRDouble sharedDouble].delegate = self;
}

+ (void) poleUp{
    [[DRDouble sharedDouble] poleUp];
    NSLog(@"Pole up action triggered");
}

+ (void) poleDown{
    [[DRDouble sharedDouble] poleDown];
    NSLog(@"Pole down action triggered");
}

+ (void)poleStop{
    [[DRDouble sharedDouble] poleStop];
    NSLog(@"Pole stop action triggered");
}

// This method is used to receive the data which we get using post method.
+ (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data{
    NSLog(@"%@", [NSString stringWithFormat: @"Received data: %@",connection.description]);
}

// This method receives the error report in case of connection is not made to server.
+ (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@", [NSString stringWithFormat: @"Connection failed: %@",connection.description]);
}

// This method is used to process the data after connection has made successfully.
+ (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"%@", [NSString stringWithFormat: @"Finished Loading: %@",connection.description]);
}

#pragma mark - DRDoubleDelegate

+ (void)doubleDidConnect:(DRDouble *)theDouble {
    NSLog(@"Double is Connected");
}

+ (void)doubleDidDisconnect:(DRDouble *)theDouble {
    NSLog(@"Double is Not Connected");
}

+ (void)doubleStatusDidUpdate:(DRDouble *)theDouble {
    NSLog(@"\npoleHeightPercent: %@",[NSString stringWithFormat:@"%d", [DRDouble sharedDouble].kickstandState]);
    NSLog(@"\nBattery Percentage: %@", [NSString stringWithFormat:@"%f", [DRDouble sharedDouble].batteryPercent]);
    NSLog(@"\nFirmware Version: %@", [DRDouble sharedDouble].firmwareVersion);
    NSLog(@"\nSerial Number: %@", [DRDouble sharedDouble].serial);
}

@end
