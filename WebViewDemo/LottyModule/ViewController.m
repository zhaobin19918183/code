//
//  ViewController.m
//  WebViewDemo
//
//  Created by YYDD on 2017/5/4.
//  Copyright © 2017年 com.lotty.web. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:24];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"这个是壳的页面";
    label.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:label];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
