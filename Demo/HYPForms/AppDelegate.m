#import "AppDelegate.h"

#import "HYPSampleCollectionViewController.h"
#import "HYPFormBackgroundView.h"
#import "HYPFormsLayout.h"

#import "UIColor+ANDYHex.h"
#import "NSObject+HYPTesting.h"
#import "UIColor+HYPFormsColors.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    if ([NSObject isUnitTesting]) return YES;
#endif

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSDictionary *dictionary = @{@"address" : @"Burger Park 667",
                                 @"end_date" : @"2017-10-31 23:00:00 +00:00",
                                 @"first_name" : @"Ola",
                                 @"last_name" : @"Nordman",
                                 @"start_date" : @"2014-10-31 23:00:00 +00:00"
                                 };

    HYPSampleCollectionViewController *sampleController = [[HYPSampleCollectionViewController alloc] initWithDictionary:dictionary];

    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:sampleController];
    controller.view.tintColor = [UIColor HYPFormsControlsBlue];
    controller.navigationBarHidden = YES;

    self.window.rootViewController = controller;

    [self.window makeKeyAndVisible];

    return YES;
}

@end
