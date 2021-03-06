//
//  AppDelegate.m
//  Blocstagram
//
//  Created by Melissa Boring on 10/12/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "AppDelegate.h"
#import "ImagesTableViewController.h"
#import "LoginViewController.h"
#import "DataSource.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    UINavigationController *navVC = [[UINavigationController alloc] init];
    
    if (![DataSource sharedInstance].accessToken)
        {
    
            LoginViewController *loginVC = [[LoginViewController alloc] init];

            [navVC setViewControllers:@[loginVC] animated:YES];

            //start app within login view controller and switch to images table controller once an access token is obtained
            [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
                
                ImagesTableViewController *imagesVC = [[ImagesTableViewController alloc] init];
                
                [navVC setViewControllers:@[imagesVC] animated:YES];
            }];
        }
        else
        {
            ImagesTableViewController *imagesVC = [[ImagesTableViewController alloc] init];
            [navVC setViewControllers:@[imagesVC] animated:YES];
        }
    
    self.window.rootViewController = navVC;
    
    [self.window makeKeyAndVisible];
    return YES;
}


@end
