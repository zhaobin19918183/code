//
//  LienChartView.m
//  AudioTouch
//
//  Created by newland on 2017/5/26.
//  Copyright © 2017年 newland. All rights reserved.
//

#import "LienChartView.h"


@implementation LienChartView{
    //颜色
    LineChartView *chartView;
    UIColor *descriptionColor;//文字说明颜色
    UIColor *legendtextColor;//图例文字颜色
    UIColor *xAxisTextColor;//x 轴文字颜色
    UIColor *yAxisTextColor;//y 轴文字颜色
    UIColor *axisColor;//轴颜色
    UIColor *gridColor;//网格线颜色
    UIColor *valueColor;//拐点处文字颜色
    UIColor *lineColor;//折线颜色
    //计算是第几个 x 轴的点
    int customXLabelCount;
    //为了防止重复
    NSMutableArray <NSNumber*>*copyArray;
    //是否重复
    BOOL copyState;
    //y轴
    ChartYAxis *leftAxis;
}


//初始化
-(instancetype)initWithFrame:(CGRect)frame
{
    @try {
        self = [super initWithFrame:frame];
        if (self) {
            [self initData];
        }
        return self;
    } @catch (NSException *exception) {
        NSLog(@"==========%s出错:%@==========",__func__,exception);
    }
}

//初始化数据
-(void)initData{
    self.chartDataDic = [[NSMutableDictionary alloc]init];//折线数据
    descriptionColor = RGBA(65, 197, 238, 1);//文字说明颜色
    legendtextColor = [UIColor blackColor];//图例文字颜色
    axisColor = [UIColor darkGrayColor];//轴颜色
    gridColor = RGBA(204, 204, 204, 1);//网格线颜色
    valueColor = [UIColor cyanColor];//拐点处文字颜色
    lineColor = [UIColor cyanColor];//折线颜色
    customXLabelCount = 0;//自定义的 x 轴数量
    copyArray = [[NSMutableArray alloc]init];
    chartView = [[LineChartView alloc] init];
}

//添加折线图
-(void)creatLineChart:(CGRect)frame{
    @try {
        chartView.frame = frame;
        chartView.backgroundColor =  [UIColor blackColor];
        chartView.descriptionText = @"";
        chartView.noDataText = @"暂无数据";
        chartView.scaleYEnabled = NO;//Y轴缩放
        chartView.scaleXEnabled = NO;//X轴缩放
        chartView.doubleTapToZoomEnabled = NO;//取消双击缩放
        chartView.dragEnabled = NO;//启用拖拽图标
        chartView.dragDecelerationEnabled = NO;//拖拽后是否有惯性效果
        [chartView setDescriptionFont:[UIFont systemFontOfSize:13]];//描述字体大小
        [chartView setDescriptionTextColor: descriptionColor];//文字描述
        chartView.rightAxis.enabled = NO;//不绘制右边轴
        chartView.legend.form = ChartLegendFormNone;
        
        //设置X轴样式
        ChartXAxis *xAxis = chartView.xAxis;
        xAxis.axisLineWidth = 1.0/[UIScreen mainScreen].scale;//设置X轴线宽
        xAxis.labelPosition = XAxisLabelPositionBottom;//X轴的显示位置，默认是显示在上面的
        xAxis.drawGridLinesEnabled = YES;//不绘制网格线
        xAxis.labelTextColor = [UIColor grayColor];//label文字颜色
        xAxis.avoidFirstLastClippingEnabled = YES;//两端对齐
        xAxis.labelCount = 7;
        xAxis.forceLabelsEnabled = YES;
        xAxis.axisMinimum = 0;
        xAxis.axisMaximum = 60;
        
        //设置Y轴样式
        leftAxis = chartView.leftAxis;//获取左边Y轴
        leftAxis.axisLineWidth = 1.0/[UIScreen mainScreen].scale;//Y轴线宽
        leftAxis.labelPosition = YAxisLabelPositionOutsideChart;//label位置
        leftAxis.axisLineColor = [UIColor grayColor];//Y轴颜色
        leftAxis.labelTextColor = [UIColor grayColor];//文字颜色
        leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//文字字体
        leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置虚线样式的网格线
        leftAxis.gridColor = [UIColor grayColor];//网格线颜色
        leftAxis.inverted = NO;//是否将Y轴进行上下翻转
        leftAxis.gridAntialiasEnabled = YES;//开启抗锯齿
        leftAxis.drawGridLinesEnabled = YES;
        leftAxis.labelCount = 7;
        leftAxis.forceLabelsEnabled = YES;
        leftAxis.axisMinimum = 0;
        leftAxis.axisMaximum = 120;
        //设置折线图数据
        [self setLineCharaData];
    } @catch (NSException *exception) {
        NSLog(@"==========%s出错:%@==========",__func__,exception);
    }
}

//设置 xy 轴
-(ChartDataEntry *)setLinChartData:(double)x y:(double)y{
    @try {
        ChartDataEntry *entry = [[ChartDataEntry alloc]initWithX:x y:y];
        return entry;
    } @catch (NSException *exception) {
        NSLog(@"==========%s出错:%@==========",__func__,exception);
    }
}

/**
 绘制折线图
 
 @param dic 所有点的数据
 @return 一条折线的数据
 */
-(NSMutableArray *)creatLineChartData:(NSMutableDictionary *)dic{
    @try {
        //将 LineChartDataSet 对象放入数组中
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
//        int count = 0;//记录当前循环是第几遍
        NSArray *dicKey = [dic allKeys];
        
        
        
        for (int i = 0; i<dicKey.count; i++) {
            NSMutableArray *entryArray = [[NSMutableArray alloc]init];
            for (ChartDataEntry *entry in [dic objectForKey:[dicKey objectAtIndex:i]]) {
                [entryArray addObject:entry];
            }
            LineChartDataSet *set = [[LineChartDataSet alloc] initWithValues:entryArray label:@""];
            set.drawCirclesEnabled = NO;//是否绘制拐点
            [dataSets addObject:set];
        }
        
        return dataSets;
    } @catch (NSException *exception) {
        NSLog(@"==========%s出错:%@==========",__func__,exception);
    }
}

//设置折线图数据
- (void)setLineCharaData{
    @try {
        //创建 LineChartData 对象, 此对象就是lineChartView需要最终数据对象
        NSMutableArray *array = [[NSMutableArray alloc]init];
        array = [self creatLineChartData:self.chartDataDic];
        LineChartData *data = [[LineChartData alloc] initWithDataSets:array];
        chartView.data = data;
        //绘图
        [self.addView addSubview:chartView];
    } @catch (NSException *exception) {
        NSLog(@"==========%s出错:%@==========",__func__,exception);
    }
}
@end

