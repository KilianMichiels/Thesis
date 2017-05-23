//
//  IDViewController.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 4/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface IDViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *employeeButton;
@property (strong, nonatomic) IBOutlet UIButton *visitorButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *removeFaceButton;

// Core data:
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

// Global statistic parameters
@property int fail;
@property int success;
@property NSObject *facialRecognitionMessage;
@property BOOL sessionSet;
@property NSDate* session;
@property NSString * user_tag;
@property NSString * username;
@property BOOL firsttime;


// ROS Variables:
@property MainROSDoubleControl * ROSController;


@end
