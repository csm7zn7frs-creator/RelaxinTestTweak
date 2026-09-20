#import "AppDelegate.h"
#import "RootViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.backgroundColor = [UIColor blackColor];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] init]];
	[self.window makeKeyAndVisible];
	return YES;
}

@end
