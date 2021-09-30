//
//  AppDelegate.m
//  PagaYa
//
//  Created by developer on 28/05/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import "StudentQuestionViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize myAudioPlayer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    application.statusBarHidden = YES;
    
    
    // Parse init
    [PFUser enableAutomaticUser];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"ec62fba4-8bb7-407b-84bf-c71d4302bb0f";
        configuration.clientKey = @"6d581e0f-de99-4085-b432-353589ca646b";
        configuration.server = @"https://parse.brainyapps.com:20021/parse";
    }]];
    [PFUser enableRevocableSessionInBackground];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    PFInstallation *currentInstall = [PFInstallation currentInstallation];
    if (currentInstall) {
        currentInstall.badge = 0;
        [currentInstall saveInBackground];
    }
    // Facebook
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    [GIDSignIn sharedInstance].clientID = @"";
    
    // Push Notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    
    // audioplayer init
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    myAudioPlayer.numberOfLoops = 1;
    myAudioPlayer.volume = 1;
    [AVAudioSession.sharedInstance overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                          options:options];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    NSInteger pushType = [[userInfo objectForKey:@"type"] integerValue];
    PFUser *me = [PFUser currentUser];
    NSInteger userType = [me[PARSE_USER_TYPE] integerValue];
    if (pushType == NOTIFICATION_ACCEPTED && userType == USER_TYPE_PARENT){
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_SYNC_ACCEPTED object:nil];
    } else {
        if (pushType == NOTIFICATION_PARENT_SYNC && userType == USER_TYPE_STUDENT){
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_SYNC_PENDING object:nil];
        }
    }
    
    
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1;
    } else { // active status
        application.applicationIconBadgeNumber = 0;
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
    
    if (pushType == NOTIFICATION_START_STUDY && userType == USER_TYPE_STUDENT){
        NSDictionary *data = [userInfo objectForKey:@"data"];
        [[StudentQuestionViewController getInstance] startTest:data];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
