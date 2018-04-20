//
//  MacroParameters.h
//  AssistiveTouch
//
//  Created by shuai pan on 2018/1/25.
//  Copyright © 2018年 shuai pan. All rights reserved.
//

#ifndef MacroParameters_h
#define MacroParameters_h

#import "AppDelegate.h"

#define AppWindow ((AppDelegate *)[UIApplication sharedApplication].delegate).window
#define SCREEN_W CGRectGetWidth([UIScreen mainScreen].bounds)
#define SCREEN_H CGRectGetHeight([UIScreen mainScreen].bounds)

#define isIPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

// 悬浮图标悬浮位置
#define SUSP_POSITION @"suspension_position"
// 张开悬浮窗
#define OPEN_SUSPW @"open_float_window"
// 张开悬浮窗单项宽度
#define SingleWidth 60.f


#define AsTouchWidth 50.f
#define AsTouchHeight 50.f

// 张开content 上下间距
#define MaskSP 5.f

//after time

//动画时间
#define ATDuration 0.2f

#define FW_HiddenDelay 5.f

// 张开content动画
#define NOTIFI_CONTENT_BEGIN_AT @"notification_floatAnimationView_satrt_animation"


// 悬浮窗弱化动画
#define SUSP_WEAKENED_AT @"suspension_window_weakened_animate"

// 悬浮窗返回边界最短距离动画
#define SUSP_MINDISTANCE_AT @"suspension_window_minimum_distance_animation"

// 悬浮窗越界后返回边界动画
#define SUSP_ACROSS_BORDER_AT @"suspension_window_across_border_animation"



#endif /* MacroParameters_h */














