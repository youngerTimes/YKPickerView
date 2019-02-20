//
//  DateModel.h
//  DatePickerViewDemo
//
//  Created by 杨锴 on 2018/1/18.
//  Copyright © 2018年 younger_times. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateModel : NSObject

@property(nonatomic,assign)NSInteger year;
@property(nonatomic,assign)NSInteger month;
@property(nonatomic,assign)NSInteger day;
@property(nonatomic,assign)NSInteger hour;
@property(nonatomic,assign)NSInteger minute;
@property(nonatomic,assign)NSInteger second;
@property(nonatomic,assign)NSInteger weekDay; //星期天：1 .... 星期六：7
@property(nonatomic,strong)NSDate *date;

/**
 返回日期格式
 
 @param format 格式化的字符串
 @return 返回字符串
 */
-(NSString *)returnDateByFormat:(NSString *)format;

/**
 返回格式化的周
 
 @param weekDay weekDay
 @return 格式化
 */
-(NSString *)returnWeek:(NSInteger)weekDay;

@end
