//
//  LottyApiLogic.h
//  WebViewDemo
//
//  Created by YYDD on 2017/5/23.
//  Copyright © 2017年 com.lotty.web. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LottyApiObject : NSObject

/**
 是否显示壳
 */
@property(nonatomic,assign)BOOL inSpecialState;

/**
 显示网页内容
 */
@property(nonatomic,strong)NSString *urlStr;

/**
 statusBar背景色
 */
@property(nonatomic,strong)UIColor *statusBarColor;

/**
 0表示白色 1表示黑色
 */
@property(nonatomic,assign)NSInteger fontColorFlag;


/**
 是否显示导航栏
 */
@property(nonatomic,assign)BOOL showNavBar;

/**
 更新地址
 */
@property(nonatomic,strong)NSString *appStoreUrl;

/**
 目标版本号
 */
@property(nonatomic,strong)NSString *targetAppVersion;


@end

@interface LottyApiLogic : NSObject

+(LottyApiLogic *)sharedLogic;


@property(nonatomic,strong)LottyApiObject *apiObject;

-(LottyApiObject *)checkApiState:(NSString *)appId;

-(void)changeStatusBar;


-(void)changeDefaultStatusBar;

@end

