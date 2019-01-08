//
//  AppDelegate.m
//  ZYWChart
//
//  Created by zdqh on 2016/12/17.
//  Copyright © 2016年 com.zdqh. All rights reserved.
//

#import "AppDelegate.h"
#import "FHHFPSIndicator.h"
#import "WYLoginVC.h"
#import "ICEQuickOrder.h"
#import "ICEQuote.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize  userName;
@synthesize  passWord;
@synthesize  userID;


@synthesize  loginFlag;
@synthesize  iceQuote;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    //[NSThread sleepForTimeInterval:3.0];
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.loginFlag = 0;
#if defined(DEBUG) || defined(_DEBUG)
    [[FHHFPSIndicator sharedFPSIndicator] show];
#endif

#if NpTradeTest
    //LoginVC1* Controller = [[LoginVC1 alloc]init];
#else
    //LoginVC* Controller = [[LoginVC alloc]init];
    WYLoginVC* Controller = [[WYLoginVC alloc]init];
    //Controller.view.frame = self.window.bounds;
#endif
    //Controller.view.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:Controller];
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(self.isEable) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //锁屏后执行这一条
    NSLog(@"application did enterBBBBBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
- (void)applicationWillEnterForeground:(UIApplication *)application {

    NSLog(@"application will enterForeground");
    //2s后发送心跳 并重新连接
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //非首次登录
            if(self.loginFlag){
                @try{
                    ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
                    ICEQuote *quote = [ICEQuote shareInstance];
                    [quote HeartBeat:self.strAcc];
                    [quickOrder HeartBeat:self.strCmd];
                }
                @catch(ICEException* s){
                    NSLog(@"heart beat exception ==== %@",s);
                    ICEQuickOrder *quickOrder = [ICEQuickOrder shareInstance];
                    ICEQuote *quote = [ICEQuote shareInstance];
                    [quickOrder Connect2ICE];
                    [quote Connect2Quote];
                }
            }
        });
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Did Become Active======");

}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Will Terminate=========");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
