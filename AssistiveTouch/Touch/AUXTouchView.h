

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface AUXTouchView : UIView
@property(nonatomic, copy)void(^AUXTouchViewItemBlock)(UIButton *buttn);
@property(nonatomic, strong)NSMutableArray *dataSource;
+ (instancetype)shareTouch;
- (void)drawAUXTouchView;


@end

NS_ASSUME_NONNULL_END
