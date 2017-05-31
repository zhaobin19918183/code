//
//  ViewController.h
//  AudioTouch
//
//  Created by newland on 2017/5/24.
//  Copyright © 2017年 newland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineChartCell.h"

@protocol DBDelegate <NSObject>

-(void)getDB:(float)db;

@end

@interface ViewController : UIViewController
typedef void(^SelectedRoomBlock)(NSString *hzStr);
@property (nonatomic, copy) SelectedRoomBlock selectedRoomBlock;
/**代理*/
@property(nonatomic,weak)id<DBDelegate>delegate;

@end

