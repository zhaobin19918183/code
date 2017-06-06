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
@property(nonatomic,strong) NSMutableDictionary *chartDataDic;//
@property(nonatomic,strong)NSMutableArray *chartDataArray;
/* view */
@property (nonatomic,strong) UIView *addView;
/* */
@property (nonatomic,strong) UIColor *yAxisColor;
/*  */
@property (nonatomic,strong) UIColor *xAxisColor;

/**
 
 */
@property(nonatomic,retain)NSArray *xAxisDataArray;
/**
 
 */
@property(nonatomic,retain)NSArray *yAxisDataArray;

/**
 
 
 @param frame  frame
 @return self
 */
-(instancetype)initWithFrame:(CGRect)frame;


-(ChartDataEntry *)setLinChartData:(double)x y:(double)y;


-(void)initData;


-(void)creatLineChart:(CGRect)frame;

@end
