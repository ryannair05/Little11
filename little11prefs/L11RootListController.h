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
-(OrderedDictionary*)trimDataSource:(OrderedDictionary*)dataSource;
-(NSMutableArray*)appSpecifiers;
- (void)respring:(id)sender;
@end

@interface OBButtonTray : UIView
@property (nonatomic,retain) UIVisualEffectView * effectView;
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
@end

@interface OBBoldTrayButton : UIButton
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+(id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
@property (nonatomic,retain) UIView * viewIfLoaded;
@property (nonatomic,strong) UIColor * backgroundColor;
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end


@interface L11TwitterCell : PSTableCell
@property (nonatomic, retain, readonly) UIView *avatarView;
@property (nonatomic, retain, readonly) UIImageView *avatarImageView;
@end

@interface L11TwitterCell () {
    NSString *_user;
}
@end

