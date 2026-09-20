#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *const kPrefsID = @"com.gf.relaxintest";
static NSString *const kEnabledKey = @"tweakEnabled";
static BOOL TweakEnabled(void) {
	Boolean keyExists = false;
	Boolean value = CFPreferencesGetAppBooleanValue((__bridge CFStringRef)kEnabledKey, (__bridge CFStringRef)kPrefsID, &keyExists);
	if (!keyExists) {
		return YES;
	}
	return value;
}

static void ShowInjectedAlert(void) {
	if (!TweakEnabled()) {
		return;
	}

	CFPreferencesSetAppValue(CFSTR("injected"), kCFBooleanTrue, (__bridge CFStringRef)kPrefsID);
	CFPreferencesAppSynchronize((__bridge CFStringRef)kPrefsID);

	UIAlertController *alert = [UIAlertController
		alertControllerWithTitle:@"RelaxinTest"
		message:@"SpringBoard 注入成功。\n插件已在 iOS 17.1.1 / Relaxin 环境跑起来。"
		preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];

	UIWindow *window = nil;
	for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
		if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
			for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
				if (candidate.isKeyWindow) {
					window = candidate;
					break;
				}
			}
		}
	}
	if (!window) {
		window = [UIApplication sharedApplication].windows.firstObject;
	}

	UIViewController *host = window.rootViewController;
	while (host.presentedViewController) {
		host = host.presentedViewController;
	}
	[host presentViewController:alert animated:YES completion:nil];
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
	%orig;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		ShowInjectedAlert();
	});
}

%end
