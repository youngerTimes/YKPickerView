//
//  UIView+Util.m
//  IOS_Catagory_Demo
//
//  Created by tjarry on 15/9/16.
//  Copyright (c) 2015年 tjarry. All rights reserved.
//

#import "UIView+Util.h"

@implementation UIView (Util)


/**
 *  背景色和透明度
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor withAlpha:(CGFloat)alpha{
    
    self.backgroundColor = backgroundColor;
    self.alpha = alpha;
}


/**
 * 移除所有的子视图
 */
-(void)removeAllSubviews{
    
    for (int i = 0; i < self.subviews.count; i ++) {
        
        UIView *view = self.subviews[i];
        [view removeFromSuperview];
        --i
        ;
    }
}

/**
 *  设置view的边框样式
 */
- (void)setCornerRadius:(CGFloat)radius{
    
    self.layer.cornerRadius = radius;
}

- (void)setBoarderWidth:(float)width withColor:(UIColor *)color Radius:(CGFloat)radius{
    
    [self setBoarderWidth:width withColor:color];
    self.layer.cornerRadius = radius;
}

- (void)setBoarderWidth:(float)width withColor:(UIColor *)color{
    
    self.layer.borderWidth = width;
    self.layer.borderColor = color.CGColor;
}


/**
 设置线
 */
- (UIView *)setWithLine {
    UIView *line = [[UIView alloc]init];
//    line.backgroundColor = defaultLineColor;
    return line;
}


/**
 *  获取view的坐标、大小、中心点等属性
 */
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}


- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

-(UIViewController*) viewContoller{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}
@end
