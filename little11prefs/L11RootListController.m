#include "L11RootListController.h"

#if __cplusplus
extern "C" {
#endif

    CFSetRef SBSCopyDisplayIdentifiers();
    NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);

#if __cplusplus
}
#endif

OBWelcomeController *welcomeController;

@implementation L11RootListController

@synthesize respringButton;

- (instancetype)init {
    self = [super init];

    if (self) {
        self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(respring:)];
        self.navigationItem.rightBarButtonItem = self.respringButton;
        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"Little11";
        [self.navigationItem.titleView addSubview:self.titleLabel];
    
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/little11prefs.bundle/icon@3x.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 0.0;
        [self.navigationItem.titleView addSubview:self.iconView];

        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
        headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/little11prefs.bundle/Banner.png"];
        headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.headerView addSubview:headerImageView];
    
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor],
            [headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor],
            [headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor],
            [headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor],
        ]];
    }

    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat const offsetY = scrollView.contentOffset.y;

    if (offsetY > 500) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }
}

- (NSArray *)specifiers {

	if (_specifiers == nil) {
		NSMutableArray *testingSpecs = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];
                
        [testingSpecs addObjectsFromArray:[self appSpecifiers]];
        
        _specifiers = testingSpecs;

        self.savedSpecifiers = [[NSMutableDictionary alloc] init];
        
        for (PSSpecifier *specifier in [self specifiers]) {
			if ([specifier propertyForKey:@"id"]) {
				[self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
		    }
		}

        NSDictionary const *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little11prefs.plist"];

        BOOL firstTime;

        if ([prefs objectForKey:@"firstTime"]) {
            firstTime = [[prefs objectForKey:@"firstTime"] boolValue];
        }
        else
            firstTime = YES;
            
        if (firstTime) {

            welcomeController = [[OBWelcomeController alloc] initWithTitle:@"Welcome to Little11" detailText:@"Little11 Brings iPhone 11 Gestures and Features to all devices!" icon:[UIImage systemImageNamed:@"gear"]];

            [welcomeController addBulletedListItemWithTitle:@"The Tweak" description:@"The iPhone X Gestures should be available on all devices, and so Little11 brings these fluid gestures to your device." image:[UIImage systemImageNamed:@"1.circle.fill"]];
            [welcomeController addBulletedListItemWithTitle:@"App Support" description:@"The majority of apps work with Little11 without an issue. For the exceptions, I'm doing my best to fix them though sometimes it can prove to be a challenge. Turning on or off the compatibility mode and/or device spoofing settings may improve or worsen certain apps. " image:[UIImage systemImageNamed:@"2.circle.fill"]];
            [welcomeController addBulletedListItemWithTitle:@"Support" description:@"Little11 is made to be the best possible, but there are still some issues unfortunately. To report issues and for support I can be contacted over Email, Discord, Twitter, Reddit, and Github." image:[UIImage systemImageNamed:@"3.circle.fill"]];
            [welcomeController addBulletedListItemWithTitle:@"Open Source" description:@"Little11 is open source and can be found on Github. Feel free to check out the code anytime and even make a pull request." image:[UIImage systemImageNamed:@"4.circle.fill"]];

            OBBoldTrayButton* continueButton = [OBBoldTrayButton buttonWithType:1];
            [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
            [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
            [continueButton setClipsToBounds:YES];
            [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
            [continueButton.layer setCornerRadius:19]; 
            [welcomeController.buttonTray addButton:continueButton];
            
            welcomeController.buttonTray.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
            
            UIVisualEffectView *effectWelcomeView = [[UIVisualEffectView alloc] initWithFrame:welcomeController.viewIfLoaded.bounds];
            
            effectWelcomeView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
            
            [welcomeController.viewIfLoaded insertSubview:effectWelcomeView atIndex:0];       

            welcomeController.viewIfLoaded.backgroundColor = [UIColor clearColor];

            [welcomeController.buttonTray addCaptionText:@"Thank you for your using Little11!"];

            welcomeController.modalPresentationStyle = UIModalPresentationPageSheet;
            welcomeController.modalInPresentation = YES;
            welcomeController.view.tintColor = [UIColor systemBlueColor];
            [self presentViewController:welcomeController animated:YES completion:nil];
        }
    }
	return _specifiers;
}

-(void)dismissWelcomeController { 
    [welcomeController dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableDictionary const *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little11prefs.plist"];

    [prefs setValue:[NSNumber numberWithBool:NO] forKey:@"firstTime"]; 

    [prefs writeToFile:@"/var/mobile/Library/Preferences/com.ryannair05.little11prefs.plist" atomically:YES]; 
}

-(void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little11prefs.plist"];

    BOOL hasStatusBarOrInset = NO;
    
    if (([[prefs objectForKey:@"iPadDock"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"iPadMultitasking"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcherNoDock"]] animated:YES];
    }
    else {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcher"]] animated:YES];
    }

    if (([[prefs objectForKey:@"statusBarStyle"] integerValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"HideSBCC"]] animated:YES];
    }
    else if  (([[prefs objectForKey:@"statusBarStyle"] integerValue]) > 1) {
        hasStatusBarOrInset = YES;
    }
    if (([[prefs objectForKey:@"bottomInset"] boolValue]) == 1) {
        hasStatusBarOrInset = YES;
    }

    if (([[prefs objectForKey:@"roundedAppSwitcher"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] animated:YES];
    }

    if (([[prefs objectForKey:@"roundedCorners"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"screenRoundness"]] animated:YES];
    }

    if (!hasStatusBarOrInset){
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"deviceSpoofing"]] animated:YES];
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/KeyboardPlus.dylib"]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardDock"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"noGesturesForKeyboard"]] animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(void)reloadSpecifiers {
    [super reloadSpecifiers];

    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little11prefs.plist"];

    BOOL hasStatusBarOrInset = NO;
    
    if (([[prefs objectForKey:@"iPadDock"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"iPadMultitasking"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcherNoDock"]] animated:NO];
    }
    else {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcher"]] animated:NO];
    }

    if (([[prefs objectForKey:@"statusBarStyle"] integerValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"HideSBCC"]] animated:NO];
    }
    else if  (([[prefs objectForKey:@"statusBarStyle"] integerValue]) > 1) {
        hasStatusBarOrInset = YES;
    }
    if (([[prefs objectForKey:@"bottomInset"] boolValue]) == 1) {
        hasStatusBarOrInset = YES;
    }

    if (([[prefs objectForKey:@"roundedAppSwitcher"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] animated:NO];
    }

    if (([[prefs objectForKey:@"roundedCorners"] boolValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"screenRoundness"]] animated:NO];
    }

    if (!hasStatusBarOrInset){
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"deviceSpoofing"]] animated:NO];
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/KeyboardPlus.dylib"]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"keyboardDock"]] animated:NO];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"noGesturesForKeyboard"]] animated:YES];
    }
}

-(NSMutableArray*)appSpecifiers {
    NSMutableArray *specifiers = [NSMutableArray array];

    NSArray *displayIdentifiers = [(__bridge NSSet *)SBSCopyDisplayIdentifiers() allObjects];

    NSMutableDictionary *apps = [NSMutableDictionary new];
    for (NSString *appIdentifier in displayIdentifiers) {
        NSString *appName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(appIdentifier);
        if (appName) {
            [apps setObject:appName forKey:appIdentifier];
        }
    }
    OrderedDictionary *dataSourceUser = (OrderedDictionary*)[apps copy];
    dataSourceUser = [self trimDataSource:dataSourceUser];
    dataSourceUser = [self sortedDictionary:dataSourceUser];
    
    PSSpecifier* groupSpecifier = [PSSpecifier groupSpecifierWithName:@"Per-app Customization:"];
    [specifiers addObject:groupSpecifier];
    
    for (NSString *bundleIdentifier in dataSourceUser.allKeys) {
        NSString *displayName = dataSourceUser[bundleIdentifier];
        
        PSSpecifier *spe = [PSSpecifier preferenceSpecifierNamed:displayName target:self set:nil get:@selector(getIsWidgetSetForSpecifier:) detail:[L11AppSettingsController class] cell:PSLinkListCell edit:nil];
        [spe setProperty:@"IBKWidgetSettingsController" forKey:@"detail"];
        [spe setProperty:@YES forKey:@"isController"];
        [spe setProperty:@YES forKey:@"enabled"];
        [spe setProperty:bundleIdentifier forKey:@"bundleIdentifier"];
        [spe setProperty:bundleIdentifier forKey:@"appIDForLazyIcon"];
        [spe setProperty:@YES forKey:@"useLazyIcons"];
        
        [specifiers addObject:spe];
    }
    
    return specifiers;
}

-(OrderedDictionary*)trimDataSource:(OrderedDictionary*)dataSource {
    OrderedDictionary *mutable = [dataSource mutableCopy];
    
    NSArray *bannedIdentifiers = [[NSArray alloc] initWithObjects:
                                  @"com.apple.sidecar",
                                  nil];

    for (NSString *key in bannedIdentifiers) {
        [mutable removeObjectForKey:key];
    }
    return mutable;
}

-(OrderedDictionary*)sortedDictionary:(OrderedDictionary*)dict {
    NSArray *sortedValues;
    OrderedDictionary *mutable = [OrderedDictionary dictionary];
    
    sortedValues = [[dict allValues] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *value in sortedValues) {
        // Get key for value.
        NSString const *key = [[dict allKeysForObject:value] objectAtIndex:0];
        
        [mutable setObject:value forKey:key];
    }
    
    return mutable;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
  NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
  NSMutableDictionary *settings = [NSMutableDictionary dictionary];
  [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];

  return ([settings objectForKey:specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
  NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
  NSMutableDictionary *settings = [NSMutableDictionary dictionary];
  [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];

  [settings setObject:value forKey:specifier.properties[@"key"]];
  [settings writeToFile:path atomically:YES];
  CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
  if (notificationName) {
   CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
  }

  NSString const *key = [specifier propertyForKey:@"key"];
    
  NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little11prefs.plist"];

  if (([[prefs objectForKey:@"statusBarStyle"] integerValue]) == 0) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"HideSBCC"]] animated:YES];
  }
  else {
    if (![self containsSpecifier:self.savedSpecifiers[@"HideSBCC"]])
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"HideSBCC"]] afterSpecifierID:@"batteryPercent" animated:YES];
  }

  if ([key isEqualToString:@"iPadDock"]) {
      if ([value boolValue] == false) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"iPadMultitasking"]] animated:YES];
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcherNoDock"]] animated:YES];
            if ([self containsSpecifier:self.savedSpecifiers[@"keyboardDock"]])
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcher"]] afterSpecifierID:@"keyboardDock" animated:YES];
            else 
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcher"]] afterSpecifierID:@"homeBarLS" animated:YES];
      }
      else  {
            if (![self containsSpecifier:self.savedSpecifiers[@"iPadMultitasking"]]) {
				[self insertContiguousSpecifiers:@[self.savedSpecifiers[@"iPadMultitasking"]] afterSpecifierID:@"iPadDock" animated:YES];
                [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcher"]] animated:YES];
                if ([self containsSpecifier:self.savedSpecifiers[@"keyboardDock"]])
                    [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcherNoDock"]] afterSpecifierID:@"keyboardDock" animated:YES];
                else 
                    [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"roundedAppSwitcherNoDock"]] afterSpecifierID:@"homeBarLS" animated:YES];
        }
	}
  }

  else if ([key isEqualToString:@"roundedAppSwitcher"]) {

      if ([value boolValue] == false) {
          [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] animated:YES];
      }
      else if (![self containsSpecifier:self.savedSpecifiers[@"appswitcherRoundness"]]) {
            if ([self containsSpecifier:self.savedSpecifiers[@"roundedAppSwitcher"]])
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] afterSpecifierID:@"roundedAppSwitcher" animated:YES];
            else
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"appswitcherRoundness"]] afterSpecifierID:@"roundedAppSwitcherNoDock" animated:YES];
	  }

    }

    else if ([key isEqualToString:@"roundedCorners"]) {

        if ([value boolValue] == false) {
            [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"screenRoundness"]] animated:YES];
        }
        else if (![self containsSpecifier:self.savedSpecifiers[@"screenRoundness"]]) {
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"screenRoundness"]] afterSpecifierID:@"roundedCorners" animated:YES];
        }

    }
    
    if (([[prefs objectForKey:@"statusBarStyle"] integerValue] > 1) || [[prefs objectForKey:@"bottomInset"] boolValue]) {
        if (![self containsSpecifier:self.savedSpecifiers[@"compatabilityMode"]]) {
            if ([self containsSpecifier:self.savedSpecifiers[@"screenRoundness"]])
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] afterSpecifierID:@"screenRoundness" animated:YES];
            else 
                [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] afterSpecifierID:@"roundedCorners" animated:YES];

            [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"deviceSpoofing"]] afterSpecifierID:@"compatabilityMode" animated:YES];
        }
    }

    else {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"compatabilityMode"]] animated:YES];
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"deviceSpoofing"]] animated:YES];
    }
} 
  

- (void)respring:(id)sender {
    pid_t pid;
    const char* args[] = {"sbreload", NULL};
    posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
}
@end

@implementation L11TwitterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

    if (self) {

        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 38, 38)];

        self.detailTextLabel.numberOfLines = 1;
        self.detailTextLabel.textColor = [UIColor grayColor];

        self.textLabel.textColor = [UIColor blackColor];
        self.tintColor = [UIColor labelColor];

        CGFloat const size = 29.f;

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, [UIScreen mainScreen].scale);
        specifier.properties[@"iconImage"] = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        _avatarView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        _avatarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatarView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1];
        _avatarView.userInteractionEnabled = NO;
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = size / 2;
        _avatarView.layer.borderWidth = 2;
        _avatarView.layer.borderColor = [[UIColor tertiaryLabelColor] CGColor];
        
        [self.imageView addSubview:_avatarView];

        _avatarImageView = [[UIImageView alloc] initWithFrame:_avatarView.bounds];
        _avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatarImageView.alpha = 0;
        _avatarImageView.layer.minificationFilter = kCAFilterTrilinear;
        [_avatarView addSubview:_avatarImageView];

        _user = [specifier.properties[@"accountName"] copy];
        NSAssert(_user, @"User name not provided");

        specifier.properties[@"url"] = [self.class _urlForUsername:_user];

        self.detailTextLabel.text = _user;

        if (!_user) {
            return self;
        }

        // self.avatarImage = [UIImage imageNamed:[NSString stringWithFormat:@"/Library/PreferenceBundles/little11prefs.bundle/%@.png", _user]];

        // This has a delay as image needs to be downloaded
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            
            NSString *size = [UIScreen mainScreen].scale > 2 ? @"original" : @"bigger";
            NSError __block *err = NULL;
            NSData __block *data;
            BOOL __block reqProcessed = false;
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://mobile.twitter.com/%@/profile_image?size=%@", _user, size]]];
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData  *_data, NSURLResponse *_response, NSError *_error) {
                err = _error;
                data = _data;
                reqProcessed = true;
            }] resume];

            while (!reqProcessed) {
                [NSThread sleepForTimeInterval:0];
            }

            if (err)
                return;
                
            dispatch_async(dispatch_get_main_queue(), ^{
                    self.avatarImage = [UIImage imageWithData: data];
            });
        });
    }

    return self;
}

#pragma mark - Avatar

- (void)setAvatarImage:(UIImage *)avatarImage
{
    _avatarImageView.image = avatarImage;

    if (_avatarImageView.alpha == 0)
    {
        [UIView animateWithDuration:0.15
            animations:^{
                _avatarImageView.alpha = 1;
            }
        ];
    }
}

+ (NSURL *)_urlForUsername:(NSString *)user {

/*    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"aphelion://"]]) {
        return [NSString stringWithFormat: @"aphelion://profile/%@", user]; // Easter egg by hbkirb
    } else*/
     
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
        return [NSURL URLWithString: [@"tweetbot:///user_profile/" stringByAppendingString:user]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) {
        return [NSURL URLWithString: [@"twitterrific:///profile?screen_name=" stringByAppendingString:user]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings://"]]) {
        return [NSURL URLWithString: [@"tweetings:///user?screen_name=" stringByAppendingString:user]];
    } /*else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        return [NSURL URLWithString: [@"twitter://user?screen_name=" stringByAppendingString:user]];
    }*/ else {
        return [NSURL URLWithString: [@"https://mobile.twitter.com/" stringByAppendingString:user]];
    }
}

- (void)setSelected:(BOOL)arg1 animated:(BOOL)arg2
{
    if (arg1) [[UIApplication sharedApplication] openURL:[self.class _urlForUsername:_user] options:@{} completionHandler:nil];
}
@end
