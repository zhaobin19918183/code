//
//  LienChartView.m
//  AudioTouch
//
//  Created by newland on 2017/5/26.
//  Copyright © 2017年 newland. All rights reserved.
//

#import "LienChartView.h"


@implementation LienChartView{
    //
    LineChartView *chartView;
    UIColor *descriptionColor;//
    UIColor *legendtextColor;//
    UIColor *xAxisTextColor;//
    UIColor *yAxisTextColor;//
    UIColor *axisColor;//
    UIColor *gridColor;//
    UIColor *valueColor;//
    UIColor *lineColor;//
 
    int customXLabelCount;
    
    NSMutableArray <NSNumber*>*copyArray;
   
    BOOL copyState;
 
    ChartYAxis *leftAxis;
}



-(instancetype)initWithFrame:(CGRect)frame
{
    @try {
        self = [super initWithFrame:frame];
        if (self) {
            [self initData];
        }
        return self;
    } @catch (NSException *exception) {
        NSLog(@"==========%s:%@==========",__func__,exception);
    }
}

-(void)initData{
    self.chartDataDic = [[NSMutableDictionary alloc]init];
    descriptionColor = RGBA(65, 197, 238, 1);
    legendtextColor = [UIColor blackColor];
    axisColor = [UIColor darkGrayColor];
    gridColor = RGBA(204, 204, 204, 1);
    valueColor = [UIColor cyanColor];
    lineColor = [UIColor cyanColor];
    customXLabelCount = 100;
    copyArray = [[NSMutableArray alloc]init];
    chartView = [[LineChartView alloc] init];
}

-(void)creatLineChart:(CGRect)frame{
    @try {
        chartView.frame = frame;
        chartView.backgroundColor =  [UIColor blackColor];
        chartView.descriptionText = @"";
       
        chartView.chartDescription.enabled = YES;
        chartView.scaleYEnabled = NO;//
        chartView.doubleTapToZoomEnabled = NO;//
        chartView.dragEnabled = YES;//
        chartView.dragDecelerationEnabled = YES;//
        [chartView setDescriptionFont:[UIFont systemFontOfSize:13]];//
        [chartView setDescriptionTextColor: descriptionColor];//
        chartView.rightAxis.enabled = NO;
        chartView.dragDecelerationFrictionCoef = 0.9;//
       

        
       // [chartView fitScreen];
        
     
        ChartXAxis *xAxis = chartView.xAxis;
        xAxis.axisLineWidth = 1.0/[UIScreen mainScreen].scale;//
        xAxis.labelPosition = XAxisLabelPositionBottom;//
        xAxis.drawGridLinesEnabled = YES;//
        xAxis.labelTextColor = [UIColor grayColor];//
        xAxis.avoidFirstLastClippingEnabled = YES;//
        xAxis.labelCount = 21;
        //xAxis.labelWidth = 1000;
        
        xAxis.forceLabelsEnabled = YES;
        xAxis.axisMinimum = 0;
        xAxis.axisMaximum = 2000;
     
       
        
        //
        leftAxis = chartView.leftAxis;//
        leftAxis.axisLineWidth = 1.0/[UIScreen mainScreen].scale;//
        leftAxis.labelPosition = YAxisLabelPositionOutsideChart;//
        leftAxis.axisLineColor = [UIColor grayColor];//
        leftAxis.labelTextColor = [UIColor grayColor];//
        leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//
        leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//
        leftAxis.gridColor = [UIColor grayColor];
        leftAxis.inverted = NO;
        leftAxis.gridAntialiasEnabled = YES;
        leftAxis.drawGridLinesEnabled = YES;
        leftAxis.labelCount = 7;
        leftAxis.forceLabelsEnabled = YES;
        leftAxis.axisMinimum = 0;
        leftAxis.axisMaximum = 120;
       
        [self setLineCharaData];
    } @catch (NSException *exception) {
        NSLog(@"==========%s:%@==========",__func__,exception);
    }
}

//
-(ChartDataEntry *)setLinChartData:(double)x y:(double)y{
    @try {
        ChartDataEntry *entry = [[ChartDataEntry alloc]initWithX:x y:y];
        return entry;
    } @catch (NSException *exception) {
        NSLog(@"==========%s:%@==========",__func__,exception);
    }
}


-(NSMutableArray *)creatLineChartData:(NSMutableDictionary *)dic{
    @try {
       
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];

        NSArray *dicKey = [dic allKeys];
        
        
        
        for (int i = 0; i<dicKey.count; i++) {
            NSMutableArray *entryArray = [[NSMutableArray alloc]init];
            for (ChartDataEntry *entry in [dic objectForKey:[dicKey objectAtIndex:i]]) {
                [entryArray addObject:entry];
            }
            LineChartDataSet *set = [[LineChartDataSet alloc] initWithValues:entryArray label:@""];
            set.drawCirclesEnabled = NO;
            set.circleRadius = 1;
            [dataSets addObject:set];
        }
        
        return dataSets;
    } @catch (NSException *exception) {
        NSLog(@"==========%s:%@==========",__func__,exception);
    }
}

- (void)setLineCharaData{
    @try {
       
        NSMutableArray *array = [[NSMutableArray alloc]init];
        array = [self creatLineChartData:self.chartDataDic];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:array];

        chartView.data = data;
        
        [self.addView addSubview:chartView];
    } @catch (NSException *exception) {
        NSLog(@"==========%s:%@==========",__func__,exception);
    }
}
@end

