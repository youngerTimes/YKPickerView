//
//  LunarSolarConverter.h
//  DatePicker
//
//  Created by 杨锴 on 16/5/23.
//  Copyright © 2016年 yvkd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Solar.h"
#import "Lunar.h"

@interface LunarSolarConverter : NSObject

/**
 *农历转公历
 */
+ (Solar *)lunarToSolar:(Lunar *)lunar;

/**
 *公历转农历
 */
+ (Lunar *)solarToLunar:(Solar *)solar;

+(int)Year:(int)y Month:(int)m;

+ (int)LeapMonthDays:(int)y;

+(NSString *)formatlunarWithYear:(int)year AndMonth:(int)month AndDay:(int)day;
@end
