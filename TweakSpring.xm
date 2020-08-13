#import <UIKit/UIKit.h>
#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

NSInteger statusBarStyle, screenRoundness, appswitcherRoundness;
BOOL enabled, wantsHomeBarSB, wantsHomeBarLS, wantsRoundedAppSwitcher, wantsReduceRows, wantsRoundedCorners, wantsXButtons;
BOOL wantsCCGrabber, wantsProudLock, wantsHideSBCC,wantsLSShortcuts, wantsBatteryPercent, wantsiPadDock;
BOOL wantsiPadMultitasking;

%hook BSPlatform
- (NSInteger)homeButtonType {
	return 2;
}
%end

@interface CSQuickActionsView : UIView
- (UIEdgeInsets)_buttonOutsets;
@property (nonatomic, retain) UIControl *flashlightButton; 
@property (nonatomic, retain) UIControl *cameraButton;
@end

%hook CSQuickActionsView
- (BOOL)_prototypingAllowsButtons {
	return wantsLSShortcuts;
}
- (void)_layoutQuickActionButtons {
    CGRect const screenBounds = [UIScreen mainScreen].bounds;
    int const y = screenBounds.size.height - 90 - [self _buttonOutsets].top;

    [self flashlightButton].frame = CGRectMake(46, y, 50, 50);
    [self cameraButton].frame = CGRectMake(screenBounds.size.width - 96, y, 50, 50);
}
%end

%group HideSBCC
%hook CCUIModularControlCenterOverlayViewController
- (CCUIHeaderPocketView*)overlayHeaderView {
    return nil;
}
%end
%end

%group batteryPercent
%hook _UIBatteryView 
-(BOOL)_currentlyShowsPercentage {
    return YES;
}
-(BOOL)_shouldShowBolt {
    return NO;
}
%end 

%hook _UIStatusBarStringView  
- (void)setText:(NSString *)text {
	if ([text containsString:@"%"]) 
      return;
    else 
       %orig(text);
}     
%end
%end

%hook SBReachabilitySettings
- (void)setSystemWideSwipeDownHeight:(double) systemWideSwipeDownHeight { 
    %orig(100);
}
%end

%group StatusBarX
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return %c(_UIStatusBarVisualProvider_Split58);
}
%end

%hook SBIconListGridLayoutConfiguration
- (UIEdgeInsets)portraitLayoutInsets { 
    UIEdgeInsets const x = %orig;
    NSUInteger const locationRows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
    if (locationRows == 3 || statusBarStyle == 3) {
        return x;
    }
    return UIEdgeInsetsMake(x.top+10, x.left, x.bottom, x.right);
}
%end
%end

%group StatusBarXSpacing
%hook _UIStatusBarVisualProvider_Split58
+(CGSize)notchSize {
    CGSize const orig = %orig;
    return CGSizeMake(orig.width, 18);
}
+(double)height {
    return 20;
}
%end
%end

%group StatusBariPad
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    if (wantsRoundedCorners && screenRoundness > 15) return %c(_UIStatusBarVisualProvider_RoundedPad_ForcedCellular);
    return %c(_UIStatusBarVisualProvider_Pad_ForcedCellular);
}
%end

%hook CCUIHeaderPocketView
- (void)setFrame:(CGRect)frame {
    if (wantsRoundedCorners && screenRoundness > 15) %orig(CGRectSetY(frame, -20));
    else %orig(CGRectSetY(frame, -24));
}
%end
%end

%hook SBFHomeGrabberSettings
- (BOOL)isEnabled {
    return wantsHomeBarSB;
} 
%end

%group hideHomeBarLS
%hook CSTeachableMomentsContainerView
-(void)setHomeAffordanceContainerView:(UIView *)arg1{
    return;
}
%end
%end

%group completelyRemoveHomeBar
%hook MTLumaDodgePillSettings
- (void)setHeight:(double)arg1 {
	arg1 = 0;
	%orig;
}
%end
%end

%group roundedDock
%hook UITraitCollection
- (CGFloat)displayCornerRadius {
	return appswitcherRoundness;
}
%end
%end

%hook SBIconListView
-(unsigned long long)iconRowsForCurrentOrientation{
    int const orig = %orig;
    if (orig < 4) return orig;
	return orig - wantsReduceRows + wantsiPadDock;
}
%end

%group ccGrabber

@interface CSTeachableMomentsContainerView : UIView
@property(retain, nonatomic) UIView *controlCenterGrabberView;
@property(retain, nonatomic) UIView *controlCenterGrabberEffectContainerView;
@property (retain, nonatomic) UIImageView * controlCenterGlyphView; 
@end

%hook CSTeachableMomentsContainerView
- (void)_layoutControlCenterGrabberAndGlyph  {
    %orig;
    if (statusBarStyle == 2) {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 73,36,46,2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0,0,46,2.5);
        self.controlCenterGlyphView.frame = CGRectMake(315,45,16.6,19.3);
    } else {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 75.5,24,60.5,2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0,0,60.5,2.5);
        self.controlCenterGlyphView.frame = CGRectMake(320,35,16.6,19.3);
    }
}
%end
%end

// Allows you to use the non-X iPhone button combinations. For some reason only works on some devices - Just as the iPhone X Combinations
%group originalButtons
%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
    return %orig(1, arg2);
}
%end

%hook SBHomeHardwareButtonActions
- (id)initWitHomeButtonType:(long long)arg1 {
    return %orig(1);
}
%end

int applicationDidFinishLaunching = 2;

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray *lockHome = @[@104, @101];
    NSArray *lockVol = @[@104, @102, @103];
    if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2) {
        %orig(lockHome);
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
    if (applicationDidFinishLaunching == 1) {
        applicationDidFinishLaunching--;
        return;
    }
    %orig;
}
%end

%hook SBHomeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
    return %orig(arg1,1,arg3,arg4);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
    return %orig(arg1,1);
}
%end

%hook SBLockHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 buttonActions:(id)arg6 homeButtonType:(long long)arg7 createGestures:(_Bool)arg8 {
    return %orig(arg1,arg2,arg3,arg4,arg5,arg6,1,arg8);
}
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 homeButtonType:(long long)arg6 {
    return %orig(arg1,arg2,arg3,arg4,arg5,1);
}
%end

%hook SBVolumeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 homeButtonType:(long long)arg3 {
    return %orig(arg1,arg2,1);
}
%end
%end

%group roundedCorners

@interface _UIRootWindow : UIView
@property (setter=_setContinuousCornerRadius:, nonatomic) double _continuousCornerRadius;
@end

%hook _UIRootWindow
-(void)layoutSubviews {
    %orig;
    self.clipsToBounds = YES;
    self._continuousCornerRadius = screenRoundness;
    return;
}
%end

%hook SBReachabilityBackgroundView
- (double)_displayCornerRadius {
    return screenRoundness;
}
%end
%end 

%group ProudLock
%hook SBUIPasscodeBiometricResource
-(BOOL)hasPearlSupport {
    return YES;
}
-(BOOL)hasMesaSupport {
    return NO;
}
%end

@interface SBDashBoardMesaUnlockBehaviorConfiguration : NSObject
- (BOOL)_isAccessibilityRestingUnlockPreferenceEnabled;
@end

@interface SBDashBoardBiometricUnlockController : NSObject
@end

@interface SBLockScreenController : NSObject
+ (id)sharedInstance;
- (BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2;
@end

CGFloat offset = 0;

%hook SBFLockScreenDateView
-(id)initWithFrame:(CGRect)arg1 {
    CGFloat const screenWidth = UIScreen.mainScreen.bounds.size.width;

	if (screenWidth <= 320) {
		offset = 20;
	} else if (screenWidth <= 375) {
		offset = 35;
	} else if (screenWidth <= 414) {
		offset = 28;
	}

    return %orig;
}
- (void)layoutSubviews {
	%orig;

	UIView* timeView = MSHookIvar<UIView*>(self, "_timeLabel");
	UIView* dateSubtitleView = MSHookIvar<UIView*>(self, "_dateSubtitleView");
	UIView* customSubtitleView = MSHookIvar<UIView*>(self, "_customSubtitleView");
	
	[timeView setFrame:CGRectSetY(timeView.frame, timeView.frame.origin.y + offset)];
	[dateSubtitleView setFrame:CGRectSetY(dateSubtitleView.frame, dateSubtitleView.frame.origin.y + offset)];
	[customSubtitleView setFrame:CGRectSetY(customSubtitleView.frame, customSubtitleView.frame.origin.y + offset)];
}
%end

%hook SBDashBoardLockScreenEnvironment
- (void)handleBiometricEvent:(unsigned long long)arg1 {
	%orig;

	if (arg1 == 4) {
		SBDashBoardBiometricUnlockController* biometricUnlockController = MSHookIvar<SBDashBoardBiometricUnlockController*>(self, "_biometricUnlockController");
		SBDashBoardMesaUnlockBehaviorConfiguration* unlockBehavior = MSHookIvar<SBDashBoardMesaUnlockBehaviorConfiguration*>(biometricUnlockController, "_biometricUnlockBehaviorConfiguration");
		
		if ([unlockBehavior _isAccessibilityRestingUnlockPreferenceEnabled]) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[[%c(SBLockScreenManager) sharedInstance] _finishUIUnlockFromSource:12 withOptions:nil];
			});
		}
	}
}
%end

%hook BSUICAPackageView
- (id)initWithPackageName:(id)packageName inBundle:(id)arg2 {
	if (![packageName hasPrefix:@"lock"]) return %orig;
	
	packageName = [packageName stringByAppendingString:@"-896h"];

	return %orig(packageName, [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/SpringBoardUIServices.framework"]);
}
%end

%hook CSCombinedListViewController
- (UIEdgeInsets)_listViewDefaultContentInsets {
    UIEdgeInsets orig = %orig;

    orig.top += offset;
    return orig;
}
%end

%hook SBUIBiometricResource
- (id)init {
	id r = %orig;
	
	MSHookIvar<BOOL>(r, "_hasMesaHardware") = NO;
	MSHookIvar<BOOL>(r, "_hasPearlHardware") = YES;
	
	return r;
}
%end

@interface WGWidgetGroupViewController : UIViewController
@end

%hook WGWidgetGroupViewController
- (void)updateViewConstraints {
    %orig;
	[self.view setFrame:CGRectSetY(self.view.frame, self.view.frame.origin.y + (offset/2))];
}
%end
%end

%group iPadDock
%hook SBFloatingDockController
+ (BOOL)isFloatingDockSupported {
	return YES;
}
%end
%end

%group iPadMultitasking

%hook SBApplication
- (BOOL)isMedusaCapable {
    return YES;
}
%end

%hook SBPlatformController
-(long long)medusaCapabilities {
	return 2;
}
%end

%hook SBMainWorkspace
-(BOOL)isMedusaEnabled {
	return YES;
}
%end
%end 

// Preferences.
void loadPrefs() {
     @autoreleasepool {

        NSDictionary const *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little11prefs.plist"];

        if (prefs) {
            enabled = [[prefs objectForKey:@"enabled"] boolValue];
            statusBarStyle = [[prefs objectForKey:@"statusBarStyle"] integerValue];
            screenRoundness = [[prefs objectForKey:@"screenRoundness"] integerValue];
            appswitcherRoundness = [[prefs objectForKey:@"appswitcherRoundness"] integerValue];
            wantsHomeBarSB = [[prefs objectForKey:@"homeBarSB"] boolValue];
            wantsHomeBarLS = [[prefs objectForKey:@"homeBarLS"] boolValue];
            wantsRoundedAppSwitcher =[[prefs objectForKey:@"roundedAppSwitcher"] boolValue];
            wantsReduceRows =  [[prefs objectForKey:@"reduceRows"] boolValue];
            wantsCCGrabber = [[prefs objectForKey:@"ccGrabber"] boolValue];
            wantsBatteryPercent = [[prefs objectForKey:@"batteryPercent"] boolValue];
            wantsiPadDock = [[prefs objectForKey:@"iPadDock"] boolValue];
            wantsiPadMultitasking = wantsiPadDock ? [[prefs objectForKey:@"iPadMultitasking"] boolValue] : NO;
            wantsXButtons =  [[prefs objectForKey:@"xButtons"] boolValue];
            wantsRoundedCorners = [[prefs objectForKey:@"roundedCorners"] boolValue];
            wantsProudLock = [[prefs objectForKey:@"ProudLock"] boolValue];
            wantsHideSBCC = [[prefs objectForKey:@"HideSBCC"] boolValue];
            wantsLSShortcuts = [[prefs objectForKey:@"lsShortcutsEnabled"] boolValue];
        }
        else {
            NSString *path = @"/System/Library/PrivateFrameworks/CameraUI.framework/CameraUI-d4x-n104.strings";
            NSString *pathDefault = @"/Library/PreferenceBundles/little11prefs.bundle/CameraUI-d4x-n104.strings";
            NSFileManager const *fileManager = [NSFileManager defaultManager];

            if (![fileManager fileExistsAtPath:path]) {
                [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
            }

            path = @"/User/Library/Preferences/com.ryannair05.little11prefs.plist";
            pathDefault = @"/Library/PreferenceBundles/little11prefs.bundle/defaults.plist";

            if (![fileManager fileExistsAtPath:path]) {
                [fileManager copyItemAtPath:pathDefault toPath:path error:nil];
                loadPrefs();
            }
        }
    }
}

%ctor {
    @autoreleasepool {

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.little11prefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        loadPrefs();

        if (enabled) {

            if (statusBarStyle == 1) %init(StatusBariPad);
            else if (statusBarStyle > 1) {
                %init(StatusBarX);
                if (statusBarStyle == 3)
                    %init(StatusBarXSpacing);
            } 
            else wantsHideSBCC = YES;

            if (!wantsHomeBarLS) {
                %init(hideHomeBarLS);
                if (!wantsHomeBarSB) %init(completelyRemoveHomeBar);
            }

            if (wantsCCGrabber) %init(ccGrabber);
            if (wantsBatteryPercent) %init(batteryPercent);
            if (!wantsXButtons) %init(originalButtons);
            if (wantsHideSBCC) %init(HideSBCC);
            if (wantsRoundedAppSwitcher) %init(roundedDock);
            if (wantsRoundedCorners) %init(roundedCorners);
            if (wantsiPadDock) %init(iPadDock);
            if (wantsiPadMultitasking) %init(iPadMultitasking)
            if (wantsProudLock) %init(ProudLock);

            %init;
        }
    }
}