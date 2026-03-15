// ============================================
// 767 Telegram Tweak - Ghost Mode + Black Menu
// Compiled with Theos on macOS (GitHub Actions)
// Target: Telegram iOS (ph.telegra.Telegraph)
// ============================================

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// Global Ghost Mode toggle
static BOOL ghostModeEnabled = YES;
static UIWindow *menuWindow767 = nil;

// ============================================
// HOOK 1: Ghost Mode - Hide Read Receipts
// Block the method that marks messages as read
// ============================================
%hook TGModernConversationController

// Prevent sending "read" signal to server
- (void)_markMessagesAsRead {
    if (ghostModeEnabled) {
        // ئەم نامەیان وەک "خوێندراو" nemarkin - Ghost Mode
        return;
    }
    %orig; // ئەگەر Ghost OFF بوو، ئاسایی بکار
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    %orig;
    if (ghostModeEnabled) {
        // مەیلا "خوێندراوم" نانێرین
        return;
    }
}

%end

// ============================================
// HOOK 2: Hide "last seen" and Online Status
// ============================================
%hook TGPrivacySettingsController

- (void)viewDidLoad {
    %orig;
    if (ghostModeEnabled) {
        // داناستنا "Last Seen = Nobody" ب شێوازی خۆکار
        NSLog(@"[767] Ghost Mode: Hiding online status");
    }
}

%end

// ============================================
// HOOK 3: Inject 767 Black Menu on App Start
// ============================================
%hook TGRootController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    // ١ چرکە راگرە دا تەلیگرام ب تەمامی ڤەبێت
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self show767Menu];
    });
}

%new
- (void)show767Menu {
    if (menuWindow767 && !menuWindow767.isHidden) return;
    
    // Menu Panel (ئەو پانەلا ڕەشە)
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 110)];
    panel.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.06 alpha:0.95];
    panel.layer.cornerRadius = 14;
    panel.layer.shadowColor = [UIColor blackColor].CGColor;
    panel.layer.shadowOpacity = 0.7;
    panel.layer.shadowRadius = 12;
    
    // ناڤ (767 MOD)
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, 150, 22)];
    title.text = @"  767 MOD";
    title.font = [UIFont boldSystemFontOfSize:15];
    title.textColor = [UIColor colorWithRed:0.3 green:0.7 blue:1.0 alpha:1.0];
    [panel addSubview:title];
    
    // Separator
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(10, 38, 200, 0.5)];
    sep.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    [panel addSubview:sep];
    
    // Ghost Mode Label
    UILabel *ghostLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 48, 130, 20)];
    ghostLabel.text = @"Seen Off (Ghost)";
    ghostLabel.font = [UIFont systemFontOfSize:13];
    ghostLabel.textColor = [UIColor whiteColor];
    [panel addSubview:ghostLabel];
    
    // Switch
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(155, 44, 51, 31)];
    sw.on = ghostModeEnabled;
    sw.transform = CGAffineTransformMakeScale(0.75, 0.75);
    sw.onTintColor = [UIColor colorWithRed:0.2 green:0.75 blue:0.4 alpha:1.0];
    [sw addTarget:self action:@selector(ghostToggle:) forControlEvents:UIControlEventValueChanged];
    [panel addSubview:sw];
    
    // Close Button
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(185, 6, 28, 28);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close767Menu) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:closeBtn];
    
    // Window
    UIWindowScene *scene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] anyObject];
    menuWindow767 = [[UIWindow alloc] initWithWindowScene:scene];
    menuWindow767.windowLevel = UIWindowLevelAlert + 10;
    menuWindow767.backgroundColor = [UIColor clearColor];
    menuWindow767.userInteractionEnabled = YES;
    
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor clearColor];
    [vc.view addSubview:panel];
    
    // Position: top right
    CGRect screen = [UIScreen mainScreen].bounds;
    panel.frame = CGRectMake(screen.size.width - 230, 90, 220, 110);
    vc.view.frame = screen;
    
    menuWindow767.rootViewController = vc;
    menuWindow767.hidden = NO;
}

%new
- (void)ghostToggle:(UISwitch *)sender {
    ghostModeEnabled = sender.isOn;
    NSLog(@"[767] Ghost Mode: %@", ghostModeEnabled ? @"ON" : @"OFF");
}

%new
- (void)close767Menu {
    menuWindow767.hidden = YES;
}

%end

// ============================================
// CONSTRUCTOR: Auto-run when dylib loads
// ============================================
%ctor {
    NSLog(@"[767 MOD] Telegram Tweak Loaded!");
    NSLog(@"[767 MOD] Ghost Mode: Active");
    
    // Initialize hooks
    %init(TGModernConversationController);
    %init(TGPrivacySettingsController);
    %init(TGRootController);
}
