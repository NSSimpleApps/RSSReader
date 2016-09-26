//
//  AppDelegate.m
//  RSSReader
//
//  Created by NSSimpleApps on 31.05.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkReachabilityManager.h"

@interface AppDelegate ()

@property (strong, nonatomic) AFNetworkReachabilityManager *reachabilityManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Создаем reachabilityManager, который будет мониторить наличие сети.
    
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    __weak typeof(self) weakSelf = self;
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Network is unreachable" message:@"Cache is in using" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Close"
                                     style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                         
                                         [alertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
            [alertController addAction:action];
            
            [strongSelf.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }];
    [self.reachabilityManager startMonitoring];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [self.reachabilityManager stopMonitoring];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [self.reachabilityManager startMonitoring];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
