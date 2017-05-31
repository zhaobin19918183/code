//
//  LienChartView.h
//  AudioTouch
//
//  Created by newland on 2017/5/26.
//  Copyright © 2017年 newland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioTouch-Bridging-Header.h"
#import "AudioTouch-Swift.h"

//rgb
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
@interface LienChartView : UIView<ChartViewDelegate>
@property(nonatomic,strong) NSMutableDictionary *chartDataDic;//折线图数据 必填
@property(nonatomic,strong)NSMutableArray *chartDataArray;
/* view */
@property (nonatomic,strong) UIView *addView;
/* y 轴颜色 */
@property (nonatomic,strong) UIColor *yAxisColor;
/* x 轴颜色 */
@property (nonatomic,strong) UIColor *xAxisColor;

/**
 x 轴数据
 */
@property(nonatomic,retain)NSArray *xAxisDataArray;
/**
 y 轴数据
 */
@property(nonatomic,retain)NSArray *yAxisDataArray;

/**
 初始化
 
 @param frame  frame
 @return self
 */
-(instancetype)initWithFrame:(CGRect)frame;


/**
 设置 xy 轴数据
 
 @param x x 轴数据
 @param y y 轴数据
 @return 图表数据录入
 */
-(ChartDataEntry *)setLinChartData:(double)x y:(double)y;

/**
 初始化数据
 */
-(void)initData;

/**
 绘制折线图的大小
 
 @param frame  frame
 */
-(void)creatLineChart:(CGRect)frame;

@end
