//
//  TextToSpeech.m
//  Facial Recognition
//
//  Created by Kilian Michiels on 1/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import "TextToSpeech.h"
#import "constants.h"

AVSpeechSynthesizer * synthesizer;

@implementation TextToSpeech

//-------------------------------------------------------------------------//
//                                 TALKING                                 //
//-------------------------------------------------------------------------//

/*
 Initialize the text to speech on the iPad.
 The iPad says "t" on startup if TESTING_VARIABLES == YES when everything works fine.
 */

+ (void)initializeTalker{
    synthesizer = [[AVSpeechSynthesizer alloc] init];
    synthesizer.delegate = synthesizer;
    if(TESTING_VARIABLES){
        NSString *text = @"t";
        
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
        
        [synthesizer speakUtterance:utterance];
    }
}

/*
 talk: method to say standardized phrases embedded in the program.
 The index decides which phrase is spoken.
 
 index = 0 --> "Hello there!"
 index = 1 --> "Thank you. The picture is being processed."
 index = 2 --> "That's all!"
 index = 3 --> "Please stand in front of the camera."
 index = 4 --> "It looks like I could not recognize you. Please enter your name so I can recognise you in the future."
 index = 5 --> "If you have any comments or suggestions, please insert them here."
 
 */
+ (void) talk: (int) index
{
    NSString *text = @"";
    
    // Draw the attention of the person who triggered the motion detection.
    if(index == 0){
        
        text = @"Hello there!";
        
    }
    // Notify the person the image was taken.
    else if(index == 1){
        
        text = @"Thank you. The picture is being processed.";
        
    }
    // Notify the person they don't have to stand in front of the camera anymore.
    // (This can also be used to return to the main screen.)
    else if(index == 2){
        
        text = @"That's all!";
        
    }
    // Notify the person they have to stand in front of the camera to take a picture.
    else if(index == 3){
        
        text = @"Please stand in front of the camera.";
        
    }
    // Notify the person they were not recognised.
    else if (index == 4){
        
        text = @"It looks like I could not recognize you. Please enter your name so I can recognise you in the future.";
        
    }
    // Ask the user for feedback.
    else if (index == 5){
        
        text = @"If you have any comments or suggestions, please insert them here.";
        
    }
    // Ask the user if they are a visitor or an employee.
    else if (index == 6){
        
        text = @"Are you visiting here or are you an employee? Please choose one of the options.";
        
    }
    
    // The iPad should not talk.
    else{
        
        text = @"Test. I was not supposed to say anything.";
        
    }
    
    // Do the actual talking.
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    [synthesizer speakUtterance:utterance];
}

/*
 talkText: used for not so common used words like names.
 */
+ (void) talkText:(NSString *)text{
    // Do the actual talking.
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    [synthesizer speakUtterance:utterance];
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"\n\n----------Done speaking----------\n\n");
}

+(void)stopTalking{
    if([synthesizer isSpeaking]){
        [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

+(void)continueTalking{
    if(![synthesizer isSpeaking]){
        [synthesizer continueSpeaking];
    }
}

@end
