//
//  TyzpFolatAnimationView.m
//  AssistiveTouch
//
//  Created by shuai pan on 2018/1/20.
//  Copyright © 2018年 shuai pan. All rights reserved.
//

#import "TyzpFloatAnimationView.h"
#import "MacroParameters.h"
@interface TyzpFloatAnimationView ()

@property (nonatomic,assign) BOOL isOpen;

@end

@implementation TyzpFloatAnimationView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self ht_initializeControls];
    }
    return self;
}
- (void)ht_initializeControls {
    [self addSubview:self.content];
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimation:) name:NOTIFI_CONTENT_BEGIN_AT object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat self_w = CGRectGetWidth(self.frame);
    CGFloat self_h = CGRectGetHeight(self.frame);
    self.content.clipsToBounds = YES;
    self.content.layer.cornerRadius = self_h/2;
    
    [UIView beginAnimations:@"contentAnimation" context:nil];
    [UIView setAnimationDelay:0.f];
    [UIView setAnimationDuration:ATDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.content.alpha = _isOpen? 1.f:0.f;
    self.content.frame = CGRectMake(0.f, 0.f, self_w, self_h);
    [UIView commitAnimations];   
}

- (void)openContent:(BOOL)isOpen location:(BOOL)right {
    self.isOpen = isOpen;
    self.content.isRight = right;
    self.content.backgroundColor = [UIColor whiteColor];
}
- (void)startAnimation:(NSNotification *)nofiti {
    
    NSDictionary *dict = nofiti.userInfo;
    if ([nofiti.object isKindOfClass:[UIButton class]]) {
        UIButton *btn = nofiti.object;
        
        BOOL right = ![dict[SUSP_POSITION] boolValue];
        BOOL open = [dict[OPEN_SUSPW] boolValue];
        CGRect self_rect = self.frame;
        [self openContent:open location:right];
        if (open) {
            self_rect.size.width = self.content.expansionWidth;
            if (!right) {
                self_rect.origin.x = CGRectGetMaxX(btn.frame) - self.content.expansionWidth;
            }
        }else {
            self_rect.size.width = CGRectGetWidth(btn.frame);
            if (!right) {
                self_rect.origin.x = CGRectGetMinX(btn.frame);
            }
        }
        [UIView beginAnimations:@"floatAnimation" context:nil];
        [UIView setAnimationDelay:0.f];
        [UIView setAnimationDuration:ATDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.frame = self_rect;
        [UIView commitAnimations];

    }
}
- (TyzpContentView*)content {
    if (!_content) {
        _content = [[TyzpContentView alloc] initWithFrame:CGRectZero];
        _content.alpha = 0.f;
    }
    return _content;
}
- (void)remove {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFI_CONTENT_BEGIN_AT object:nil];
    [self removeFromSuperview];
}
- (void)dealloc {
    
    NSLog(@"TyzpFloatAnimationView dealloc");
}
@end

@interface  TyzpContentView ()

@property (nonatomic,strong)NSMutableArray *buttonArray;

@end
static CGFloat sp = 10.f;
@implementation TyzpContentView

- (CGFloat)expansionWidth {
    return self.buttonArray.count * SingleWidth + AsTouchWidth + sp;
}
- (void)loadResources:(NSArray *)sourceArray {
    if (sourceArray.count < 1) return;
    if (self.buttonArray.count > 0) {
        [self.buttonArray removeAllObjects];
    }
    for (UIView *btn in self.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn removeFromSuperview];
        }
    }
    for (int i=0; i<sourceArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn setTitle:sourceArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [btn addTarget:self action:@selector(clickAnimationViewContenViewAction:) forControlEvents: UIControlEventTouchUpInside];
        [self addSubview:btn];
        [self.buttonArray addObject:btn];
    }
}
- (void)clickAnimationViewContenViewAction:(UIButton *)btn {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickAnimationViewContenAction:)]) {
        [self.delegate clickAnimationViewContenAction:btn.tag];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat self_h = CGRectGetHeight(self.frame);
    CGFloat w = SingleWidth;
    NSInteger i = 0;
    CGFloat x = self.isRight?self_h:5.f+sp;
    for (UIButton *btn in self.buttonArray) {
        btn.frame = CGRectMake( w*i+x, 0.f, w-5.f ,self_h);
        i++;
    }
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _buttonArray;
}


- (void)drawRect:(CGRect)rect {
    [self markLayerWithTopSpacing:MaskSP];
}
- (void )markLayerWithTopSpacing:(CGFloat)spacing {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    CGFloat mask_h = h - 2 * spacing;
    CGFloat radius = mask_h/2;
    CGFloat mask_w = w;
    
    //添加路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint leftCenter = CGPointMake(radius, CGRectGetHeight(self.bounds)/2);
    //    左边
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:leftCenter radius:radius startAngle:M_PI/2 endAngle:M_PI*3/2 clockwise:YES];
    //    中间
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRect:CGRectMake(radius, spacing, w-2*radius, mask_h)];
    //    右边
    CGPoint rightCenter = CGPointMake(mask_w - radius, CGRectGetHeight(self.bounds)/2);
    UIBezierPath *path3 = [UIBezierPath bezierPathWithArcCenter:rightCenter radius:radius startAngle:M_PI*3/2 endAngle:M_PI clockwise:YES];
    [path appendPath:path1];
    [path appendPath:path2];
    [path appendPath:path3];
    shapeLayer.path = path.CGPath;
    self.layer.mask = shapeLayer;
}


@end




















