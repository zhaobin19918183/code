//
//  FFT.h
//  TestFFT
//
//  Created by jiangqin on 16/6/18.
//  Copyright © 2016年 mopellet. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Complex;
@interface FFT : NSObject
+ (NSArray<Complex *> *)fft:(NSMutableArray<Complex *> *)input;
+ (NSArray<Complex *> *)ifft:(NSMutableArray *)x;
+ (NSArray<Complex *> *)cconvolve:(NSMutableArray<Complex *> *)x :(NSMutableArray<Complex *> *)y;
+ (NSArray<Complex *> *)convolve:(NSMutableArray<Complex *> *)x :(NSMutableArray<Complex *> *)y;
- (void)show:(NSMutableArray <Complex *> *)x :(NSString *)title;
@end
