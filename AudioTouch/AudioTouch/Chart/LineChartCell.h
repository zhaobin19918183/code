//
//  LineChartCell.h
//  AudioTouch
//
//  Created by newland on 2017/5/26.
//  Copyright © 2017年 newland. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LineChartCellDelegate <NSObject>

-(void)reloadView;

@end

@interface LineChartCell : UITableViewCell
/** delegate */
@property (nonatomic,weak) id<LineChartCellDelegate> delegate;
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame;
@end
