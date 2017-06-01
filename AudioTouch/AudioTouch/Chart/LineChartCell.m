//
//  LineChartCell.m
//  AudioTouch
//
//  Created by newland on 2017/5/26.
//  Copyright © 2017年 newland. All rights reserved.
//

#import "LineChartCell.h"
#import "LienChartView.h"

@implementation LineChartCell{
    LienChartView *lineChartView;
    NSMutableArray *dataArray;
    NSMutableArray *yLine;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame{
    @try {
        self = [super initWithFrame:frame];
        if (self) {
            self.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            dataArray = [[NSMutableArray alloc]init];
            yLine = [[NSMutableArray alloc]init];
            lineChartView = [[LienChartView alloc]initWithFrame:CGRectZero];
            lineChartView.yAxisColor = [UIColor whiteColor];
            lineChartView.xAxisColor = [UIColor whiteColor];
            //添加视图
            lineChartView.addView = self;
            [self creatSubview];
        }
        return self;
    } @catch (NSException *exception) {
        NSLog(@"==========%s出错:%@==========",__func__,exception);
    }
}
-(void)creatSubview{
    NSUserDefaults *ydata = [NSUserDefaults standardUserDefaults];
     yLine  = [ ydata objectForKey:@"ydata"];
    NSLog(@"yLine.count === %lu",(unsigned long)yLine.count);
    
     for (int i=0; i<yLine.count; i++)
     {
          [dataArray addObject:[lineChartView setLinChartData:1*i y:[yLine[i]  floatValue]]];
    }
   // [dataArray addObject:[lineChartView setLinChartData:0 y:0]];
 
    [lineChartView.chartDataDic setObject:dataArray forKey:@"0"];
    //frame
    [lineChartView creatLineChart:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height)];
}

@end
