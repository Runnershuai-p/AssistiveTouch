//
//  ViewController.m
//  AssistiveTouch
//
//  Created by shuai pan on 2018/1/29.
//  Copyright © 2018年 Pan. All rights reserved.
//

#import "ViewController.h"
#import "AssistiveTouch.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor orangeColor];
    bgView.tag = 1000;
    [self.view addSubview:bgView];
    UIViewController *vc1 = [UIViewController new];
    UIViewController *vc2 = [UIViewController new];
    UIViewController *vc3 = [UIViewController new];


    vc1.view.backgroundColor  = [UIColor whiteColor];
    vc2.view.backgroundColor  = [UIColor redColor];

    vc3.view.backgroundColor  = [UIColor cyanColor];

    [AssistiveTouch shareAssTouch].expansionArray = @[@"注册",@"登录",@"大密室"];
    [[AssistiveTouch shareAssTouch] showTouchImage:[UIImage imageNamed:@"left"] didSelectExpansionContent:^(NSInteger selectIndex) {
        
        switch (selectIndex) {
            case 0:
                if (!self.presentedViewController) {
                    [self presentViewController:vc1 animated:YES completion:nil];
                    
                }
                break;
            case 1:
                if (!self.presentedViewController) {
                    [self presentViewController:vc2 animated:YES completion:nil];
                }
                break;
            case 2:
                if (self.presentedViewController) {
                    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
                    
                }

                break;
                
            default:
                break;
        }
        
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self orientDidChange];
}
- (void)orientDidChange {
    CGRect rect = [[AssistiveTouch shareAssTouch] activeArea];
    UIView *view = [self.view viewWithTag:1000];
    view.frame = rect;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
