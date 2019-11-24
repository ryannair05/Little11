#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

// Declaring our Variables that will be used throughout the program
static NSInteger statusBarStyle, screenRoundness, appswitcherRoundness, bottomInsetVersion;
static BOOL wantsHomeBarSB, wantsHomeBarLS, wantsKeyboardDock, wantsRoundedAppSwitcher, wantsReduceRows, wantsCCGrabber, wantsRoundedCorners, wantsPIP, wantsProudLock, wantsHideSBCC,wantsLSShortcuts, wantsBatteryPercent;

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

%hook CSQuickActionsView // Enables/Disables the lockscreen shortcuts 
- (BOOL)_prototypingAllowsButtons {
	return wantsLSShortcuts;
}
%end

// Fixes the toggles on the coversheet

@interface CSQuickActionsView : UIView
- (void)_layoutQuickActionButtons;
@end

%hook CSQuickActionsView
- (void)_layoutQuickActionButtons {
	%orig;
	for (UIView *subview in self.subviews) {
		if (subview.frame.origin.x < 50) {
			subview.frame = CGRectMake(46, subview.frame.origin.y - 90, 50, 50);
		} else {
			CGFloat _screenWidth = [UIScreen mainScreen].bounds.size.width;
			subview.frame = CGRectMake(_screenWidth - 96, subview.frame.origin.y - 90, 50, 50);
		}
        #pragma clang diagnostic ignored "-Wunused-value"
        [subview init];
	}
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

// Reduce reachability sensitivity.
%hook SBReachabilitySettings
- (void)setSystemWideSwipeDownHeight:(double) systemWideSwipeDownHeight {
    %orig(100);
}
%end

// All the hooks for the iPhone X statusbar.
%group StatusBarX
// Fix control center, it dosen't crash anymore on iOS 13 like it does on iOS 12 but this is still wanted
%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    return NSClassFromString(@"_UIStatusBarVisualProvider_Split58");
}
%end
%end

// All the hooks for the iPad statusbar.
%group StatusBariPad

@interface CCUIHeaderPocketView : UIView				
@end

%hook _UIStatusBarVisualProvider_iOS
+ (Class)class {
    if(screenRoundness >= 16) return NSClassFromString(@"_UIStatusBarVisualProvider_RoundedPad_ForcedCellular");
    return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
}
%end

// Fixes status bar glitch after closing control center
%hook CCUIHeaderPocketView
- (void)setFrame:(CGRect)frame {
    if(screenRoundness >= 16) %orig(CGRectSetY(frame, -20));
    else %orig(CGRectSetY(frame, -24));
}
%end
%end

// Hide the homebar on the coversheet
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

// Enables the floating dock + rounds the cards of the app switcher.
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

int applicationDidFinishLaunching;

// Allows you to use the non-X iPhone button combinations.
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

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    applicationDidFinishLaunching = 2;
    %orig;
}
%end

%hook SBPressGestureRecognizer
- (void)setAllowedPressTypes:(NSArray *)arg1 {
    NSArray * lockHome = @[@104, @101];
    NSArray * lockVol = @[@104, @102, @103];
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
- (id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
    return %orig(arg1,1);
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

// Adds the new bottom inset to the screen.
%group InsetX	

extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef);

typedef unsigned long long addr_t;

static addr_t step64(const uint8_t *buf, addr_t start, size_t length, uint32_t what, uint32_t mask) {
	addr_t end = start + length;
	while (start < end) {
		uint32_t x = *(uint32_t *)(buf + start);
		if ((x & mask) == what) {
			return start;
		}
		start += 4;
	}
	return 0;
}

static addr_t find_branch64(const uint8_t *buf, addr_t start, size_t length) {
	return step64(buf, start, length, 0x14000000, 0xFC000000);
}

static addr_t follow_branch64(const uint8_t *buf, addr_t branch) {
	long long w;
	w = *(uint32_t *)(buf + branch) & 0x3FFFFFF;
	w <<= 64 - 26;
	w >>= 64 - 26 - 2;
	return branch + w;
}

static CFPropertyListRef (*orig_MGCopyAnswer_internal)(CFStringRef property, uint32_t *outTypeCode);
CFPropertyListRef new_MGCopyAnswer_internal(CFStringRef property, uint32_t *outTypeCode) {
    CFPropertyListRef r = orig_MGCopyAnswer_internal(property, outTypeCode);
	#define k(string) CFEqual(property, CFSTR(string))
    NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (k("oPeik/9e8lQWMszEjbPzng")) {
        CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)r);
        CFRelease(r);
        CFNumberRef num;
        uint32_t deviceSubType = 0x984;
        num = CFNumberCreate(NULL, kCFNumberIntType, &deviceSubType);
        CFDictionarySetValue(copy, CFSTR("ArtworkDeviceSubType"), num);
        return copy;
    }  else if (k("8olRm6C1xqr7AJGpLRnpSw") && [bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        return (__bridge CFPropertyListRef)@YES;
    }
	return r;
}
%end

// Adds the old bottom inset to the screen.
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
%group PIP
extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
#define keyy(key_) CFEqual(key, CFSTR(key_))
    if (keyy("nVh/gwNpy7Jv1NOk00CMrw"))
        return wantsPIP;
    return %orig;
}
%end

// Adds the padlock to the lockscreen.
%group ProudLock

extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
#define keyyy(key_) CFEqual(key, CFSTR(key_))
    if (keyyy("z5G/N9jcMdgPm8UegLwbKg"))
        return YES;
    return %orig;
}

CGFloat offset = 0;

%hook SBFLockScreenDateViewController
- (void)loadView {
	if (%c(JPWeatherManager) != nil) {
		%orig;
		return;
	}
	CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
	if (screenWidth <= 320) {
		offset = 20;
	} else if (screenWidth <= 375) {
		offset = 35;
	} else if (screenWidth < 415) {
		offset = 28;
	}
	%orig;
}
%end 

%hook SBFLockScreenDateView
- (void)setFrame:(CGRect)frame {
    if(%c(JPWeatherManager) != nil) return;
    %orig(CGRectSetY(frame, frame.origin.y + offset));
}
%end

%hook NCNotificationListCollectionView
- (void)setFrame:(CGRect)frame {
	%orig(CGRectSetY(frame, frame.origin.y + offset));
}
%end

%hook SBDashBoardAdjunctListView
- (void)setFrame:(CGRect)frame {
	%orig(CGRectSetY(frame, frame.origin.y + offset));
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

// Fix the iPhone X status bar in instagram.
%group InstagramFix

@interface IGNavigationBar : UIView
@end

%hook UIStatusBar_Modern
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, -5));
}
%end

%hook IGNavigationBar
- (void)layoutSubviews {
    %orig;
    CGRect _frame = self.frame;
    _frame.origin.y = 20;
    self.frame = _frame;
}
%end
%end

// Fix the iPhone X status bar in Google Maps.
%group GMapsFix

%hook UIStatusBar_Modern
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, -10));
}
%end
%end

// Fix the iPhone X status bar in YouTube.
%group YTSBFix

%hook UIStatusBar_Modern
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, -7));
}
%end

%hook YTHeaderView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y + 10));
}
%end
%end

// Fix bottom bar in YouTube.
%group YTBBFix

BOOL isClassInHierarchy(Class cls)
{
    __block __weak BOOL (^weak_recursiveSearch)(UIView*, Class);
    BOOL (^recursiveSearch)(UIView*, Class);
    weak_recursiveSearch = recursiveSearch = ^(UIView* v, Class c){
        if ([v isKindOfClass:c])
            return YES;
        for (UIView* subV in v.subviews)
        {
            if (weak_recursiveSearch(subV, c))
                return YES;
        }
        return NO;
    };
    for (UIWindow* w in [UIApplication sharedApplication].windows)
    {
        if (recursiveSearch(w, cls))
            return YES;
    }
    return NO;
}

%hook YTPivotBarView
- (void)setFrame:(CGRect)frame {
    if(!isClassInHierarchy(%c(YTNGWatchCollectionView))) {
        %orig(CGRectSetY(frame, frame.origin.y - 21));
    }
}
%end

%hook YTNGWatchLayerView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, -21));
}
%end
%end

// Preferences.
static void loadPrefs() {
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
      //  wantsOriginalButtons =  [[prefs objectForKey:@"originalButtons"] boolValue];
        wantsRoundedCorners = [[prefs objectForKey:@"roundedCorners"] boolValue];
        wantsPIP = [[prefs objectForKey:@"PIP"] boolValue];
        wantsProudLock = [[prefs objectForKey:@"ProudLock"] boolValue];
        wantsHideSBCC = [[prefs objectForKey:@"HideSBCC"] boolValue];
        wantsLSShortcuts = [[prefs objectForKey:@"lsShortcutsEnabled"] boolValue];
	}
}

static void initPrefs() {
	NSString *path = @"/User/Library/Preferences/com.ryannair05.little11prefs.plist";
	NSString *pathDefault = @"/Library/PreferenceBundles/little11prefs.bundle/defaults.plist";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager copyItemAtPath:pathDefault toPath:path error:nil];
	}
}

%ctor {
    @autoreleasepool {
	    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.little11prefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	    initPrefs();
	    loadPrefs();
        if(statusBarStyle == 1) %init(StatusBariPad) 
	    else if(statusBarStyle == 2) {
            %init(StatusBarX);
            NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            if([bundleIdentifier isEqualToString:@"com.burbn.instagram"]) %init(InstagramFix);
            else if([bundleIdentifier isEqualToString:@"com.google.Maps"]) %init(GMapsFix);
            else if([bundleIdentifier isEqualToString:@"com.google.ios.youtube"]) %init(YTSBFix);
        }
        else wantsHideSBCC = YES;
	
	    if(bottomInsetVersion == 2) {
            MSImageRef libGestalt = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
            if (libGestalt) {
                void *MGCopyAnswerFn = MSFindSymbol(libGestalt, "_MGCopyAnswer");
                const uint8_t *MGCopyAnswer_ptr = (const uint8_t *)MGCopyAnswer;
                addr_t branch = find_branch64(MGCopyAnswer_ptr, 0, 8);
                addr_t branch_offset = follow_branch64(MGCopyAnswer_ptr, branch);
                MSHookFunction(((void *)((const uint8_t *)MGCopyAnswerFn + branch_offset)), (void *)new_MGCopyAnswer_internal, (void **)&orig_MGCopyAnswer_internal);
            }
            %init(InsetX);
        } else if(bottomInsetVersion == 1) %init(bottomInset);
        
        if(!wantsHomeBarSB) %init(hideHomeBarSB);
        if(!wantsHomeBarLS) %init(hideHomeBarLS);

        if(wantsHomeBarSB || bottomInsetVersion > 0) {
            NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            if([bundleIdentifier isEqualToString:@"com.apple.camera"]) %init(CameraFix);
            else if([bundleIdentifier isEqualToString:@"com.google.ios.youtube"]) %init(YTBBFix);
        }

        if(wantsKeyboardDock) %init(KeyboardDock);;
        
        if(wantsRoundedAppSwitcher) %init(roundedDock);
        %init(reduceRows);
        if(wantsCCGrabber) %init(ccGrabber);
      //  if(wantsOriginalButtons) 
        %init(originalButtons);
      //  else %init (xButtons);
        if(wantsRoundedCorners) %init(roundedCorners);
        %init(PIP);
        if(wantsHideSBCC) %init(HideSBCC);
        if(wantsBatteryPercent) %init(batteryPercent);
        if(wantsProudLock) %init(ProudLock);
        
        %init(_ungrouped);
    }
}
