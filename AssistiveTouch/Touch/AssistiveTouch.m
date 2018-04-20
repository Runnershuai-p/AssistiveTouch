//
//  AssistiveTouch.m
//  AssistiveTouch
//
//  Created by shuai pan on 2018/1/24.
//  Copyright © 2018年 shuai pan. All rights reserved.
//
#import "TyzpFloatAnimationView.h"
#import "MacroParameters.h"
#import "AssistiveTouch.h"
#import "AppDelegate.h"
#import "UIView+AnimationRules.h"

@interface AssistiveTouch () <TyzpContentViewDelegate>{
    CGFloat marginTop ;
    CGFloat marginBottom ;
}
@property (nonatomic ,strong) TyzpFloatAnimationView *animationView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic ,copy) DidSelectExpansionContent didSelectExpansionContent;

@property (nonatomic ,assign ,readonly) CGFloat openWidth;

@property (nonatomic ,assign) BOOL opened;
@property (nonatomic ,assign) BOOL isRight;
@property (nonatomic ,assign) CGRect borderRect;


@end
@implementation AssistiveTouch


#pragma mark Public Method
+ (instancetype)shareAssTouch {
    static dispatch_once_t onceToken;
    static AssistiveTouch *assTouch= nil;
    dispatch_once(&onceToken, ^{
        assTouch = [[AssistiveTouch alloc] init];
    });
    return assTouch;
}
- (void)showTouchImage:(UIImage *)image didSelectExpansionContent:(DidSelectExpansionContent)didSelectBlock{
    if (image) {
        [self.button setBackgroundImage:image forState:UIControlStateNormal];
    } else {
        [self.button setTitle:@"ATouch" forState:UIControlStateNormal];
        [self.button setBackgroundColor:[UIColor grayColor]];
    }
    self.borderRect = [UIScreen mainScreen].bounds;
    marginTop = isIPhoneX? 40.f:0.f;
    marginBottom = isIPhoneX? 40.f:0.f;
    
    [self changedScreenToward];
    CGRect s_rect = self.frame;
    s_rect.origin.x = self.borderRect.origin.x;
    s_rect.origin.y = self.borderRect.origin.y+CGRectGetWidth(self.frame);
    self.frame = s_rect;
    self.didSelectExpansionContent = didSelectBlock;
}
- (CGRect)activeArea {
    return _borderRect;
}
- (void)setExpansionArray:(NSArray *)expansionArray {
    _expansionArray = expansionArray;
    if (_expansionArray.count < 1) return;
    [self.animationView.content loadResources:_expansionArray];
}
#pragma mark TyzpContentViewDelegate
- (void)clickAnimationViewContenAction:(NSInteger)clickIndex {
    if (self.didSelectExpansionContent) {
        self.didSelectExpansionContent(clickIndex);
    }
}
#pragma mark Private Method

- (instancetype )init {
    CGRect frame = CGRectMake(0.f,100.f,AsTouchWidth ,AsTouchHeight);
    self = [super initWithFrame:frame];
    if (self) {
        //这句话很重要
        [self makeKeyAndVisible];
         self.windowLevel = UIWindowLevelAlert + 1;
        self.rootViewController = [UIViewController new];
        [self ht_initializeControls];
    }
    return self;
    
}
- (void)ht_initializeControls {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.animationView];
    [self addSubview:self.button];
    //放一个拖动手势，用来改变控件的位置
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePostion:)];
    [self.button addGestureRecognizer:pan];
    //设备旋转的时候收回按钮
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
//    self.isWeakened = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat self_w = CGRectGetWidth(self.frame);
    CGFloat self_h = CGRectGetHeight(self.frame);
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self_h/2;
    self.button.clipsToBounds = YES;
    self.button.layer.cornerRadius = self_h/2;
    CGFloat btn_x = 0.f;
    if (self.isRight) {
        btn_x = self_w - self_h;
    }
    self.button.frame = CGRectMake(btn_x, 0.f, self_h, self_h);
    self.animationView.frame = CGRectMake(0.f, 0.f, self_w, self_h);

}

#pragma mark - touchAction
-(void)choose:(UIButton *)btn{
    self.opened = !self.opened;
    btn.alpha = 1.f;

    if (!self.opened) {
        [self performSelector:@selector(weakenedAnimation) withObject:SUSP_WEAKENED_AT afterDelay:FW_HiddenDelay];
    }
    else {
        [self weakenedAnimation];
    }
    CGRect frame = self.frame;
    frame.size.width = self.opened ? self.openWidth:CGRectGetHeight(self.frame);
    CGFloat self_x = CGRectGetMinX(self.frame);
    if (self.isRight) {
        if (self.opened) {
            self_x = CGRectGetMinX(self.frame) - self.openWidth + CGRectGetHeight(self.frame);
        }else {
            self_x = CGRectGetMinX(self.frame) + self.openWidth - CGRectGetHeight(self.frame);
        }
    }
    frame.origin.x = self_x;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.frame = frame;
        NSNumber *isRight = [NSNumber numberWithBool:self.isRight];
        NSNumber *isOpen = [NSNumber numberWithBool:self.opened];
        NSDictionary *animationMsg = @{SUSP_POSITION:isRight,
                                       OPEN_SUSPW:isOpen };
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFI_CONTENT_BEGIN_AT object:btn userInfo:animationMsg];
    });
}

#pragma mark - 手势事件
-(void)changePostion:(UIPanGestureRecognizer *)pan {
    NSInteger location = [self relativeWindowLocation: self.button];
    //获取手势的位置
    CGPoint position = [pan translationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
//        self.isWeakened  = NO;
        self.button.alpha = 1.f;
        self.opened = NO;
        CGRect rect = [self.button convertRect:self.button.bounds toView:AppWindow];
        self.frame = rect;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(weakenedAnimation) object:SUSP_WEAKENED_AT];
        [self weakenedAnimation];
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        self.button.alpha = 1.f;
    }
    else if (pan.state == UIGestureRecognizerStateEnded) {
        [self minimumDistanceAnimation];
        self.isRight = location == 1? YES:NO;
        //结束拖动边界判断
         [self acrossTheborderAnimation];
//        延迟弱化
        [self performSelector:@selector(weakenedAnimation) withObject:SUSP_WEAKENED_AT afterDelay:FW_HiddenDelay];
    }else if (pan.state == UIGestureRecognizerStateCancelled){
         self.isRight = location == 1? YES:NO;
    }
    //通过stransform 进行平移交换
    self.transform = CGAffineTransformTranslate(self.transform, position.x, position.y);
    //将增量置为零
    [pan setTranslation:CGPointZero inView:self];
}


#pragma mark - ChangeStatusBarOrientationNotification
- (void)orientDidChange:(NSNotification *)notifi{
    if ([notifi.name isEqualToString:UIApplicationDidChangeStatusBarOrientationNotification]) {

        [self changedScreenToward];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGRect s_rect = self.frame;
            s_rect.origin.x = self.borderRect.origin.x;
            s_rect.origin.y = self.borderRect.origin.y+CGRectGetWidth(self.frame);
            self.frame = s_rect;
        
            [UIView beginAnimations:@"changesanimation" context:nil];
            [UIView setAnimationDuration:1.5f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.alpha = 1.f;
            self.button.alpha = 1.f;
            [UIView commitAnimations];
            [self performSelector:@selector(weakenedAnimation) withObject:SUSP_WEAKENED_AT afterDelay:FW_HiddenDelay];
        });
    }
}
- (void)orientWillChange:(NSNotification *)notifi {
    if ([notifi.name isEqualToString:UIApplicationWillChangeStatusBarOrientationNotification]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(weakenedAnimation) object:SUSP_WEAKENED_AT];
        [UIView beginAnimations:@"changesanimation" context:nil];
        [UIView setAnimationDuration:1.f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.alpha = 0.f;
        self.button.alpha = 0.f;
        [UIView commitAnimations];
    }
}
#pragma mark - ChangeScreenToward

- (void)changedScreenToward {
    CGFloat sp_h = 0.f;
    CGFloat sp_w = 0.f;
    CGRect rect = self.borderRect;
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interface = [self interfaceScreenToward];
    if(interface == UIInterfaceOrientationPortrait){
        rect.origin.x = 0.f;
        rect.origin.y = marginTop;
        sp_w = 0.f;
        sp_h = marginBottom+marginTop;
    }
    else if(interface == UIInterfaceOrientationLandscapeRight){
        rect.origin.x = marginTop;
        rect.origin.y = 0.f;
        sp_w = marginTop;
        sp_h = marginBottom;
    }
    else if(interface == UIInterfaceOrientationLandscapeLeft){
        rect.origin.x = 0.f;
        rect.origin.y = 0.f;
        sp_w = marginTop;
        sp_h = marginBottom;
    }
    rect.size.width = SCREEN_W - sp_w;
    rect.size.height = SCREEN_H - sp_h;
    self.borderRect = rect;
    //    重新定位touch坐标
}
#pragma mark - touch button返回边界最优距离动画
- (void)minimumDistanceAnimation {
    CGPoint minPoint = [self minimumDistanceWitScreenBorder:self.borderRect];
    CGRect rect = self.frame;
    rect.origin.x = minPoint.x;
    rect.origin.y = minPoint.y;
    [UIView beginAnimations:SUSP_MINDISTANCE_AT context:nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.frame = rect;
    [UIView commitAnimations];
}

#pragma mark - touch button 弱化动画
- (void)weakenedAnimation {
    BOOL isWeakened = !self.opened;
    [self weakenedAssistiveTouch:self.borderRect isWeakened:isWeakened weakened:^(CGRect rect) {
        [UIView beginAnimations:SUSP_WEAKENED_AT context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.button.alpha = isWeakened? 0.3:1.f;
        self.frame = rect;
        [UIView commitAnimations];
    }];
}


#pragma mark - 边界判断动画
- (void)acrossTheborderAnimation {
    [self judgeAcrossTheborder:self.borderRect isOverBack:^(BOOL isOvered, CGRect rect) {
        if (isOvered) {
            [UIView beginAnimations:SUSP_ACROSS_BORDER_AT context:nil];
            [UIView setAnimationDuration:0.3f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.frame = rect;
            [UIView commitAnimations];
        }
    }];
}
#pragma mark - setter method
- (void)setOpened:(BOOL)opened {
    _opened = opened;
    self.animationView.alpha = _opened? 1.f:0.f;
}

#pragma mark - getter method
- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor grayColor];
        [_button addTarget:self action:@selector(choose:) forControlEvents:UIControlEventTouchUpInside];
        _button.titleLabel.font = [UIFont systemFontOfSize:15.f];

    }
    return _button;
}

- (TyzpFloatAnimationView *)animationView {
    if (!_animationView) {
        _animationView = [[TyzpFloatAnimationView alloc] initWithFrame:CGRectZero];
        _animationView.content.delegate = self;
    }
    return _animationView;
}

- (CGFloat)openWidth {
    return [self.animationView.content expansionWidth];
}
@end




