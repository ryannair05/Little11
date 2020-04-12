#import "L11AppSettingsController.h"
#import <Preferences/PSTableCell.h>
#include <spawn.h>
#import "OrderedDictionary.h"

@interface PSListController (Method)
-(BOOL)containsSpecifier:(id)arg1;
@end

@interface L11RootListController : PSListController
@property (nonatomic, retain) UIBarButtonItem *respringButton;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) NSMutableDictionary *savedSpecifiers;
-(NSDictionary*)trimDataSource:(NSDictionary*)dataSource;
-(NSMutableArray*)appSpecifiers;
- (void)respring:(id)sender;
@end

@interface L11TwitterCell : PSTableCell

@property (nonatomic, retain, readonly) UIView *avatarView;
@property (nonatomic, retain, readonly) UIImageView *avatarImageView;
@property (nonatomic, retain) UIImage *avatarImage;

@end


