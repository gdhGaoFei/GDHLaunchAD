//
//  AppDelegate.m
//  GDHLaunchADDemo
//
//  Created by 高得华 on 17/1/23.
//  Copyright © 2017年 GaoFei. All rights reserved.
//

#import "AppDelegate.h"
#import "GDHLaunchADViewController.h"
#import "ViewController.h"
#import "HomeWebViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self WZXLaunchView];
    [self.window makeKeyAndVisible];
    
    return YES;
}
- (void)WZXLaunchView{
    NSString *gifImageURL = @"http://img1.gamedog.cn/2013/06/03/43-130603140F30.gif";
    NSString *imageURL = @"http://img4.duitang.com/uploads/item/201410/24/20141024135636_t2854.thumb.700_0.jpeg";
    
    [GDHLaunchADViewController ShowGDHLaunchADFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) ImageURL:gifImageURL timeNumber:10 strokeColor:[UIColor redColor] lineWidth:2 backgroundColor:[UIColor blueColor] textColor:[UIColor whiteColor] showSkipType:GDHLaunchADSkipShowTypeAnimation options:GDHWebImageOnlyLoad LaunchAdCallBack:^(UIImage *image, NSString *imageURL) {
        /// 广告加载结束
        NSLog(@"%@ %@",image,imageURL);
    } ImageClick:^(GDHLaunchADViewController *GDHLaunchADVC) {
        
        /// 点击广告
        
        //2.在webview中打开
        HomeWebViewController *VC = [[HomeWebViewController alloc] init];
        VC.urlStr = @"http://www.jianshu.com/p/7205047eadf7";
        VC.title = @"广告";
        VC.AppDelegateSele= -1;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
        [GDHLaunchADVC presentViewController:nav animated:YES completion:nil];
        
    } CompletePlay:^{
        //广告展示完成回调,设置window根控制器
        ViewController *vc = [[ViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nav;
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
