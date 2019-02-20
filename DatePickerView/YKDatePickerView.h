//
//  YKDatePickerView.h
//  DatePickerViewDemo
//
//  Created by 杨锴 on 2018/1/15.
//  Copyright © 2018年 younger_times. All rights reserved.
//

/*
 在古代，一年分为十二个月纪，每个月纪有两个节气。在前的为节气，在后的为中气，如立春为正月节，雨水为正月中，后人就把节气和中气统称为节气。
 
 中气：雨水、春分、谷雨、小满、夏至、大暑、处暑、秋分、霜降、小雪、冬至、大寒
 节气：立春、惊蛰、清明、立夏、芒种、小暑、立秋、白露、寒露、立冬、大雪、小寒
 
 我国农历将二十四个节气分为十二个节气和十二个中气，其中序数为奇数的（如立春）成为节气，偶数的（如雨水）称为中气。
 
 农历以月亮为周期（阴历），十二个月历总共约有354天；再配合年历（阳历），年历则是根据地球公转所形成的四季变化而得的周期所编制。而月历较年历短，两者相差了11天，因此，便要每19年加多7个闰月来填补误差。而决定那一个月做闰月，则依廿四节气而定，农历月份通常包含一个节气和一个中气，如惊蛰╱秋分等等，若某农历月份只有节气而没有中气，历法便会把该月多加一个月以作为闰月。以2006年为例，农历七月正好是个有节气而没有中气的月份，因此便闰七月来作调整误差。
 
 
 综合：若某农历月份只有节气而没有中气，历法便会把该月多加一个月以作为闰月
 闰月列表参照：http://www.wannianli.com.cn/runnian.html
 */

#import <UIKit/UIKit.h>
#import "UIView+Util.h"
#import "DateModel.h"

@class DateModel;

typedef enum : NSUInteger {
    ShortTimeStyle   = 1<<1,     // YYYY-MM-DD
    LongTimeStyle    = 1<<2,     //YYY-MM-DD HH:mm
} DateStyles;

@protocol DatePickerDelegate<NSObject>

@required
/**
 完成点击
 @param model 结果
 */
-(void)complete:(DateModel *)model;

/**
 取消点击
 */
-(void)cancel;
@end

@interface YKDatePickerView : UIView

-(instancetype)initWithStyle:(DateStyles)datetyle;
@property(weak,nonatomic)id< DatePickerDelegate > delegate;

/**
 非UITextField的inputView唤起的View 请调用此两个方法
 
 @param vc 传入的VC
 */
-(void)showDatePickerView:(UIViewController *)vc;

/**
 非UITextField的inputView唤起的View 请调用此两个方法
 
 @param vc 传入的VC
 */
-(void)hidenDatePickerView:(UIViewController *)vc;

@end

