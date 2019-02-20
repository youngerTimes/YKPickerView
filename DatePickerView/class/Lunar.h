//
//  Lunar.h
//  DatePicker
//
//  Created by 杨锴 on 16/5/23.
//  Copyright © 2016年 yvkd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lunar : NSObject
/**
 *是否闰月
 */
@property(assign) BOOL isleap;
/**
 *农历 日
 */
@property(assign) int lunarDay;
/**
 *农历 月
 */
@property(assign) int lunarMonth;
/**
 *农历 年
 */
@property(assign) int lunarYear;
@end
