//
//  ViewController.h
//  AudioTouch
//
//  Created by newland on 2017/5/24.
//  Copyright © 2017年 newland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineChartCell.h"

#include "EZAudio/EZAudio.h"

@protocol DBDelegate <NSObject>

-(void)getDB:(float)db;

@end

@interface ViewController : UIViewController<EZMicrophoneDelegate, EZAudioFFTDelegate>

typedef void(^SelectedRoomBlock)(NSString *hzStr);
@property (nonatomic, copy) SelectedRoomBlock selectedRoomBlock;
/**代理*/
@property(nonatomic,weak)id<DBDelegate>delegate;

// EZAudioPlot for frequency plot
//
@property (nonatomic,strong)  EZAudioPlot *audioPlotFreq;

//
// EZAudioPlot for time plot
//
@property (nonatomic,strong)  EZAudioPlot *audioPlotTime;

////
//// A label used to display the maximum frequency (i.e. the frequency with the
//// highest energy) calculated from the FFT.
////
//@property (nonatomic, strong)  UILabel *maxFrequencyLabel;

//
// The microphone used to get input.
//
@property (nonatomic,strong) EZMicrophone *microphone;

//
// Used to calculate a rolling FFT of the incoming audio data.
//
@property (nonatomic, strong) EZAudioFFTRolling *fft;


@end

