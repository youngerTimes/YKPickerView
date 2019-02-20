//
//  YKDatePickerView.m
//  DatePickerViewDemo
//
//  Created by 杨锴 on 2018/1/15.
//  Copyright © 2018年 younger_times. All rights reserved.
//

#define TOOLBARCOLOR [UIColor orangeColor]  // 工具条字体颜色

#import "YKDatePickerView.h"
#import "LunarSolarConverter.h"

@interface YKDatePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,strong)UIToolbar *toolbar;              //工具条
@property(nonatomic,strong)UIBarButtonItem *cancel;         //取消按钮
@property(nonatomic,strong)UIBarButtonItem *cutCalendar;    //农历国历切换按钮
@property(nonatomic,strong)UIBarButtonItem *weekDay;        //周末
@property(nonatomic,strong)UIBarButtonItem *complete;       //完成按钮
@property(nonatomic,strong)UIPickerView *pickerView;        //日历选择器
@property(nonatomic,strong)UIView *bgView;                  //非TextField唤起时的背景

//======== NSInteger
@property(nonatomic,assign)NSInteger minYear;       //最小年限
@property(nonatomic,assign)NSInteger maxYear;       //最大年限
@property(nonatomic,assign)NSInteger selectYear;    //选中的年
@property(nonatomic,assign)NSInteger selectMonth;   //选中的月
@property(nonatomic,assign)NSInteger selectDay;     //选中的天
@property(nonatomic,assign)NSInteger selectHour;    //选中的时
@property(nonatomic,assign)NSInteger selectMinute;  //选中的分
@property(nonatomic,assign)NSInteger selectSecond;  //选中的秒

//======== NSArray/NSMutableArray
@property(nonatomic,strong)NSMutableArray *hourArray;   //时数组 0 - 24
@property(nonatomic,strong)NSMutableArray *minuteArray; //分数组 0 - 60
@property(nonatomic,strong)NSMutableArray *monthsArray; // 切换农历日历时，取得months的临时数组
@property(nonatomic,strong)NSArray *years;              // 根据最小与最大年限计算的数组至

//======== NSDictionary
@property(nonatomic,strong)NSDictionary * months;           // 国历与农历的月集合
@property(nonatomic,strong)NSDictionary * days;             //国历与农历的天集合
@property(nonatomic,strong)NSDictionary *leapMonths;        //由年对应的闰月
@property(nonatomic,strong)NSDictionary *weekDays;          //星期
@property(nonatomic,strong)NSDictionary *monthMap;          //农历汉字与Int类型映射
@property(nonatomic,strong)NSDictionary *resultSelectDate;  //最终的日期数据结果集

//======== Other
@property(nonatomic,assign)DateStyles dateStyle;             //风格
@property(nonatomic,assign)Boolean gregorian;               //是否是公历
@property(nonatomic,strong)NSDate *date;                    //日期对象
@property(nonatomic,assign)unsigned unitFlags;              //flags
@property(nonatomic,strong)NSCalendar *calendar;            //日历对象
@property(nonatomic,strong)NSDateComponents *components;    //components对象
@property(nonatomic,strong)DateModel *dateModel;

@end

@implementation YKDatePickerView

{
    CGFloat _width;     //屏幕宽度
    CGFloat _height;    //屏幕高度
}

-(instancetype)initWithStyle:(DateStyles)datetyle{
    self = [super init];
    if (self) {
        [self initData];
        _dateStyle           = datetyle;
        self.backgroundColor = [UIColor whiteColor];
        self.bounds          = CGRectMake(0,0 , _width, _width*0.6);
        
        [self addSubview:self.toolbar];
        [self addSubview:self.pickerView];
        
        //添加屏幕翻滚监听，变换视图
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        [self pickerInitSelectDate];
    }
    return self;
}

/**
 初始化加载数据
 */
-(void)initData{
    _width      = [UIScreen mainScreen].bounds.size.width;
    _height     = [UIScreen mainScreen].bounds.size.height;
    _gregorian  = true;
    _unitFlags  = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|
    NSCalendarUnitSecond|NSCalendarUnitWeekday;
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"LeapMonths" ofType:@"plist"];
    _leapMonths     = [NSDictionary dictionaryWithContentsOfFile:path];
    
    _minYear        = 1900;
    _maxYear        = 2100;
    
    for (int i = 0; i < 24; i ++ ) {
        [self.hourArray addObject:@(i)];
    }
    for (int i = 0; i < 60; i ++ ) {
        [self.minuteArray addObject:@(i)];
    }
}

/**
 初始化默认选择，选择当天日期
 */
-(void)pickerInitSelectDate{
    NSDateComponents *compontent = [self dateCompontent];
    self.dateModel = [[DateModel alloc]init];
    [self setDateModelBy:compontent];
    [self weekDay:compontent.weekday];
}

-(void)setDateModelBy:(NSDateComponents *)compontent{
    self.dateModel.year     = compontent.year;
    self.dateModel.month    = compontent.month;
    self.dateModel.day      = compontent.day;
    self.dateModel.hour     = compontent.hour;
    self.dateModel.minute   = compontent.minute;
    self.dateModel.second   = compontent.second;
    self.dateModel.weekDay  = compontent.weekday;
    self.dateModel.date     = [self.calendar dateFromComponents:compontent];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.gregorian = true;
    [self dateCompontent];
    self.toolbar.frame = CGRectMake(0, 0, _width, 30);
    CGFloat orgin = self.toolbar.frame.origin.y + self.toolbar.frame.size.height;
    self.pickerView.frame = CGRectMake(0, orgin, _width, self.frame.size.height);
}

#pragma mark --method

-(void)showDatePickerView:(UIViewController *)vc{
    
    UIView *view = [vc.tabBarController.view.subviews lastObject];
    CGFloat offset;
    if (view == nil || view.isHidden) {
        offset = 0;
    }else{
        offset = view.height;
    }
    
    [vc.view addSubview:self.bgView];
    [vc.view addSubview:self];
    self.frame = CGRectMake(0, _height, _width, self.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.center = CGPointMake(_width/2,_height - self.frame.size.height/2-offset);
    } completion:nil];
}

-(void)hidenDatePickerView:(UIViewController *)vc{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, _height, _width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

/**
 根据年月计算当月天数，包括农历计算（闰月计算），国历计算
 
 @return 返回天数
 */
-(NSInteger)calculateDaysCount{
    
    //选择的年与月
    NSInteger selectYear    = [self.pickerView selectedRowInComponent:0] + _minYear;
    NSInteger selectMonth   = [self.pickerView selectedRowInComponent:1] + 1;
    NSInteger selectDay     = [self.pickerView selectedRowInComponent:2] + 1;
    
    //选取的月份
    NSInteger inter     = [self.pickerView selectedRowInComponent:1];
    NSString *string    = self.monthsArray[inter];
    Boolean leap        = [string containsString:@"闰"];
    
    Lunar *lunar        = [[Lunar alloc]init];
    lunar.lunarYear     = (int)selectYear;
    lunar.lunarMonth    = (int)selectMonth;
    lunar.lunarDay      = (int)selectDay;
    lunar.isleap        = leap;
    
    Solar *solar = [LunarSolarConverter lunarToSolar:lunar];
    
    //转换 components 对象
    self.components.year    = solar.solarYear;
    self.components.month   = solar.solarMonth;
    self.components.day     = solar.solarDay;
    self.date               = [self.calendar dateFromComponents:self.components];
    
    //农历的映射
    if (!_gregorian) {
        selectMonth = [self filtMonths:self.monthsArray[selectMonth - 1]];
    }
    
    //计算闰平年
    Boolean isLapYear = false;
    if ((selectYear%4 == 0 && selectYear%100 != 0)||selectYear%400 == 0){
        isLapYear = YES;
    }else{
        isLapYear = NO;
    }
    
    //国历
    if (_gregorian) {
        //计算天数
        NSSet *day_31 = [NSSet setWithObjects:@1,@3,@5,@7,@8,@10,@12,nil];
        NSSet *day_30 = [NSSet setWithObjects:@4,@6,@9,@11,nil];
        
        //2月且是闰年
        if (selectMonth ==2 && isLapYear) {
            return 29;
        }
        //2月且不是闰年
        if (selectMonth == 2 && !isLapYear) {
            return 28;
        }
        //1,3,5,7,8,10,12月
        if ([day_31 containsObject:[NSNumber numberWithInteger:selectMonth]]) {
            return 31;
        }
        //4,6,9,11月
        else if ([day_30 containsObject:[NSNumber numberWithInteger:selectMonth]]){
            return 30;
        }
    }
    
    //农历
    else{
        NSString *leapString = self.leapMonths[[NSString stringWithFormat:@"%ld",selectYear]];
        if (leapString != nil && leap) {
            //闰月
            return [LunarSolarConverter LeapMonthDays:(int)_selectYear];
        }else{
            //平月
            return [LunarSolarConverter Year:(int)selectYear Month:(int)selectMonth];
        }
    }
    return 0;
}

/**
 闰月问题：返回汉字无法定位Int类型，且包含闰字同理
 
 @param month 汉字月，正月，三月
 @return 返回脚标
 */
-(NSInteger)filtMonths:(NSString *)month{
    if ([month containsString:@"正月"]) return 1;
    if ([month containsString:@"三月"]) return 3;
    if ([month containsString:@"四月"]) return 4;
    if ([month containsString:@"五月"]) return 5;
    if ([month containsString:@"六月"]) return 6;
    if ([month containsString:@"七月"]) return 7;
    if ([month containsString:@"八月"]) return 8;
    if ([month containsString:@"九月"]) return 9;
    if ([month containsString:@"十月"]) return 10;
    if ([month containsString:@"十一月"]) return 11;
    if ([month containsString:@"十二月"]) return 12;
    if ([month containsString:@"二月"]) return 2;
    else return  0;
}

/**
 取消
 */
-(void)cancelClick{
    if ([self.delegate respondsToSelector:@selector(cancel)]) {
        [self.delegate cancel];
    }
}

/**
 完成
 */
-(void)completeClick{
    if ([self.delegate respondsToSelector:@selector(complete:)]) {
        [self.delegate complete:self.dateModel];
    }
}

/**
 公历农历切换
 */
-(void)cutCalendarClick{
    _gregorian = !_gregorian;
    NSString *value = _gregorian?@"国历":@"农历";
    [self.cutCalendar setTitle:value];
    [self.pickerView reloadAllComponents];
    [self dateWithYear:_selectYear Month:_selectMonth Day:_selectDay Hour:_selectHour Minute:_selectMinute];
}

#pragma mark -- delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0) {
        //刷新日期，计算天数
        _selectYear = [pickerView selectedRowInComponent:0] + _minYear;
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
    }
    if (component == 1) {
        //刷新日期，计算天数
        _selectMonth    = [pickerView selectedRowInComponent:1] + 1;
        _selectDay      = [pickerView selectedRowInComponent:2] + 1;
        if (!_gregorian) {
            //农历文字映射
            _selectMonth = [self filtMonths:self.monthsArray[row]];
        }
        [pickerView reloadComponent:2];
    }
    if (component == 2) {
        _selectDay = [pickerView selectedRowInComponent:2] + 1;
    }
    if (component == 3) {
        _selectHour = [pickerView selectedRowInComponent:3];
    }
    if (component == 4) {
        _selectMinute = [pickerView selectedRowInComponent:4];
    }
    [self dateWithYear:_selectYear Month:_selectMonth Day:_selectDay Hour:_selectHour Minute:_selectMinute];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *lbl = (UILabel *)view;
    if (lbl == nil) {
        lbl = [[UILabel alloc]init];
        //在这里设置字体相关属性
        [lbl setTextAlignment:NSTextAlignmentCenter];
    }
    lbl.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return lbl;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (component == 0) {
        NSString * year = [NSString stringWithFormat:@"%ld年",[self.years[row] integerValue]];
        return year;
    }
    
    if (component == 1) {
        NSNumber *number = [NSNumber numberWithBool:self.gregorian];
        if (self.gregorian) {
            NSString *month = [NSString stringWithFormat:@"%@",self.months[number][row]];
            return month;
        }else{
            return self.monthsArray[row];
        }
    }
    
    if (component == 2) {
        NSNumber *number = [NSNumber numberWithBool:self.gregorian];
        NSString *day = [NSString stringWithFormat:@"%@",self.days[number][row]];
        return day;
    }
    
    if (component == 3) {
        NSNumber *number = (NSNumber*)self.hourArray[row];
        NSString *hour = [NSString stringWithFormat:@"%02ld时",[number integerValue]];
        return hour;
    }
    
    if (component == 4) {
        NSNumber *number = (NSNumber*)self.minuteArray[row];
        NSString *minute = [NSString stringWithFormat:@"%02ld分",[number integerValue]];
        return minute;
    }
    return @"";
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    if (_dateStyle == ShortTimeStyle) {
        return 3;
    }
    if (_dateStyle == LongTimeStyle) {
        return 5;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0) {
        return _maxYear - _minYear;
    }
    if (component == 1) {
        NSNumber *number = [NSNumber numberWithBool:self.gregorian];
        
        //先移除
        if (!self.gregorian) {
            [self.monthsArray removeAllObjects];
        }
        
        //在新增
        self.monthsArray = [self.months[number] mutableCopy];
        if (!self.gregorian) {
            NSString *selectYear = [NSString stringWithFormat:@"%ld",_selectYear];
            NSInteger index = [self.leapMonths[selectYear] integerValue];
            
            //查询到当年存在闰月，将闰月插入列表
            if (index) {
                NSString *value = [NSString stringWithFormat:@"闰%@",self.months[number][index - 1]];
                [self.monthsArray insertObject:value atIndex:index];
            }
        }
        return  [self.monthsArray count];
    }
    
    if (component == 2) {
        _selectDay = [pickerView selectedRowInComponent:2] + 1;
        return [self calculateDaysCount];
    }
    if (component == 3) {
        return self.hourArray.count;
    }
    if (component == 4) {
        return self.minuteArray.count;
    }
    return 0;
}

-(void)statusBarOrientationChange:(NSNotification *)noti{
    _width = [UIScreen mainScreen].bounds.size.width;
    _height = [UIScreen mainScreen].bounds.size.height;
    [self layoutSubviews];
}

/**
 返回NSDateComponents格式 取得当天的日期
 
 @return NSDateComponents
 */
-(NSDateComponents*)dateCompontent{
    self.date       = [NSDate date];
    
    self.components = [self.calendar components:self.unitFlags fromDate:self.date];
    _selectYear     = self.components.year;
    _selectMonth    = self.components.month;
    _selectDay      = self.components.day;
    _selectHour     = self.components.hour;
    _selectMinute   = self.components.minute;
    _selectSecond   = self.components.second;
    
    [self.pickerView selectRow:self.components.year - _minYear inComponent:0 animated:YES];
    [self.pickerView selectRow:self.components.month - 1 inComponent:1 animated:YES];
    [self.pickerView selectRow:self.components.day - 1 inComponent:2 animated:YES];
    
    if (_dateStyle == LongTimeStyle) {
        [self.pickerView selectRow:self.components.hour inComponent:3 animated:YES];
        [self.pickerView selectRow:self.components.minute inComponent:4 animated:YES];
    }
    
    [self dateWithYear:_selectYear Month:_selectMonth Day:_selectDay Hour:_selectHour Minute:_selectMinute];
    
    return self.components;
}

/**
 设置周末
 
 @param week 周末字典
 */
-(void)weekDay:(NSInteger)week{
    NSNumber *number = [NSNumber numberWithInteger:week];
    [self.weekDay setTitle:self.weekDays[number]];
}

/**
 选择完毕后，计算时间和格式化，准备输出
 
 @param year 选择年
 @param month 选择月
 @param day 选择天
 */
-(void)dateWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day Hour:(NSInteger)hour Minute:(NSInteger)minute{
    NSDateComponents *components;
    
    //国历
    if (_gregorian) {
        self.components.year    = year;
        self.components.month   = month;
        self.components.day     = day;
        self.components.hour    = hour;
        self.components.minute  = minute;
        self.date               = [self.calendar dateFromComponents:self.components];
        components = [self.calendar components:self.unitFlags fromDate:self.date];
    }
    
    //国历
    else{
        //selectMonth 被修正过了
        NSInteger inter     = [self.pickerView selectedRowInComponent:1];
        NSString *string    = self.monthsArray[inter];
        Boolean leap        = [string containsString:@"闰"];
        
        //农历类创建
        Lunar *lunar        = [[Lunar alloc]init];
        lunar.lunarYear     = (int)year;
        lunar.lunarMonth    = (int)month;
        lunar.lunarDay      = (int)day;
        lunar.isleap        = leap;
        
        //转换国历
        Solar *solar = [LunarSolarConverter lunarToSolar:lunar];
        
        //转换 components 对象
        self.components.year    = solar.solarYear;
        self.components.month   = solar.solarMonth;
        self.components.day     = solar.solarDay;
        self.components.hour    = hour;
        self.components.minute  = minute;
        self.date               = [self.calendar dateFromComponents:self.components];
        components = [self.calendar components:self.unitFlags fromDate:self.date];
    }
    [self setDateModelBy:components];
    [self weekDay:components.weekday];
}

/**
 为了低耦合，本来大部分功能可以对NSDate进行扩展，但要多些一些类，不方面复用
 */
#pragma mark --lazy load

-(NSMutableArray *)hourArray{
    if (!_hourArray) {
        _hourArray = [NSMutableArray array];
    }
    return _hourArray;
}

-(NSMutableArray *)minuteArray{
    if (!_minuteArray) {
        _minuteArray = [NSMutableArray array];
    }
    return _minuteArray;
}

-(NSMutableArray *)monthsArray{
    if (!_monthsArray) {
        _monthsArray = [NSMutableArray array];
    }
    return _monthsArray;
}

-(NSArray *)years{
    if (!_years) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i = _minYear; i <= _maxYear; i ++) {
            [array addObject:[NSNumber numberWithInteger:i]];
        }
        _years = [NSArray arrayWithArray:array];
    }
    return _years;
}

-(NSDictionary *)monthMap{
    if (!_monthMap) {
        _monthMap = @{@"正月":@1,@"二月":@2,@"三月":@3,@"四月":@4,@"五月":@5,@"六月":@6,@"七月":@7,@"八月":@8,@"九月":@9,@"十月":@10,@"十一月":@11,@"十二月":@12};
    }
    return _monthMap;
}

-(NSDictionary *)weekDays{
    if (!_weekDays) {
        _weekDays = @{@1:@"星期天",@2:@"星期一",@3:@"星期二",@4:@"星期三",@5:@"星期四",@6:@"星期五",@7:@"星期六"};
    }
    return _weekDays;
}

-(NSDictionary *)months{
    if (!_months) {
        _months = @{@1:@[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月"],
                    @0:@[@"正月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月",@"八月",@"九月",@"十月",@"十一月",@"十二月"]};
    }
    return _months;
}

-(NSDictionary *)days{
    if (!_days) {
        _days = @{@1:@[@"1日",@"2日",@"3日",@"4日",@"5日",@"6日",@"7日",@"8日",@"9日",@"10日",@"11日",@"12日",@"13日",@"14日",@"15日",@"16日",@"17日",@"18日",@"19日",@"20日",@"21日",@"22日",@"23日",@"24日",@"25日",@"26日",@"27日",@"28日",@"29日",@"30日",@"31日"],
                  @0:@[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十"]};
    }
    return _days;
}

-(UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc]init];
        CGFloat orgin = self.toolbar.frame.origin.y + self.toolbar.frame.size.height;
        _pickerView.frame = CGRectMake(0, orgin, _width, self.frame.size.height);
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

-(UIToolbar *)toolbar{
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc]init];
        _toolbar.frame = CGRectMake(0, 0, _width, 30);
        UIBarButtonItem *springBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [_toolbar setItems:@[self.cancel,self.cutCalendar,springBtn,self.weekDay,self.complete] animated:YES];
    }
    return _toolbar;
}

-(UIBarButtonItem *)cancel{
    if (!_cancel) {
        _cancel = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClick)];
        [_cancel setTintColor:TOOLBARCOLOR];
    }
    return _cancel;
}

-(UIBarButtonItem *)cutCalendar{
    if (!_cutCalendar) {
        _cutCalendar = [[UIBarButtonItem alloc]initWithTitle:@"公历" style:UIBarButtonItemStylePlain target:self action:@selector(cutCalendarClick)];
        [_cutCalendar setTintColor:TOOLBARCOLOR];
    }
    return _cutCalendar;
}

-(UIBarButtonItem *)complete{
    if (!_complete) {
        _complete = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeClick)];
        [_complete setTintColor:TOOLBARCOLOR];
    }
    return _complete;
}

-(UIBarButtonItem *)weekDay{
    if (!_weekDay) {
        _weekDay = [[UIBarButtonItem alloc]initWithTitle:@"未知" style:UIBarButtonItemStylePlain target:nil action:nil];
        [_weekDay setTintColor:TOOLBARCOLOR];
    }
    return _weekDay;
}
-(NSCalendar *)calendar{
    if (!_calendar) {
        _calendar =  [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return _calendar;
}

-(NSDateComponents *)components{
    if (!_components) {
        _components = [[NSDateComponents alloc]init];
    }
    return _components;
}
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor colorWithRed:0.37 green:0.37 blue:0.37 alpha:0.4];
        _bgView.frame = CGRectMake(0, 0, _width, _height);
    }
    return _bgView;
}
@end

