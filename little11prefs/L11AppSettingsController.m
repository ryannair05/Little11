#import "L11AppSettingsController.h"

@implementation L11AppSettingsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)specifiers {
    if (_specifiers == nil) {
		NSMutableArray *testingSpecs = [[self loadSpecifiersFromPlistName:@"AppSettings" target:self] mutableCopy];
        
        _specifiers = testingSpecs;
    }
    
	return _specifiers;
}
/*
-(void)viewWillAppear:(BOOL)view {
    [super viewWillAppear:view];
    
    // [self reloadSpecifiers];
}
*/
-(void)setSpecifier:(PSSpecifier*)specifier {
    [super setSpecifier:specifier];
    
    // Load up stuff from here!
    self.displayName = [specifier name];
    self.bundleIdentifier = [specifier propertyForKey:@"bundleIdentifier"];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	NSMutableDictionary *appSettings = [settings objectForKey:self.bundleIdentifier];
	if (!appSettings) {
		appSettings = [NSMutableDictionary new];
	}
	return ([appSettings objectForKey:specifier.properties[@"key"]]) ?: [settings objectForKey:specifier.properties[@"key"]]?:specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	if (![settings objectForKey:self.bundleIdentifier]) {
		[settings setObject:[NSMutableDictionary new] forKey:self.bundleIdentifier];
	}
	[(NSMutableDictionary *)[settings valueForKey:self.bundleIdentifier] setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];

	// pid_t pid;
	// int status;
	// const char* args[] = {"killall", "-9", [self.displayName UTF8String], NULL};
	// posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
	// waitpid(pid, &status, WEXITED);
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}
@end
