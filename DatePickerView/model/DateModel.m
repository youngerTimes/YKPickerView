//
//  DateModel.m
//  DatePickerViewDemo
//
//  Created by 杨锴 on 2018/1/18.
//  Copyright © 2018年 younger_times. All rights reserved.
//

#import "DateModel.h"

static NSDictionary *weekDictionary;

@implementation DateModel

+(void)load{
    weekDictionary = @{@1:@"星期天",@2:@"星期一",@3:@"星期二",@4:@"星期三",@5:@"星期四",@6:@"星期五",@7:@"星期六"};
}

-(NSString *)returnDateByFormat:(NSString *)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = format;
    
    NSCalendar *calendar            = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components    = [[NSDateComponents alloc]init];
    components.year                 = self.year;
    components.month                = self.month;
    components.day                  = self.day;
    components.hour                 = self.hour;
    components.minute               = self.minute;
    components.weekday              = self.weekDay;
    NSDate *date                    = [calendar dateFromComponents:components];
    
    return  [formatter stringFromDate:date];
}

-(NSString *)returnWeek:(NSInteger)weekDay{
    return weekDictionary[@(weekDay)];
}

@end
