//
//  UIView+AnimationRules.m
//  AssistiveTouch
//
//  Created by shuai pan on 2018/1/25.
//  Copyright © 2018年 shuai pan. All rights reserved.
//

#import "UIView+AnimationRules.h"
#import "MacroParameters.h"


@implementation UIView (AnimationRules)

- (void)weakenedAssistiveTouch:(CGRect)borderRect isWeakened:(BOOL)isWeakened weakened:(void(^)(CGRect rect))weakenedBlock {
    //    边界
    CGPoint leftUp    = [self leftUpCornersPointWithBorderRect:borderRect];
    CGPoint leftDown  = [self leftDownCornersPointWithBorderRect:borderRect];
    CGPoint rightUp   = [self rightUpCornersPointWithBorderRect:borderRect];
    CGPoint rightDown = [self rightDownCornersPointWithBorderRect:borderRect];
    CGRect rect = self.frame;
    CGFloat half_h = CGRectGetHeight(self.frame)/2;
    
    if (isWeakened) {
        CGPoint s_point = CGPointMake(rect.origin.x, rect.origin.y);
        if (CGPointEqualToPoint(s_point, leftUp)) {
//            左上角
            rect.origin.y = leftUp.y-half_h;
        }
        else if (CGPointEqualToPoint(s_point, rightUp)) {
//            右上角
            rect.origin.y = rightUp.y-half_h;
        }
        else if (CGPointEqualToPoint(s_point, leftDown)) {
//            左下角
            rect.origin.y = leftDown.y+half_h;
        }
        else if (CGPointEqualToPoint(s_point, rightDown)) {
//            右下角
            rect.origin.y = rightDown.y+half_h;
        }
        else if (rect.origin.x == leftUp.x) {
            //            左边
            rect.origin.x = leftUp.x - half_h;
        }
        else if (rect.origin.y == rightUp.y) {
            //            上边
            rect.origin.y = rightUp.y - half_h;
        }
        else if (CGRectGetMaxX(self.frame) == rightUp.x){
            //            右边
            rect.origin.x = rightUp.x - half_h;
        }
        else if(CGRectGetMaxY(self.frame) == leftDown.y){
            //            下边
            rect.origin.y = leftDown.y - half_h;
        }
    }
    else {
    
        if (rect.origin.x < leftUp.x) {
//            左边
            rect.origin.x = leftUp.x;
        }
        else if (rect.origin.y < rightUp.y) {
//            上边
            rect.origin.y = rightUp.y;
        }
        else if (CGRectGetMaxX(self.frame) > rightDown.x){
//            右边
            rect.origin.x = rightDown.x - 2*half_h;
        }
        else if(CGRectGetMaxY(self.frame) > leftDown.y){
//            下边
            rect.origin.y = leftDown.y - 2*half_h;
        }
    }
    weakenedBlock(rect);
}
#pragma mark -处理逻辑：最优距离 越界，弱化

//越界判断 合适的frame
- (void)judgeAcrossTheborder:(CGRect)borderRect isOverBack:(void(^)(BOOL isOvered,CGRect rect))overBlock {
    CGRect frame = self.frame;
    CGFloat leftX = CGRectGetMinX(borderRect);//0.f;
    CGFloat rightX = CGRectGetMaxX(borderRect);//SCREEN_W;
    CGFloat upY = CGRectGetMinY(borderRect);
    CGFloat downY = CGRectGetMaxY(borderRect);

    //记录是否越界
    BOOL isOver = NO;
    if (CGRectGetMinX(self.frame) < leftX) {
        frame.origin.x = leftX;
        isOver = YES;
    }
    else if (CGRectGetMaxX(self.frame) > rightX) {
        frame.origin.x = rightX - CGRectGetWidth(self.frame);
        isOver = YES;
    }
    if (CGRectGetMinY(self.frame) < upY) {
        frame.origin.y = upY;
        isOver = YES;
    }
    else if (CGRectGetMaxY(self.frame) > downY) {
        frame.origin.y = downY - CGRectGetHeight(self.frame);
        isOver = YES;
    }
    overBlock(isOver,frame);
}

- (CGPoint)minimumDistanceWitScreenBorder:(CGRect)borderRect {
    CGFloat self_w = CGRectGetWidth(self.frame);
    CGFloat self_h = CGRectGetHeight(self.frame);
//    中心点相对屏幕坐标
    CGPoint center = CGPointMake(self.frame.origin.x + self_w/2, self.frame.origin.y + self_h/2);
//    边界
    CGFloat minX = CGRectGetMinX(borderRect);
    CGFloat maxX = CGRectGetMaxX(borderRect);
    CGFloat minY = CGRectGetMinY(borderRect);
    CGFloat maxY = CGRectGetMaxY(borderRect);
//    NSLog(@"minX：%f,maxX：%f",CGRectGetMinX(rect),CGRectGetMaxX(rect));
//    NSLog(@"minY：%f,maxY：%f",CGRectGetMinY(rect),CGRectGetMaxY(rect));

    CGPoint leftPoint = CGPointMake(minX, center.y);
    CGPoint rightPoint = CGPointMake(maxX, center.y);
    CGPoint upPoint = CGPointMake(center.x, minY);
    CGPoint downPoint = CGPointMake(center.x, maxY);
    CGFloat left_sp = lineLengthOfPoints(center,leftPoint);
    CGFloat right_sp = lineLengthOfPoints(center,rightPoint);
    CGFloat up_sp = lineLengthOfPoints(center,upPoint);
    CGFloat down_sp = lineLengthOfPoints(center,downPoint);
    CGFloat min_sp = MIN(MIN(left_sp, right_sp), MIN(up_sp, down_sp));
    
    if(min_sp == right_sp){
        return CGPointMake(rightPoint.x  - self_w, self.frame.origin.y);
    }
    else if (min_sp  == up_sp){
        return CGPointMake(self.frame.origin.x,upPoint.y);
    }
    else if (min_sp  == down_sp){
        return CGPointMake(self.frame.origin.x, downPoint.y-self_h);
    }
    return CGPointMake(leftPoint.x, self.frame.origin.y);
}

//    横竖屏判断
- (UIInterfaceOrientation)interfaceScreenToward {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return orientation;
}
//
- (CGPoint)leftUpCornersPointWithBorderRect:(CGRect)borderRect {
    CGFloat minX = CGRectGetMinX(borderRect);
    CGFloat minY = CGRectGetMinY(borderRect);
    return CGPointMake(minX, minY);
}
- (CGPoint)rightUpCornersPointWithBorderRect:(CGRect)borderRect {
    CGFloat maxX = CGRectGetMaxX(borderRect);
    CGFloat minY = CGRectGetMinY(borderRect);
    return CGPointMake(maxX, minY);
}
- (CGPoint)leftDownCornersPointWithBorderRect:(CGRect)borderRect {
    CGFloat minX = CGRectGetMinX(borderRect);
    CGFloat maxY = CGRectGetMaxY(borderRect);
    return CGPointMake(minX, maxY);
}
- (CGPoint)rightDownCornersPointWithBorderRect:(CGRect)borderRect {
    CGFloat maxX = CGRectGetMaxX(borderRect);
    CGFloat maxY = CGRectGetMaxY(borderRect);
    return CGPointMake(maxX, maxY);
}


//
- (NSInteger)relativeWindowLocation:(UIView *)view {
    CGRect rect = [view convertRect:view.bounds toView:AppWindow];
    CGFloat x = CGRectGetMidX(rect);
    if (x > SCREEN_W/2) {
        return 1;
    }
    return -1;
}

//线段长度
float lineLengthOfPoints(CGPoint pointA,CGPoint pointB){
    double length = fabs(sqrt(pow(pointB.x-pointA.x, 2)+pow(pointB.y-pointA.y, 2)));
    return length;
}

@end
