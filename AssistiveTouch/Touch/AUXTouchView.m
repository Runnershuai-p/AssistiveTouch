

#import "AUXTouchView.h"



typedef struct {
    NSInteger left;//-1: 图标在左；1：图标在右
    BOOL expand;//是否展开
} CGLayoutDraw;

CG_INLINE CGLayoutDraw
CGLayoutDrawMake(NSInteger left, BOOL expand) {
    CGLayoutDraw value;
    value.left = left;
    value.expand = expand;
    return value;
}


@interface AUXTouchView ()
@property (nonatomic, strong) UIButton *touchView;
@property (nonatomic, strong) NSMutableArray *itemsArray;
@property (nonatomic, assign, readonly) CGFloat maxDWidth;
@property (nonatomic, assign, readonly) CGFloat minDWidth;
@property (nonatomic, assign, readonly) CGFloat superDWidth;
@property (nonatomic, assign, readonly) CGFloat superDHeight;
@property (nonatomic, assign) CGLayoutDraw drawLayout;


@end

@implementation AUXTouchView
@synthesize drawLayout = _drawLayout;



+ (instancetype)shareTouch {
    static AUXTouchView *obj_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj_ = [[AUXTouchView alloc] initWithFrame:CGRectMake(0, 120, 50, 50)];
        obj_.itemsArray = [NSMutableArray arrayWithCapacity:2];
        obj_.dataSource = [NSMutableArray arrayWithCapacity:2];
        
    });
    return obj_;
}

- (void)drawAUXTouchView  {
    
    if(self.drawLayout.expand) {
        [self clickButtonTapped:nil];
    }
    [self performSelector:@selector(touchViewAnimattionKey:) withObject:@"animateAlphaKey" afterDelay:2];

    [[[UIApplication sharedApplication].delegate window] addSubview:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat drawW = CGRectGetHeight(frame);
        
        self.touchView.frame = CGRectMake(0, 0, drawW, drawW);
        [self addSubview:self.touchView];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        self.layer.cornerRadius = drawW/2;
        self.layer.masksToBounds = YES;
        
        self.touchView.layer.cornerRadius = drawW/2;
        self.touchView.layer.masksToBounds = YES;
        
        // 添加拖动手势
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat h = CGRectGetHeight(self.frame);
    
    if(self.drawLayout.expand) {
        //- 展开了
        CGFloat butw = (self.maxDWidth-self.minDWidth)/self.itemsArray.count;

        for (UIButton *buttn in self.itemsArray) {
            buttn.hidden = NO;
            CGFloat oriX = 0;

            if(self.drawLayout.left == -1) {
                oriX = CGRectGetMaxX(self.touchView.frame);
            }
            buttn.frame = CGRectMake(oriX+butw*buttn.tag, 0, butw, h);

        }
    }
    else {
        for (UIButton *buttn in self.itemsArray) {
            buttn.hidden = YES;
            buttn.frame = CGRectMake(0, 0, 60, h);
        }
    }
    
}

- (void)clickButtonItems:(UIButton *)buttn {
    if(self.touchView.selected) {
        [self clickButtonTapped:nil];
    }
    if(self.AUXTouchViewItemBlock) {
        self.AUXTouchViewItemBlock(buttn);
    }
}

- (void)clickButtonTapped:(UIButton *)buttn {
    buttn.alpha = 1;
    [self touchViewRemoveAnimation];

    buttn.selected = !buttn.selected;
    // 悬浮窗按钮点击事件
    [self drawingExpand:buttn.selected];
    if(self.drawLayout.expand) {
        for (UIButton *buttn in self.itemsArray) {
            [buttn removeFromSuperview];
        }
        [self.itemsArray removeAllObjects];
        NSInteger index = 0;
        for (NSString *title in self.dataSource) {
            UIButton *buttn = [UIButton buttonWithType:UIButtonTypeSystem];
            buttn.backgroundColor = [UIColor clearColor];
            [buttn setTitle:title forState:UIControlStateNormal];
            [buttn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            buttn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            [buttn addTarget:self action:@selector(clickButtonItems:) forControlEvents:UIControlEventTouchUpInside];
            buttn.hidden = YES;
            buttn.tag = index;
            [self addSubview:buttn];
            [self.itemsArray addObject:buttn];
            index++;
        }
    }
    else {
        [self performSelector:@selector(touchViewAnimattionKey:) withObject:@"animateAlphaKey" afterDelay:2];
    }
    
    [self setNeedsLayout];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGFloat ww = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat hh = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);

    UIEdgeInsets edg = SafeArea();

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    
//
//
//    CGPoint translation = [gesture translationInView:self.superview];
//    CGPoint center = self.center;
//
//    center.x += translation.x;
//    center.y += translation.y;
//
//    CGFloat top = 44;
//    CGFloat left = 0;
//    CGFloat bottom = 34;
//    CGFloat right = 0;
//
//    UIEdgeInsets edg = UIEdgeInsetsMake(top, left, bottom, right);
//    edg = [[UIApplication sharedApplication].delegate.window safeAreaInsets];
//
//    // 限制悬浮窗不超出屏幕
//    center.x = MAX(edg.left+w/2, MIN(center.x, self.superview.frame.size.width - w/2 - edg.right ));
//    center.y = MAX(edg.top+h/2, MIN(center.y, self.superview.frame.size.height - h/2 - edg.bottom));
//
//    self.center = center;
//    [gesture setTranslation:CGPointZero inView:self.superview];
//
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if(gesture.state == UIGestureRecognizerStateBegan) {
        if(self.drawLayout.expand) {
            [self clickButtonTapped:nil];
        }
        [self touchViewRemoveAnimation];
    }
    else if(gesture.state == UIGestureRecognizerStateChanged) {
        

        CGPoint translation = [gesture translationInView:self.superview];
        CGPoint center = self.center;

        center.x += translation.x;
        center.y += translation.y;

        // 限制悬浮窗不超出屏幕
        center.x = MAX(edg.left+w/2, MIN(center.x, self.superDWidth - w/2 - edg.right ));
        center.y = MAX(edg.top+h/2, MIN(center.y, self.superDHeight - h/2 - edg.bottom));

        self.center = center;
        [gesture setTranslation:CGPointZero inView:self.superview];
        
    }
    else if (gesture.state == UIGestureRecognizerStateEnded){
     
        CGPoint center = self.center;

        CGFloat allowSp = fabs(ww-hh)*(ww<hh? ww/hh:hh/ww);
        
        NSInteger index = 0;
        UIInterfaceOrientation value = [[UIApplication sharedApplication] statusBarOrientation];
        if (value == UIInterfaceOrientationLandscapeLeft||
            value == UIInterfaceOrientationLandscapeRight) {
            index = 1;
        }
        if (index == 0) {
            //- 竖屏
            if (center.y < allowSp) {
                // 停留最上端
                center.y = h/2+edg.top;
            }
            else if (center.y > (hh - allowSp)) {
                // 停留最下端
                center.y = hh-h/2-edg.bottom;
            }
            else if (center.x < ww/2) {
                // 停留最左端
                center.x = w/2+edg.left;
            }
            else if (center.x > ww/2) {
                // 停留最右端
                center.x = ww-w/2-edg.right;
            }
        }
        else {
            //- 横屏
            if (center.x < allowSp) {
                // 停留最左端
                center.x = w/2+edg.left;
            }
            else if (center.x > (ww - allowSp)) {
                // 停留最右端
                center.x = ww-w/2-edg.right;
            }
            else if (center.y < hh/2) {
                // 停留最上端
                center.y = h/2+edg.top;
            }
            else if (center.y > hh/2) {
                // 停留最下端
                center.y = hh-h/2-edg.bottom;
            }
        }
        
        self.center = center;
        [gesture setTranslation:CGPointZero inView:self.superview];
        
        [self performSelector:@selector(touchViewAnimattionKey:) withObject:@"animateAlphaKey" afterDelay:2];
    }
    
}

- (void)drawingExpand:(BOOL)expand {
    self.touchView.selected = expand;

    //- 更具touchView 获取self的坐标
    CGPoint ori_self = [self.touchView.superview convertPoint:self.touchView.frame.origin toView:self.superview];
    CGRect rect = self.frame;

    if(expand) {
        
        BOOL left = (CGRectGetMinX(self.frame)+self.maxDWidth) < self.superDWidth-SafeArea().right;
        if(left) {
            rect.origin.x = ori_self.x;
            rect.size.width = self.maxDWidth;
        }
        else {
            CGRect touch = self.touchView.frame;
            touch.origin.x = self.maxDWidth-CGRectGetWidth(self.touchView.frame);
            self.touchView.frame = touch;
            
            rect.size.width = self.maxDWidth;
            rect.origin.x = ori_self.x-(self.maxDWidth-self.minDWidth);

        }
        self.drawLayout = CGLayoutDrawMake(left? -1:1, expand);
    }
    else {
        BOOL left = CGPointEqualToPoint(ori_self, self.frame.origin);

        rect.size.width = self.minDWidth;
        rect.origin.x = ori_self.x;
        rect.origin.y = ori_self.y;
        CGRect touch = self.touchView.frame;
        touch.origin.x = 0;
        self.touchView.frame = touch;
        self.drawLayout = CGLayoutDrawMake(left? -1:1, NO);
    }
    self.frame = rect;

 
}



- (UIButton *)touchView {
    if(!_touchView) {
        _touchView = [UIButton buttonWithType:UIButtonTypeCustom];
        _touchView.backgroundColor = [UIColor brownColor];
        [_touchView setTitle:@"💓" forState:UIControlStateNormal];
        [_touchView setBackgroundImage:[UIImage imageNamed:@"mainIcon"] forState:UIControlStateNormal];
        [_touchView addTarget:self action:@selector(clickButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _touchView;
}

- (CGFloat)superDHeight{
    //- 父类高度度
    return CGRectGetHeight(self.superview.frame);
}


- (CGFloat)superDWidth {
    //- 父类宽度
    return CGRectGetWidth(self.superview.frame);
}

- (CGFloat)minDWidth {
    //- 最小宽度
    return CGRectGetHeight(self.frame);
}


- (CGFloat)maxDWidth {
    //- 最大宽度
    NSInteger count = self.dataSource.count;
    return self.minDWidth+count*self.minDWidth;
}


UIEdgeInsets SafeArea(void) {
    CGFloat top = 44;
    CGFloat left = 0;
    CGFloat bottom = 34;
    CGFloat right = 0;

    UIEdgeInsets edgInset = UIEdgeInsetsMake(top, left, bottom, right);
    edgInset = [[UIApplication sharedApplication].delegate.window safeAreaInsets];
    return edgInset;
}



- (void)touchViewAnimattionKey:(NSString *)key {
    
    UIInterfaceOrientation value = [[UIApplication sharedApplication] statusBarOrientation];
    if (value == UIInterfaceOrientationLandscapeLeft||
        value == UIInterfaceOrientationLandscapeRight) {
        [UIView animateWithDuration:0.5 animations:^{
            self.touchView.alpha = 0.5;
        }];
        return;
    }
    else {
        CGRect frame = self.frame;
        if(frame.origin.x == 0) {
            frame.origin.x = -CGRectGetHeight(self.frame)/3;
        }
        else if(CGRectGetMaxX(frame) == self.superDWidth) {
            frame.origin.x += CGRectGetHeight(self.frame)/3;
        }
        else if(frame.origin.y == 0){
            frame.origin.y = -CGRectGetHeight(self.frame)/3;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.touchView.alpha = 0.5;
            }];
        }];
    }
}

- (void)touchViewRemoveAnimation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(touchViewAnimattionKey:) object:@"animateAlphaKey"];
    UIInterfaceOrientation value = [[UIApplication sharedApplication] statusBarOrientation];
    if (value == UIInterfaceOrientationLandscapeLeft||
        value == UIInterfaceOrientationLandscapeRight) {
        self.touchView.alpha = 1;
        return;
    }
    else {
        CGRect frame = self.frame;
        if(frame.origin.x == -CGRectGetHeight(self.frame)/3) {
            frame.origin.x = 0;
        }
        else if(CGRectGetMaxX(frame) == self.superDWidth+CGRectGetHeight(self.frame)/3) {
            frame.origin.x -= CGRectGetHeight(self.frame)/3;
        }
        else if(frame.origin.y == -CGRectGetHeight(self.frame)/3){
            frame.origin.y = 0;
        }
        self.frame = frame;
        self.touchView.alpha = 1;
    }
}

@end
