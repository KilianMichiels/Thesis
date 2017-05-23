//
//  TestingViewController.h
//  FacialRecognition
//
//  Created by Kilian Michiels on 18/05/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "DataStorage.h"
#import <UIKit/UIKit.h>

@interface TestingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *timeStart;
@property (strong, nonatomic) IBOutlet UILabel *timeStop;
@property (strong, nonatomic) IBOutlet UILabel *timeSearchOne;
@property (strong, nonatomic) IBOutlet UILabel *timeSearchAvg;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPeopleInDBLabel;
@property (strong, nonatomic) IBOutlet UILabel *NumberOfSearchesLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeSearchTotal;
@property (strong, nonatomic) IBOutlet UITextField *N;

@end
