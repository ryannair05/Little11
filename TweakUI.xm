#import <UIKit/UIKit.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>
#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

NSInteger statusBarStyle;
BOOL enabled, wantsKeyboardDock,wants11Camera, wantsbottomInset;
BOOL disableGestures = NO, wantsGesturesDisabledWhenKeyboard, wantsPIP;
BOOL wantsDeviceSpoofing, wantsCompatabilityMode;

%group ForceDefaultKeyboard
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets const orig = %orig;    
    return UIEdgeInsetsMake(orig.top, 0, 0, 0);
}
%end
%end

%group StatusBarX
%hook UIScrollView
- (UIEdgeInsets)adjustedContentInset {
	UIEdgeInsets orig = %orig;

    if (orig.top == 64) orig.top = 88; 
    else if (orig.top == 32) orig.top = 0;
    else if (orig.top == 128) orig.top = 152;

    return orig;
}
%end
%end

%group KeyboardDock
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    if (!(%c(BarmojiCollectionView) || %c(DockXServer)))
         orig.bottom = 46;
	else if (orig.left == 75)  {
        orig.left = 0;
        orig.right = 0;
    }
    return orig;
}
%end

%hook UIKeyboardDockView
- (CGRect)bounds {
    CGRect const bounds = %orig;
    if (%c(BarmojiCollectionView) || %c(DockXServer)) 
        return bounds;

    return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height + 15);
}
%end
%end

%group PIP
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
#define keyy(key_) CFEqual(key, CFSTR(key_))
    if (keyy("nVh/gwNpy7Jv1NOk00CMrw"))
        return YES;
    return %orig;
}
%end

%group iPhone11Cam
%hook CAMCaptureCapabilities 
-(BOOL)isCTMSupported {
    return YES;
}
%end

%hook CAMViewfinderViewController 
-(BOOL)_wantsHDRControlsVisible{
    return NO;
}
%end

%hook CAMViewfinderViewController 
-(BOOL)_shouldUseZoomControlInsteadOfSlider {
    return YES;
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

%group disableGesturesWhenKeyboard // iOS 13.3 and below
%hook SBFluidSwitcherGestureManager
-(void)grabberTongueBeganPulling:(id)arg1 withDistance:(double)arg2 andVelocity:(double)arg3  {
    if (!disableGestures)
        %orig;
}
%end
%end

%group newDisableGesturesWhenKeyboard // iOS 13.4 and up
%hook SBFluidSwitcherGestureManager
- (void)grabberTongueBeganPulling:(id)arg1 withDistance:(double)arg2 andVelocity:(double)arg3 andGesture:(id)arg4  {
    if (!disableGestures)
        %orig;
}
%end
%end

%group BoundsHack
%hookf(int, sysctl, const int *name, u_int namelen, void *oldp, size_t *oldlenp, const void *newp, size_t newlen) {
	if (namelen == 2 && name[0] == CTL_HW && name[1] == HW_MACHINE && oldp) {
        int const ret = %orig;
        const char *mechine1 = "iPhone12,1";
        strncpy((char*)oldp, mechine1, strlen(mechine1));
        return ret;
    } else {
        return %orig;
    }
}

%hookf(int, sysctlbyname, const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
	if (strcmp(name, "hw.machine") == 0) {
        int ret = %orig;
        if (oldp) {
            const char *mechine1 = "iPhone12,1";
            strcpy((char *)oldp, mechine1);
        }
        return ret;
    } else {
        return %orig;
    }
}

%hookf(int, uname, struct utsname *value) {
	int const ret = %orig;
	NSString *utsmachine = @"iPhone12,1";
    const char *utsnameCh = utsmachine.UTF8String; 
    strcpy(value->machine, utsnameCh);
    return ret;
}
%end

%group CompatabilityMode
%hook UIScreen
- (CGRect)bounds {
	CGRect bounds = %orig;
    bounds.size.height > bounds.size.width ? bounds.size.height = 812 : bounds.size.width = 812;
	return bounds;
}
%end
%end 

%hook UIWindow
- (UIEdgeInsets)safeAreaInsets {
	UIEdgeInsets orig = %orig;
    orig.bottom = wantsbottomInset ? 20 : 0;
	return orig;
}
%end

%group bottominsetfix // AWE = TikTok, TFN = Twitter, YT = Youtube
%hook AWETabBar
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y + 40));
}
%end

%hook AWEFeedTableView
- (void)setFrame:(CGRect)frame {
	%orig(CGRectMake(frame.origin.x,frame.origin.y,frame.size.width,frame.size.height + 40));
}
%end

%hook TFNNavigationBarOverlayView  
- (void)setFrame:(CGRect)frame {
    %orig(CGRectMake(frame.origin.x,frame.origin.y,frame.size.width,frame.size.height + 6));
}
%end

%hook YTPivotBarView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y - 40));
}
%end
%hook YTAppView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectMake(frame.origin.x,frame.origin.y,frame.size.width,frame.size.height + 40));
}
%end

%hook YTNGWatchLayerView
-(CGRect)miniBarFrame {
    CGRect const frame = %orig;
	return CGRectSetY(frame, frame.origin.y - 40);
}
%end
%end

%group YoutubeStatusBarXSpacingFix
%hook YTHeaderContentComboView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y - 20));
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
            wantsGesturesDisabledWhenKeyboard = [[prefs objectForKey:@"noGesturesForKeyboard"] boolValue];
            wantsPIP = [[prefs objectForKey:@"PIP"] boolValue];
            wants11Camera = [[prefs objectForKey:@"11Camera"] boolValue];
            
            NSString const *mainIdentifier = [NSBundle mainBundle].bundleIdentifier;
            NSDictionary const *appSettings = [prefs objectForKey:mainIdentifier];
    
            if (appSettings) {
                wantsKeyboardDock = [appSettings objectForKey:@"keyboardDock"] ? [[appSettings objectForKey:@"keyboardDock"] boolValue] : [[prefs objectForKey:@"keyboardDock"] boolValue];
                wantsbottomInset = [appSettings objectForKey:@"bottomInset"] ? [[appSettings objectForKey:@"bottomInset"] boolValue] : [[prefs objectForKey:@"bottomInset"] boolValue];
                wantsDeviceSpoofing = [appSettings objectForKey:@"deviceSpoofing"] ? [[appSettings objectForKey:@"deviceSpoofing"] boolValue] : [[prefs objectForKey:@"deviceSpoofing"] boolValue];
                wantsCompatabilityMode = [appSettings objectForKey:@"compatabilityMode"] ? [[appSettings objectForKey:@"compatabilityMode"] boolValue] : [[prefs objectForKey:@"compatabilityMode"] boolValue];
            } else {
                wantsKeyboardDock =  [[prefs objectForKey:@"keyboardDock"] boolValue];
                wantsbottomInset = [[prefs objectForKey:@"bottomInset"] boolValue];
                wantsDeviceSpoofing = [[prefs objectForKey:@"deviceSpoofing"] boolValue];
                wantsCompatabilityMode = [[prefs objectForKey:@"compatabilityMode"] boolValue];
            }
        }
    }
}

%ctor {
    @autoreleasepool {

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.little11prefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        loadPrefs();

        if (enabled) {

            bool const isApp = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"];

            if (isApp) {

                NSString* const bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

                if ([bundleIdentifier containsString:@"com.apple"]) {
                    if (wants11Camera && [bundleIdentifier isEqualToString:@"com.apple.camera"])
                        %init(iPhone11Cam);
                    wantsCompatabilityMode = NO;
                    wantsDeviceSpoofing = NO;
                    if (wantsbottomInset) %init(CameraFix);
                }
                else if ([bundleIdentifier isEqualToString:@"com.facebook.Facebook"] && (statusBarStyle == 1 || statusBarStyle == 2)) {
                    wantsbottomInset = YES;
                }
                else if (wantsbottomInset || statusBarStyle > 1) {
                    if ([bundleIdentifier isEqualToString:@"com.google.ios.youtube"]) {
                        if (wantsbottomInset || statusBarStyle == 2)
                            wantsCompatabilityMode = YES;
                        else
                            %init(YoutubeStatusBarXSpacingFix);
                    }
                    else if ([bundleIdentifier isEqualToString:@"com.burbn.instagram"]) {
                        wantsCompatabilityMode = NO;
                        wantsDeviceSpoofing = statusBarStyle == 2;
                    }
                    else if ([bundleIdentifier isEqualToString:@"com.zhiliaoapp.musically"]) {
                        wantsCompatabilityMode = NO;
                        wantsDeviceSpoofing = YES;
                        statusBarStyle = 2;
                    }

                    if (statusBarStyle == 2) {
                        %init(StatusBarX);
                        if (!wantsbottomInset)
                            %init(bottominsetfix);
                    }

                    if (wantsCompatabilityMode) %init(CompatabilityMode);
                    if (wantsDeviceSpoofing) %init(BoundsHack);
                }
            }

            if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/KeyboardPlus.dylib"]) {

                if (wantsKeyboardDock) %init(KeyboardDock);
                else %init(ForceDefaultKeyboard);

                if (wantsGesturesDisabledWhenKeyboard) {
                    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *n){
                            disableGestures = true;
                        }];
                    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *n){
                            disableGestures = false;
                        }];
                    if (@available(iOS 13.4, *)) 
                        %init(newDisableGesturesWhenKeyboard);
                    else
                        %init(disableGesturesWhenKeyboard);
                }
            }

            if (wantsPIP) %init(PIP);
            %init;
        }
    }
}