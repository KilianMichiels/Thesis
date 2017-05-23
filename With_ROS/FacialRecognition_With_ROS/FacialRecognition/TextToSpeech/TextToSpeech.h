//
//  TextToSpeech.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 1/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TextToSpeech : NSObject 

/*
 Initialize the text to speech on the iPad.
 The iPad says "Testing" on startup when everything works fine.
 */
+ (void) initializeTalker;

/*
 talk: method to say standardized phrases embedded in the program.
 The index decides which phrase is spoken.
 */
+ (void) talk: (int) index;

/*
 talkText: used for not so common used words like names.
 */
+ (void) talkText: (NSString*) text;

+ (void) stopTalking;

+ (void) continueTalking;

@end
