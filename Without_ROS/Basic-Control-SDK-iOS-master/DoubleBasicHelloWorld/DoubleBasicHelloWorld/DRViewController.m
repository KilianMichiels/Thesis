//
//  DRViewController.m
//  DoubleBasicHelloWorld
//
//  Created by David Cann on 8/3/13.
//  Copyright (c) 2013 Double Robotics, Inc. All rights reserved.
//

#import "DRViewController.h"
#import <DoubleControlSDK/DoubleControlSDK.h>


@interface DRViewController () <DRDoubleDelegate>
@end

@implementation DRViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	[DRDouble sharedDouble].delegate = self;
	NSLog(@"SDK Version: %@", kDoubleBasicSDKVersion);

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark - Actions

- (IBAction)poleUp:(id)sender {
	[[DRDouble sharedDouble] poleUp];
    actionText.text = @"Moving pole up";
}

- (IBAction)poleStop:(id)sender {
	[[DRDouble sharedDouble] poleStop];
    actionText.text = @"-";

}

- (IBAction)poleDown:(id)sender {
	[[DRDouble sharedDouble] poleDown];
    actionText.text = @"Moving pole down";

}

- (IBAction)kickstandsRetract:(id)sender {
	[[DRDouble sharedDouble] retractKickstands];
    actionText.text = @"Retracting kickstand";
}

- (IBAction)kickstandsDeploy:(id)sender {
	[[DRDouble sharedDouble] deployKickstands];
    actionText.text = @"Deploying kickstand";
}

- (IBAction)getInstructions:(id)sender {
    NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",@"username",@"password"];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://www.abcde.com/xyz/login.aspx"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }
    actionText.text = @"Getting Instructions";
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data{
    actionText.text = [NSString stringWithFormat: @"Received data: %@",connection.description];
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    actionText.text = [NSString stringWithFormat: @"Connection failed: %@",connection.description];}

// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    actionText.text = [NSString stringWithFormat: @"Finished Loading: %@",connection.description];
}

#pragma mark - DRDoubleDelegate

- (void)doubleDidConnect:(DRDouble *)theDouble {
	statusLabel.text = @"Double is Connected";
}

- (void)doubleDidDisconnect:(DRDouble *)theDouble {
	statusLabel.text = @"Double is Not Connected";
}

- (void)doubleStatusDidUpdate:(DRDouble *)theDouble {
	poleHeightPercentLabel.text = [NSString stringWithFormat:@"%f", [DRDouble sharedDouble].poleHeightPercent];
	kickstandStateLabel.text = [NSString stringWithFormat:@"%d", [DRDouble sharedDouble].kickstandState];
	batteryPercentLabel.text = [NSString stringWithFormat:@"%f", [DRDouble sharedDouble].batteryPercent];
	batteryIsFullyChargedLabel.text = [NSString stringWithFormat:@"%d", [DRDouble sharedDouble].batteryIsFullyCharged];
	firmwareVersionLabel.text = [DRDouble sharedDouble].firmwareVersion;
	serialLabel.text = [DRDouble sharedDouble].serial;
}

- (void)doubleDriveShouldUpdate:(DRDouble *)theDouble {
    float drive = 0.0;
    float turn = 0.0;
    float degrees = 0.0;
    
    // Check drivingbuttons forward and backwards
    if(driveForwardButton.highlighted){
        drive = kDRDriveDirectionForward;
        actionText.text = @"Moving forward";
    }
    else if (driveBackwardButton.highlighted){
        drive = kDRDriveDirectionBackward;
        actionText.text = @"Moving backwards";
    }
    
    // Check left or right
    if(driveRightButton.highlighted){
        turn = 1.0;
        degrees = -45.0;
        actionText.text = @"Turning right";
    }
    else if (driveLeftButton.highlighted){
        turn = -1.0;
        degrees = 45.0;
        actionText.text = @"Turning left";
    }
    
	[theDouble drive:drive turn:turn];
//    [[DRDouble sharedDouble] turnByDegrees:degrees];

}
@end
