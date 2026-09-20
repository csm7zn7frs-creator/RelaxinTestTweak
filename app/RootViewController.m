#import "RootViewController.h"

#if __has_include(<roothide.h>)
#include <roothide.h>
#else
static inline NSString *jbroot(NSString *path) { return path; }
#endif

static NSString *const kPrefsID = @"com.gf.relaxintest";
static NSString *const kEnabledKey = @"tweakEnabled";

@interface RootViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, strong) UISwitch *tweakSwitch;
@property (nonatomic, strong) UILabel *injectLabel;
@end

@implementation RootViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"RelaxinTest";
	self.view.backgroundColor = [UIColor colorWithRed:0.07 green:0.08 blue:0.12 alpha:1.0];
	self.navigationController.navigationBar.prefersLargeTitles = YES;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.tintColor = [UIColor systemTealColor];

	self.scrollView = [[UIScrollView alloc] init];
	self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.scrollView];

	self.stack = [[UIStackView alloc] init];
	self.stack.axis = UILayoutConstraintAxisVertical;
	self.stack.spacing = 12;
	self.stack.translatesAutoresizingMaskIntoConstraints = NO;
	[self.scrollView addSubview:self.stack];

	[NSLayoutConstraint activateConstraints:@[
		[self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
		[self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
		[self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
		[self.stack.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor constant:16],
		[self.stack.leadingAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.leadingAnchor constant:16],
		[self.stack.trailingAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.trailingAnchor constant:-16],
		[self.stack.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor constant:-24],
	]];

	[self.stack addArrangedSubview:[self cardTitle:@"这是什么"
		body:@"给 Relaxin 隐根（RootHide）用的最小测试插件。\n能打开这个 App = 越狱 App 安装成功。\n重春板后弹窗 = SpringBoard 注入成功。"]];

	[self.stack addArrangedSubview:[self statusCard]];
	[self.stack addArrangedSubview:[self toggleCard]];
	[self.stack addArrangedSubview:[self injectCard]];

	UIButton *alertButton = [self actionButton:@"弹出 App 内测试窗口"];
	[alertButton addTarget:self action:@selector(showLocalAlert) forControlEvents:UIControlEventTouchUpInside];
	[self.stack addArrangedSubview:alertButton];

	UIButton *refreshButton = [self actionButton:@"重新检测环境"];
	refreshButton.backgroundColor = [UIColor colorWithWhite:0.18 alpha:1];
	[refreshButton addTarget:self action:@selector(reloadStatus) forControlEvents:UIControlEventTouchUpInside];
	[self.stack addArrangedSubview:refreshButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self reloadStatus];
}

- (UIView *)cardTitle:(NSString *)title body:(NSString *)body {
	UIView *card = [self card];
	UILabel *t = [self label:title size:17 weight:UIFontWeightSemibold color:[UIColor whiteColor]];
	UILabel *b = [self label:body size:14 weight:UIFontWeightRegular color:[UIColor colorWithWhite:0.78 alpha:1]];
	b.numberOfLines = 0;
	UIStackView *inner = [[UIStackView alloc] initWithArrangedSubviews:@[t, b]];
	inner.axis = UILayoutConstraintAxisVertical;
	inner.spacing = 6;
	inner.translatesAutoresizingMaskIntoConstraints = NO;
	[card addSubview:inner];
	[NSLayoutConstraint activateConstraints:@[
		[inner.topAnchor constraintEqualToAnchor:card.topAnchor constant:14],
		[inner.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:14],
		[inner.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-14],
		[inner.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-14],
	]];
	return card;
}

- (UIView *)statusCard {
	NSMutableString *text = [NSMutableString string];
	[text appendFormat:@"系统：%@ %@\n", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
	[text appendFormat:@"设备：%@\n", [UIDevice currentDevice].model];
	[text appendFormat:@"jbroot(/)：%@\n", jbroot(@"/") ?: @"(无)"];
	[text appendFormat:@"ElleKit：%@\n", [self exists:jbroot(@"/usr/lib/libellekit.dylib")] ? @"找到" : @"未找到"];
	[text appendFormat:@"Sileo：%@\n", [self exists:jbroot(@"/Applications/Sileo.app")] ? @"已安装" : @"未找到"];
	[text appendFormat:@"uicache：%@", [self exists:jbroot(@"/usr/bin/uicache")] ? @"可用" : @"未找到"];
	return [self cardTitle:@"环境检测" body:text];
}

- (UIView *)toggleCard {
	UIView *card = [self card];
	UILabel *title = [self label:@"允许 SpringBoard 弹窗" size:17 weight:UIFontWeightSemibold color:[UIColor whiteColor]];
	UILabel *body = [self label:@"打开后，下次重春板会弹出“注入成功”。用来确认插件 dylib 注入是否生效。" size:13 weight:UIFontWeightRegular color:[UIColor colorWithWhite:0.75 alpha:1]];
	body.numberOfLines = 0;
	self.tweakSwitch = [[UISwitch alloc] init];
	self.tweakSwitch.on = [self tweakEnabled];
	[self.tweakSwitch addTarget:self action:@selector(toggleChanged) forControlEvents:UIControlEventValueChanged];

	UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[title, self.tweakSwitch]];
	row.axis = UILayoutConstraintAxisHorizontal;
	row.alignment = UIStackViewAlignmentCenter;

	UIStackView *inner = [[UIStackView alloc] initWithArrangedSubviews:@[row, body]];
	inner.axis = UILayoutConstraintAxisVertical;
	inner.spacing = 8;
	inner.translatesAutoresizingMaskIntoConstraints = NO;
	[card addSubview:inner];
	[NSLayoutConstraint activateConstraints:@[
		[inner.topAnchor constraintEqualToAnchor:card.topAnchor constant:14],
		[inner.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:14],
		[inner.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-14],
		[inner.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-14],
	]];
	return card;
}

- (UIView *)injectCard {
	UIView *card = [self card];
	UILabel *title = [self label:@"注入状态" size:17 weight:UIFontWeightSemibold color:[UIColor whiteColor]];
	self.injectLabel = [self label:@"" size:14 weight:UIFontWeightRegular color:[UIColor colorWithWhite:0.78 alpha:1]];
	self.injectLabel.numberOfLines = 0;
	UIStackView *inner = [[UIStackView alloc] initWithArrangedSubviews:@[title, self.injectLabel]];
	inner.axis = UILayoutConstraintAxisVertical;
	inner.spacing = 6;
	inner.translatesAutoresizingMaskIntoConstraints = NO;
	[card addSubview:inner];
	[NSLayoutConstraint activateConstraints:@[
		[inner.topAnchor constraintEqualToAnchor:card.topAnchor constant:14],
		[inner.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:14],
		[inner.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-14],
		[inner.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-14],
	]];
	return card;
}

- (UIView *)card {
	UIView *card = [[UIView alloc] init];
	card.backgroundColor = [UIColor colorWithWhite:0.14 alpha:1];
	card.layer.cornerRadius = 14;
	return card;
}

- (UILabel *)label:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight color:(UIColor *)color {
	UILabel *label = [[UILabel alloc] init];
	label.text = text;
	label.font = [UIFont systemFontOfSize:size weight:weight];
	label.textColor = color;
	return label;
}

- (UIButton *)actionButton:(NSString *)title {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setTitle:title forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	button.backgroundColor = [UIColor systemTealColor];
	button.layer.cornerRadius = 12;
	button.contentEdgeInsets = UIEdgeInsetsMake(14, 12, 14, 12);
	return button;
}

- (BOOL)exists:(NSString *)path {
	return path.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (BOOL)tweakEnabled {
	Boolean exists = false;
	Boolean value = CFPreferencesGetAppBooleanValue((__bridge CFStringRef)kEnabledKey, (__bridge CFStringRef)kPrefsID, &exists);
	return exists ? value : YES;
}

- (void)toggleChanged {
	CFPreferencesSetAppValue((__bridge CFStringRef)kEnabledKey, self.tweakSwitch.on ? kCFBooleanTrue : kCFBooleanFalse, (__bridge CFStringRef)kPrefsID);
	CFPreferencesAppSynchronize((__bridge CFStringRef)kPrefsID);
}

- (void)reloadStatus {
	self.tweakSwitch.on = [self tweakEnabled];
	Boolean exists = false;
	Boolean injected = CFPreferencesGetAppBooleanValue(CFSTR("injected"), (__bridge CFStringRef)kPrefsID, &exists) && exists;
	self.injectLabel.text = injected
		? @"SpringBoard 已报告注入成功（本机默认域有标记）。"
		: @"还没收到注入标记。装好后请：Sileo 重春板 → 等 2–3 秒看弹窗 → 再打开本 App。";
}

- (void)showLocalAlert {
	UIAlertController *alert = [UIAlertController
		alertControllerWithTitle:@"App 运行正常"
		message:@"主屏幕图标和 UI 已经起来了。这只证明 App 能跑，不证明 SpringBoard 注入。注入请看重春板弹窗。"
		preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

@end
