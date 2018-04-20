//
//  AssistiveTouch.h
//  AssistiveTouch
//
//  Created by shuai pan on 2018/1/24.
//  Copyright © 2018年 shuai pan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidSelectExpansionContent)(NSInteger);

@interface AssistiveTouch : UIWindow
@property (nonatomic, strong) NSArray *expansionArray;

+ (instancetype)shareAssTouch;

- (void)showTouchImage:(UIImage *)image didSelectExpansionContent:(DidSelectExpansionContent)didSelectBlock;

- (CGRect)activeArea;
@end


