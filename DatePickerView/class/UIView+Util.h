//
//  UIView+Util.h
//  IOS_Catagory_Demo
//
//  Created by tjarry on 15/9/16.
//  Copyright (c) 2015年 tjarry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Util)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property(assign,nonatomic)CGFloat   right;

/*  设置view的边框样式：width、color、radius*/
- (void)setCornerRadius:(CGFloat)radius;
- (void)setBoarderWidth:(float)width withColor:(UIColor *)color Radius:(CGFloat)radius;
- (void)setBoarderWidth:(float)width withColor:(UIColor *)color;

-(void)removeAllSubviews;

/**
 *  背景色和透明度
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor withAlpha:(CGFloat)alpha;

- (UIView *)setWithLine;

-(UIViewController*) viewContoller;
@end
