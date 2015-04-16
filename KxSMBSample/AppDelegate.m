//
//  AppDelegate.m
//  SMBFileReader
//
//  Created by Shota Takai on 2015/03/20.
//

#import "AppDelegate.h"
// :: Other ::
#import "SplitViewController.h"


@interface AppDelegate()
@end

@implementation AppDelegate

#pragma mark - ViewController LifeCycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // windowのrootViewControllerとしてSplitViewControllerを設定
    self.window.rootViewController = [[SplitViewController alloc] init];
    
    // 内容を表示する
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
