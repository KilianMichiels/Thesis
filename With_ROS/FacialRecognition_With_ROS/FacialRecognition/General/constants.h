//
//  constants.h
//  Facial Recognition
//
//  Created by Kilian Michiels on 2/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#ifndef constants_h
#define constants_h

///////////////////// FOR TESTING PURPOSES ONLY! /////////////////////
/**/                                                              /**/
/**/    #define TIMERS_ENABLED                  ((BOOL) YES)      /**/
/**/    #define TESTING_VARIABLES               ((BOOL) NO)       /**/
/**/    #define SEGUES_ENABLED                  ((BOOL) YES)      /**/
/**/                                                              /**/
//////////////////////////////////////////////////////////////////////


// How long should the application wait before starting the sequence when motion is detected.
#define DELAY_BEFORE_MOTION_DETECTION_STARTUP   ((double) 10.0)

// Time before the view returns to start for each of the viewControllers.
#define TIMER_TIME_STANDARD             ((double) 90.0)

#define TIMER_TIME_ATTENTION            ((double) 40.0)

#define TIMER_TIME_ID                   ((double) 60.0)

#define TIMER_TIME_CAMERA               ((double) 120.0)

#define TIMER_TIME_FACIAL_RECOGNITION   ((double) 60.0)

#define TIMER_TIME_FEEDBACK             ((double) 240.0)

// URL to go to in the WebViewFeedbackViewController. This depends on the user_tag.
/*
 Visitor_FR_first_time:
 - Form:
 https://docs.google.com/forms/d/e/1FAIpQLSfg3X_iXFz7QxprINLIfyscR1b4l7zRvVMdgyD142oofoyZkw/viewform
 
 - Response:
 https://docs.google.com/forms/d/e/1FAIpQLSfg3X_iXFz7QxprINLIfyscR1b4l7zRvVMdgyD142oofoyZkw/formResponse
 
 Visitor_FR_not_first_time:
 - Form:
 https://docs.google.com/forms/d/e/1FAIpQLScl0jiABDHbLuFHvjZEIms-aYx1eEgaH-B8AopkFGLshtx5Hw/viewform
 
 - Response:
 https://docs.google.com/forms/d/e/1FAIpQLScl0jiABDHbLuFHvjZEIms-aYx1eEgaH-B8AopkFGLshtx5Hw/formResponse
 
 Employee_FR_first_time:
 - Form:
 https://docs.google.com/forms/d/e/1FAIpQLScf8Jf6UHqZ5iFgX7MwSFA4o2FRmNm48155AY03jqyy5IyzNw/viewform
 
 - Response:
 https://docs.google.com/forms/d/e/1FAIpQLScf8Jf6UHqZ5iFgX7MwSFA4o2FRmNm48155AY03jqyy5IyzNw/formResponse
 
 Employee_FR_not_first_time:
 - Form:
 https://docs.google.com/forms/d/e/1FAIpQLSdbAVrR5cBH4qQfDORAvBUPRloQRjj31o7QfJzTmw-nJ9-C9Q/viewform
 
 - Response:
 https://docs.google.com/forms/d/e/1FAIpQLSdbAVrR5cBH4qQfDORAvBUPRloQRjj31o7QfJzTmw-nJ9-C9Q/formResponse
 
 Visitor_No_FR_Name:
 - Form:
 https://docs.google.com/forms/d/e/1FAIpQLSdOOdNQuh0c49I0mcKWJxfZL9ajzB6e7ku-YGe8JwhWgfLu4w/viewform
 
 - Response;
 https://docs.google.com/forms/d/e/1FAIpQLSdOOdNQuh0c49I0mcKWJxfZL9ajzB6e7ku-YGe8JwhWgfLu4w/formResponse
 
 Employee_No_FR_Name:
 - Form:
 https://docs.google.com/forms/d/e/1FAIpQLSfsMbwp9yV5M_l9j_fYM38Ly2jOtkxG7sNqaf0wof7SZud1SA/viewform
 
 - Response:
 https://docs.google.com/forms/d/e/1FAIpQLSfsMbwp9yV5M_l9j_fYM38Ly2jOtkxG7sNqaf0wof7SZud1SA/formResponse
 
 No_FR_No_Name:
 - Form:
 https://docs.google.com/forms/d/e/1FAIpQLSdyS4TDoxKLUpvIKedww43qIc1Mudsc91LL0YvxCoafxi4Xpg/viewform
 
 - Response:
 https://docs.google.com/forms/d/e/1FAIpQLSdyS4TDoxKLUpvIKedww43qIc1Mudsc91LL0YvxCoafxi4Xpg/formResponse
 */

#define Visitor_FR_first_time_form              @"https://docs.google.com/forms/d/e/1FAIpQLSfg3X_iXFz7QxprINLIfyscR1b4l7zRvVMdgyD142oofoyZkw/viewform?hl=en"
#define Visitor_FR_first_time_response          @"https://docs.google.com/forms/d/e/1FAIpQLSfg3X_iXFz7QxprINLIfyscR1b4l7zRvVMdgyD142oofoyZkw/formResponse?hl=en"

#define Visitor_FR_not_first_time_form          @"https://docs.google.com/forms/d/e/1FAIpQLScl0jiABDHbLuFHvjZEIms-aYx1eEgaH-B8AopkFGLshtx5Hw/viewform?hl=en"
#define Visitor_FR_not_first_time_response      @"https://docs.google.com/forms/d/e/1FAIpQLScl0jiABDHbLuFHvjZEIms-aYx1eEgaH-B8AopkFGLshtx5Hw/formResponse?hl=en"

#define Employee_FR_first_time_form             @"https://docs.google.com/forms/d/e/1FAIpQLScf8Jf6UHqZ5iFgX7MwSFA4o2FRmNm48155AY03jqyy5IyzNw/viewform?hl=en"
#define Employee_FR_first_time_response         @"https://docs.google.com/forms/d/e/1FAIpQLScf8Jf6UHqZ5iFgX7MwSFA4o2FRmNm48155AY03jqyy5IyzNw/formResponse?hl=en"

#define Employee_FR_not_first_time_form         @"https://docs.google.com/forms/d/e/1FAIpQLSdbAVrR5cBH4qQfDORAvBUPRloQRjj31o7QfJzTmw-nJ9-C9Q/viewform?hl=en"
#define Employee_FR_not_first_time_response     @"https://docs.google.com/forms/d/e/1FAIpQLSdbAVrR5cBH4qQfDORAvBUPRloQRjj31o7QfJzTmw-nJ9-C9Q/formResponse?hl=en"

#define Visitor_No_FR_form                      @"https://docs.google.com/forms/d/e/1FAIpQLSdOOdNQuh0c49I0mcKWJxfZL9ajzB6e7ku-YGe8JwhWgfLu4w/viewform?hl=en"
#define Visitor_No_FR_response                  @"https://docs.google.com/forms/d/e/1FAIpQLSdOOdNQuh0c49I0mcKWJxfZL9ajzB6e7ku-YGe8JwhWgfLu4w/formResponse?hl=en"

#define Employee_No_FR_form                     @"https://docs.google.com/forms/d/e/1FAIpQLSdOOdNQuh0c49I0mcKWJxfZL9ajzB6e7ku-YGe8JwhWgfLu4w/viewform?hl=en"
#define Employee_No_FR_response                 @"https://docs.google.com/forms/d/e/1FAIpQLSfsMbwp9yV5M_l9j_fYM38Ly2jOtkxG7sNqaf0wof7SZud1SA/formResponse?hl=en"

#define No_FR_No_Name_form                      @"https://docs.google.com/forms/d/e/1FAIpQLSdyS4TDoxKLUpvIKedww43qIc1Mudsc91LL0YvxCoafxi4Xpg/viewform?hl=en"
#define No_FR_No_Name_response                  @"https://docs.google.com/forms/d/e/1FAIpQLSdyS4TDoxKLUpvIKedww43qIc1Mudsc91LL0YvxCoafxi4Xpg/formResponse?hl=en"

///////////////////////////////////////////////////////////////////////
//                                   ROS                             //
///////////////////////////////////////////////////////////////////////

// ADD YOUR IP HERE:
#define IP_ROS_ROBOT            ((NSString*) @"Insert here")

// Example:
#define IP_ROS_ROBOT_example       ((NSString*) @"ws://192.168.30.121:9090")

#define CAMERA_UPDATE_SPEED     ((double)   0.5)

#endif /* constants_h */
