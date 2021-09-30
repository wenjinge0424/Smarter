//
//  AppDelegate.h
//  PagaYa
//
//  Created by developer on 28/05/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PFFacebookUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    AVAudioPlayer *myAudioPlayer;
}
@property (nonatomic, retain) AVAudioPlayer *myAudioPlayer;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *rootNavigationViewController;

@end

