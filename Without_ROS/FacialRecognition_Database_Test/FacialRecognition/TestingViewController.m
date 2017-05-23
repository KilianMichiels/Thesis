//
//  TestingViewController.m
//  FacialRecognition
//
//  Created by Kilian Michiels on 18/05/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "TestingViewController.h"
#include <stdlib.h>

@interface TestingViewController ()
@property NSTimeInterval time_start;
@property NSTimeInterval time_stop;

@property float searchTimeOne;
@property float searchTimeAvg;
@property int numberOfPeopleInDB;
@property int numberOfSearches;
@property float totalSearchTime;
@end

@implementation TestingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchTimeOne = 0.0;
    _searchTimeAvg = 0.0;
    _numberOfPeopleInDB = 0;
    _numberOfSearches = 0;
    _totalSearchTime = 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)addOne{
    
    BOOL added = [DataStorage addUser:[NSString stringWithFormat:@"%d", _numberOfPeopleInDB] user_tag:@"TEST_SUBJECT"];
    
    if(added){
        _numberOfPeopleInDB += 1;
        
        _numberOfPeopleInDBLabel.text = [NSString stringWithFormat:@"%d",_numberOfPeopleInDB];
    }
}

- (IBAction)add100:(id)sender {
    for (int i = 0; i < 100; i++) {
        [self addOne];
    }
}

- (IBAction)search:(id)sender {
    int r = arc4random_uniform(_numberOfPeopleInDB);
    _time_start = [[NSDate date] timeIntervalSince1970];
//    NSLog(@"Start: %f", _time_start);
    BOOL exist = [DataStorage checkForUserExistance:[NSString stringWithFormat:@"%d", r]];
    _time_stop = [[NSDate date] timeIntervalSince1970];
//    NSLog(@"Stop: %f",_time_stop);
    _totalSearchTime += (_time_stop-_time_start);
//    NSLog(@"Total search time: %f",_time_stop-_time_start);
    
    if (exist){
        _numberOfSearches += 1;
        _NumberOfSearchesLabel.text = [NSString stringWithFormat:@"%d", _numberOfSearches];
        
        NSLog(@"Done searching for the %d th person.", _numberOfSearches);
        [self updateUI];
    }
}

-(void)updateUI{
    _timeStart.text = [NSString stringWithFormat:@"%f",_time_start];
    _timeStop.text = [NSString stringWithFormat:@"%f",_time_stop];
    
    _timeSearchOne.text = [NSString stringWithFormat:@"%f",_time_stop-_time_start];
    _timeSearchAvg.text = [NSString stringWithFormat:@"%f",_totalSearchTime/_numberOfSearches];
    _timeSearchTotal.text = [NSString stringWithFormat:@"%f",_totalSearchTime];
}

- (IBAction)clear:(id)sender {
    [DataStorage deleteData];
    
    _totalSearchTime = 0.0;
    _numberOfSearches = 0;
    _searchTimeOne = 0.0;
    _searchTimeAvg = 0.0;
    _numberOfPeopleInDB = 0;
    
    
    _numberOfPeopleInDBLabel.text = [NSString stringWithFormat:@"%d",_numberOfPeopleInDB];
    _NumberOfSearchesLabel.text = [NSString stringWithFormat:@"%d",_numberOfSearches];
    
    _timeStart.text = @"<time>";
    _timeStop.text = @"<time>";
    
    _timeSearchOne.text = @"<time>";
    _timeSearchAvg.text = @"<time>";
    _timeSearchTotal.text = @"<time>";
}
- (IBAction)search1000:(id)sender {
    for(int i=0; i < 1000; i++){
        [self search:self];
    }
}
- (IBAction)addN:(id)sender {
    if (_N.text != nil) {
        int N_add = [_N.text intValue];
        for(int i=0; i < N_add; i++){
            [self addOne];
        }
    }
}

- (IBAction)searchN:(id)sender {
    if (_N.text != nil) {
     
        int N_searches = [_N.text intValue];
        for(int i=0; i < N_searches; i++){
            [self search:self];
        }
        
    }
}

@end
