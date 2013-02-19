//
//  AppDelegate.h
//  testApp
//
//  Created by Ramiro Guerrero on 18/01/13.
//  Copyright (c) 2013 Ramiro Guerrero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

extern NSString *const SessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)openSession;
-(BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code;

@end
