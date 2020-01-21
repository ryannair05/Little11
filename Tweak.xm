#import <UIKit/UIKit.h>
#include <sys/utsname.h>
#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

// Declaring our Variables that will be used throughout the program
NSInteger statusBarStyle, screenRoundness, appswitcherRoundness, bottomInsetVersion;
BOOL wantsHomeBarSB, wantsHomeBarLS, wantsKeyboardDock, wantsRoundedAppSwitcher, wantsReduceRows, wantsCCGrabber, wantsRoundedCorners, wantsPIP, wantsProudLock, wantsHideSBCC,wantsLSShortcuts, wantsBatteryPercent, wants11Camera;

// Telling the iPhone that we want the fluid gestures 

%hook BSPlatform
- (NSInteger)homeButtonType {
	return 2;
}
%end

@interface CSTeachableMomentsContainerView : UIView
@property(retain, nonatomic) UIView *controlCenterGrabberView;
@property(retain, nonatomic) UIView *controlCenterGrabberEffectContainerView;
@property (retain, nonatomic) UIImageView * controlCenterGlyphView; 
@end

// Forces the default keyboard when the iPhone X keyboard is disabled and the new bottom inset is enabled.
%group ForceDefaultKeyboard
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    orig.bottom = 0;
    return orig;
}
%end
%end

// Enables & Fixes the toggles on the lockscreen.
@interface UICoverSheetButton : UIControl
@end

@interface SBFTouchPassThroughView : UIView
@property (nonatomic, retain) UICoverSheetButton *flashlightButton;
@property (nonatomic, retain) UICoverSheetButton *cameraButton;
@end

@interface CSQuickActionsView : UIView
- (UIEdgeInsets)_buttonOutsets;
@end

%hook CSQuickActionsView
- (BOOL)_prototypingAllowsButtons {
	return wantsLSShortcuts;
}
- (void)_layoutQuickActionButtons {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UIEdgeInsets insets = [self _buttonOutsets];

    ((SBFTouchPassThroughView *)self).flashlightButton.frame = CGRectMake(46, screenBounds.size.height - 90 - insets.top, 50, 50);
	((SBFTouchPassThroughView *)self).cameraButton.frame = CGRectMake(screenBounds.size.width - 96, screenBounds.size.height - 90 - insets.top, 50, 50);
}
%end

// Fix the default status bar from glitching by hiding the status bar in the CC.
%group HideSBCC
%hook CCUIStatusBarStyleSnapshot
-(BOOL)isHidden {
    return YES;
}
%end

%hook CCUIOverlayStatusBarPresentationProvider
- (void)_addHeaderContentTransformAnimationToBatch:(id)arg1 transitionState:(id)arg2 {
    %orig(nil, arg2);
}
%end
%end

%group batteryPercent
%hook _UIBatteryView 
-(void)setShowsPercentage:(BOOL)arg1 {
    return %orig(YES);
}
%end 
%end

// Reduce reachability sensitivity.
%hook SBReachabilitySettings
- (void)setSystemWideSwipeDownHeight:(double) systemWideSwipeDownHeight {
    %orig(100);
}
%end

// All the hooks for the iPhone X statusbar.
%group StatusBarX
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}
%end
%end

// All the hooks for the iPad statusbar.
%group StatusBariPad
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    if(screenRoundness > 15) return NSClassFromString(@"_UIStatusBarVisualProvider_RoundedPad_ForcedCellular");
    return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
}
%end

// Fixes status bar glitch after closing control center
%hook CCUIHeaderPocketView
- (void)setFrame:(CGRect)frame {
    if(screenRoundness > 15) %orig(CGRectSetY(frame, -20));
    else %orig(CGRectSetY(frame, -24));
}
%end
%end

// Hide the homebar 
%hook SBFHomeGrabberSettings
- (BOOL)isEnabled {
    return wantsHomeBarSB;
} 
%end

// Hide the homebar on the lockscreen
%group hideHomeBarLS
%hook CSTeachableMomentsContainerView
-(void)setHomeAffordanceContainerView:(UIView *)arg1{
    return;
}
%end
%end

// iPhone X keyboard.
%group KeyboardDock
// Automatically adjusts the sized depending if Barmoji is installed or not.
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    NSClassFromString(@"BarmojiCollectionView") ? orig.bottom = 80 : orig.bottom = 46;
    return orig;
}
%end

// Moves the emoji and dictation icon on the keyboard. Automatically adjust the location depending if Barmoji is installed or not.
%hook UIKeyboardDockView
- (CGRect)bounds {
    CGRect bounds = %orig;
    NSClassFromString(@"BarmojiCollectionView")? bounds.origin.y = 2 : bounds.size.height += 15;
    return bounds;
}
%end
%end

// Enables the rounded dock of the iPhone X + rounds up the cards of the app switcher.
%group roundedDock

%hook UITraitCollection
- (CGFloat)displayCornerRadius {
	return appswitcherRoundness;
}
%end
%end

// Reduces the number of rows of icons on the home screen by 1.
%group reduceRows
%hook SBIconListView
-(unsigned long long)iconRowsForCurrentOrientation{
    if (%orig<4) return %orig;
	return %orig-wantsReduceRows;
}
%end
%end

// Move the control center grabber on the coversheet to a place where it is visible
%group ccGrabber

%hook CSTeachableMomentsContainerView
- (void)layoutSubviews {
    %orig;
    if(statusBarStyle == 2) {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 73,36,46,2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0,0,46,2.5);
        self.controlCenterGlyphView.frame = CGRectMake(315,45,16.6,19.3);
    } else if(statusBarStyle == 1) {
        self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 75.5,24,60.5,2.5);
        self.controlCenterGrabberView.frame = CGRectMake(0,0,60.5,2.5);
        self.controlCenterGlyphView.frame = CGRectMake(320,35,16.6,19.3);
    }
}
%end
%end

// Allows you to use the non-X iPhone button combinations.
%group originalButtons
%hook SBLockHardwareButtonActions
- (id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
    return %orig(1, arg2);
}
%end

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray * lockHome = @[@104, @101];
    NSArray * lockVol = @[@104, @102, @103];
    if ([arg1 isEqual:lockVol]) {
        return %orig(lockHome);
    }
    %orig;
}
%end

%hook SBClickGestureRecognizer
- (void)addShortcutWithPressTypes:(id)arg1 {
    return;
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

%hook SBVolumeHardwareButton
- (id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 homeButtonType:(long long)arg3 {
    return %orig(arg1,arg2,1);
}
%end
%end

// System-wide rounded screen corners.
%group roundedCorners

@interface _UIRootWindow : UIView
@property (setter=_setContinuousCornerRadius:, nonatomic) double _continuousCornerRadius;
@end

%hook _UIRootWindow
-(void)layoutSubviews {
    %orig;
    self._continuousCornerRadius = screenRoundness;
    self.clipsToBounds = YES;
    return;
}
%end
%end 

// Adds the bottom inset to the screen.
%group InsetX	

CFPropertyListRef (*orig_MGCopyAnswer_internal)();
CFPropertyListRef new_MGCopyAnswer_internal(CFStringRef property) {
    CFPropertyListRef r = orig_MGCopyAnswer_internal();
	#define k(string) CFEqual(property, CFSTR(string))
    NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (k("oPeik/9e8lQWMszEjbPzng")) {
        CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)r);
        CFRelease(r);
        uint32_t deviceSubType = 0x984;
        CFNumberRef num = CFNumberCreate(NULL, kCFNumberIntType, &deviceSubType);
        CFDictionarySetValue(copy, CFSTR("ArtworkDeviceSubType"), num);
        return copy;
    }  else if (k("8olRm6C1xqr7AJGpLRnpSw") && [bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        return (__bridge CFPropertyListRef)@YES;
    }
	return r;
}
%end

// Adds the bottom inset to the screen.
%group bottomInset			
%hook UIApplicationSceneSettings		
- (UIEdgeInsets)safeAreaInsetsLandscapeLeft {		
    UIEdgeInsets _insets = %orig;		
    _insets.bottom = 21;		
    return _insets;		
}		
- (UIEdgeInsets)safeAreaInsetsLandscapeRight {		
    UIEdgeInsets _insets = %orig;		
    _insets.bottom = 21;		
    return _insets;		
}		
- (UIEdgeInsets)safeAreaInsetsPortrait {		
    UIEdgeInsets _insets = %orig;		
    _insets.bottom = 21;
    return _insets;		
}				
 %end		
 %end

// Enables PiP in video player.
%group MobileGestalt
%hookf(Boolean, "_MGGetBoolAnswer", CFStringRef key) {
#define keyy(key_) CFEqual(key, CFSTR(key_))
    if (keyy("nVh/gwNpy7Jv1NOk00CMrw"))
        return wantsPIP;
    else if (keyy("z5G/N9jcMdgPm8UegLwbKg")) 
        return wantsProudLock;
    return %orig;
}
%end

// Adds the padlock to the lockscreen.
%group ProudLock
%hook SBUIPasscodeBiometricResource
-(BOOL)hasPearlSupport {
    return YES;
}
-(BOOL)hasMesaSupport {
    return NO;
}
%end
%end

%group iPhone11Cam
%hook CAMCaptureCapabilities 
-(BOOL)isCTMSupported {
    return YES;
}
%end
%hook CAMCaptureCapabilities
-(BOOL)devicesupportsCTM {
    return YES;
}
%end
%hook CAMDynamicShutterControl 
-(BOOL)_shouldShortPressOnTouchDown {
    return YES;
}
%end 
%hook CAMViewfinderViewController 
-(BOOL)_wantsHDRControlsVisible{
    return NO;
}
%end 
%end

// Adds a bottom inset to the camera app.
%group CameraFix
%hook CAMBottomBar 
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y -40));
}
%end

%hook CAMZoomControl
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y -30));
}
%end
%end

// Fix status bar in instagram.

%group InstagramFix

@interface IGNavigationBar : UINavigationBar
@end

%hook IGNavigationBar
- (void)layoutSubviews {    
    %orig;
    CGRect _frame = self.frame;
    _frame.origin.y = 20;
    self.frame = _frame;
}
%end
%end

%group TikTokFix
%end

// Fix status bar in YouTube.
%group YTFix
%end

%group bottominsetfix
%end 

// Preferences.
 void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little11prefs.plist"];
	if (prefs) {
		statusBarStyle = [[prefs objectForKey:@"statusBarStyle"] integerValue];
        screenRoundness = [[prefs objectForKey:@"screenRoundness"] integerValue];
        appswitcherRoundness = [[prefs objectForKey:@"appswitcherRoundness"] integerValue];
        bottomInsetVersion = [[prefs objectForKey:@"bottomInsetVersion"] integerValue];
        wantsHomeBarSB = [[prefs objectForKey:@"homeBarSB"] boolValue];
        wantsHomeBarLS = [[prefs objectForKey:@"homeBarLS"] boolValue];
        wantsKeyboardDock =  [[prefs objectForKey:@"keyboardDock"] boolValue];
        wantsRoundedAppSwitcher =[[prefs objectForKey:@"roundedAppSwitcher"] boolValue];
        wantsReduceRows =  [[prefs objectForKey:@"reduceRows"] boolValue];
        wantsCCGrabber = [[prefs objectForKey:@"ccGrabber"] boolValue];
        wantsBatteryPercent = [[prefs objectForKey:@"batteryPercent"] boolValue];
        wantsRoundedCorners = [[prefs objectForKey:@"roundedCorners"] boolValue];
        wantsPIP = [[prefs objectForKey:@"PIP"] boolValue];
        wantsProudLock = [[prefs objectForKey:@"ProudLock"] boolValue];
        wantsHideSBCC = [[prefs objectForKey:@"HideSBCC"] boolValue];
        wantsLSShortcuts = [[prefs objectForKey:@"lsShortcutsEnabled"] boolValue];
        wants11Camera = [[prefs objectForKey:@"11Camera"] boolValue];
	}
}

 void initPrefs() {
	NSString *path = @"/User/Library/Preferences/com.ryannair05.little11prefs.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/little11prefs.bundle/defaults.plist";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}
}

 void cameraPrefs() {
}

%ctor {
    @autoreleasepool {
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.little11prefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	    initPrefs();
	    loadPrefs();
        NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        if((statusBarStyle != 0 || bottomInsetVersion == 2) && ([bundleIdentifier isEqualToString:@"com.burbn.instagram"])) {
            %init(InstagramFix);
        }
        if(statusBarStyle == 1) %init(StatusBariPad)      
	    else if(statusBarStyle == 2) %init(StatusBarX);
        else wantsHideSBCC = YES;
	
	    if(bottomInsetVersion == 2) {
            MSImageRef libGestalt = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
            if (libGestalt) {
                void *MGCopyAnswerFn = MSFindSymbol(libGestalt, "_MGCopyAnswer");
                MSHookFunction((void *)((const uint8_t *)MGCopyAnswerFn + 8), (void *)new_MGCopyAnswer_internal, (void **)&orig_MGCopyAnswer_internal);
            }
            %init(InsetX);
        } else if(bottomInsetVersion == 1) %init(bottomInset);
        
        if(!wantsHomeBarLS) %init(hideHomeBarLS);

        if(bottomInsetVersion > 0 || statusBarStyle == 2) {
            if([bundleIdentifier isEqualToString:@"com.zhiliaoapp.musically"]) %init(TikTokFix);
            else if ([bundleIdentifier isEqualToString:@"com.google.ios.youtube"]) %init(YTFix);
            if(bottomInsetVersion > 0) {
                 if([bundleIdentifier isEqualToString:@"com.apple.camera"] && !wants11Camera) %init(CameraFix);
            }
            else %init(bottominsetfix);
        }

        if([bundleIdentifier isEqualToString:@"com.apple.camera"] && wants11Camera)  {
            cameraPrefs();
            %init(iPhone11Cam);
        }

        if(wantsKeyboardDock) %init(KeyboardDock);
        else %init(ForceDefaultKeyboard);
        
        if(wantsRoundedAppSwitcher) %init(roundedDock);
        %init(reduceRows);
        if(wantsCCGrabber) %init(ccGrabber);
        %init(originalButtons);
        if(wantsRoundedCorners) %init(roundedCorners);
        %init(MobileGestalt);
        if(wantsHideSBCC) %init(HideSBCC);
        if(wantsBatteryPercent) %init(batteryPercent);
        if(wantsProudLock) %init(ProudLock);
        %init(_ungrouped);
    }
}
