//
//  MSPopoverView.h
//  Test
//
//  Created by meishi on 22/11/2017.
//  Copyright © 2017 Kangbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSPopoverView : UIView

/**
 内容背景色
 */
@property(strong ,nonatomic) UIColor *contentBgColor;


/**
 角度
 */
@property(assign ,nonatomic) CGFloat cornerRadius;

/**
 唯一初始化方法

 @param customView 需要显示的内容
 @return instance
 */
- (instancetype)initWithCustomView:(UIView *)customView;


/**
 弹出view

 @param targetView 触发的view
 @param containerView 在哪个界面弹出
 @param animated 是否需要动画
 */
- (void)popoverAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;
@end
