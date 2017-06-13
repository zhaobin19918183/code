//
//  LottyWkWebViewController.h
//  WebViewDemo
//
//  Created by YYDD on 2017/5/4.
//  Copyright © 2017年 com.lotty.web. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LottyWkWebViewController : UIViewController

@property(nonatomic,strong)NSString *titleStr;

@property(nonatomic,strong)NSString *urlStr;

@property(nonatomic,assign)BOOL showTabBar;

@property(nonatomic,assign)BOOL beChildView;

@end
