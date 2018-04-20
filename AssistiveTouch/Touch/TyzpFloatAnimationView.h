//
//  TyzpFolatAnimationView.h
//  AssistiveTouch
//
//  Created by shuai pan on 2018/1/20.
//  Copyright © 2018年 shuai pan. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TyzpContentView;
@interface TyzpFloatAnimationView : UIView
@property (nonatomic,strong) TyzpContentView *content;
//@property (nonatomic,assign) CGFloat openValue;
- (void)remove;
@end





@protocol TyzpContentViewDelegate <NSObject>

- (void)clickAnimationViewContenAction:(NSInteger)clickIndex;
@end

@interface  TyzpContentView : UIView
@property (nonatomic, assign) BOOL isRight;
@property (nonatomic, assign, readonly)CGFloat expansionWidth;

@property (nonatomic, weak) id<TyzpContentViewDelegate> delegate;


- (void)loadResources:(NSArray *)sourceArray ;

@end
