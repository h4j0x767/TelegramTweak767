#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <substrate.h>
#import <dlfcn.h>

// --- Fix for Compiler Error ---
@interface UIWindow (h767)
- (void)show767Menu;
- (void)toggleMainPanel;
- (void)powerChanged:(UISlider *)sender;
@end

// Settings
static float shotPowerMultiplier = 1.0f;
static UIWindow *menuWindow767 = nil;
static UILabel *powerLabel = nil;

// Function pointer for the hook
static float (*orig_GetShotPower)(void* player) = NULL;

// The Hook Implementation
float hook_GetShotPower(void* player) {
    if (orig_GetShotPower) {
        float power = orig_GetShotPower(player);
        return power * shotPowerMultiplier;
    }
    return 1.0f;
}

// ============================================
// HOOK: Inject 767 Black Menu on UIWindow
// ============================================
%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    
    // Inject only once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self show767Menu];
        });
    });
}

%new
- (void)show767Menu {
    if (menuWindow767 != nil) return;
    
    CGRect screen = [UIScreen mainScreen].bounds;
    
    // Window Creation
    menuWindow767 = [[UIWindow alloc] initWithFrame:screen];
    menuWindow767.windowLevel = UIWindowLevelAlert + 500;
    menuWindow767.backgroundColor = [UIColor clearColor];
    menuWindow767.userInteractionEnabled = YES;
    
    // Small Black Button (Floating)
    UIButton *tinyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tinyBtn.frame = CGRectMake(screen.size.width - 60, 150, 50, 50);
    tinyBtn.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
    tinyBtn.layer.cornerRadius = 25;
    tinyBtn.layer.borderWidth = 1;
    tinyBtn.layer.borderColor = [UIColor cyanColor].CGColor;
    [tinyBtn setTitle:@"767" forState:UIControlStateNormal];
    tinyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [tinyBtn addTarget:self action:@selector(toggleMainPanel) forControlEvents:UIControlEventTouchUpInside];
    
    // Main Panel (Hidden by default)
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(screen.size.width/2 - 125, 120, 250, 180)];
    panel.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.06 alpha:0.95];
    panel.layer.cornerRadius = 20;
    panel.layer.borderWidth = 1;
    panel.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:1.0].CGColor;
    panel.tag = 767;
    panel.hidden = YES;
    
    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 250, 25)];
    title.text = @"SUPER KICK 767";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textColor = [UIColor cyanColor];
    [panel addSubview:title];
    
    // Slider Label
    powerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 210, 20)];
    powerLabel.text = @"Shot Power: 1x";
    powerLabel.textColor = [UIColor whiteColor];
    powerLabel.font = [UIFont systemFontOfSize:14];
    [panel addSubview:powerLabel];
    
    // Slider
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 90, 210, 30)];
    slider.minimumValue = 1.0f;
    slider.maximumValue = 500.0f;
    slider.value = 1.0f;
    slider.minimumTrackTintColor = [UIColor cyanColor];
    [slider addTarget:self action:@selector(powerChanged:) forControlEvents:UIControlEventValueChanged];
    [panel addSubview:slider];
    
    // Close Button
    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(20, 135, 210, 35);
    close.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    close.layer.cornerRadius = 10;
    [close setTitle:@"Close Menu" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(toggleMainPanel) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:close];

    UIViewController *vc = [[UIViewController alloc] init];
    [vc.view addSubview:tinyBtn];
    [vc.view addSubview:panel];
    
    menuWindow767.rootViewController = vc;
    menuWindow767.hidden = NO;
}

%new
- (void)toggleMainPanel {
    UIView *panel = [menuWindow767 viewWithTag:767];
    panel.hidden = !panel.isHidden;
}

%new
- (void)powerChanged:(UISlider *)sender {
    shotPowerMultiplier = sender.value;
    powerLabel.text = [NSString stringWithFormat:@"Shot Power: %.0fx", shotPowerMultiplier];
}

%end

// ============================================
// CONSTRUCTOR: Hook C++ Functions
// ============================================
%ctor {
    NSLog(@"[767] Super Goal Hack Loading...");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        void* handle = NULL;
        while (!handle) {
            handle = dlopen("@executable_path/Frameworks/UnityFramework.framework/UnityFramework", RTLD_NOW);
            if (!handle) handle = dlopen("UnityFramework", RTLD_NOW);
            usleep(500000); // 0.5s
        }
        
        NSLog(@"[767] UnityFramework found, hooking...");
        
        void* sym = dlsym(handle, "__ZN8SL_utils12GetShotPowerE7PointerI6PlayerE");
        if (sym) {
            MSHookFunction(sym, (void *)&hook_GetShotPower, (void **)&orig_GetShotPower);
            NSLog(@"[767] GetShotPower Hooked!");
        } else {
            NSLog(@"[767] Symbol GetShotPower NOT found!");
        }
    });
}
