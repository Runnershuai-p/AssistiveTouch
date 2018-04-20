//
//  UIView+AnimationRules.h
//  AssistiveTouch
//
//  Created by shuai pan on 2018/1/25.
//  Copyright © 2018年 shuai pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AnimationRules)

//悬浮窗弱化
- (void)weakenedAssistiveTouch:(CGRect)borderRect isWeakened:(BOOL)isWeakened weakened:(void(^)(CGRect rect))weakenedBlock ;

// 悬浮窗是否越界
- (void)judgeAcrossTheborder:(CGRect)borderRect isOverBack:(void(^)(BOOL isOvered,CGRect rect))overBlock ;

//获取悬浮窗据临界边最优点坐标
- (CGPoint)minimumDistanceWitScreenBorder:(CGRect)borderRect ;


/**
 屏幕朝向------->
 横屏向右：2
 横屏向左：-2
 竖屏：1
 */
- (UIInterfaceOrientation)interfaceScreenToward ;


/**
判断视图相对于屏幕的左右侧
 @param view view
 @return 1（右侧）、-1（左侧）
 */
- (NSInteger)relativeWindowLocation:(UIView *)view ;


//两点间距

float lineLengthOfPoints(CGPoint pointA,CGPoint pointB);



@end
