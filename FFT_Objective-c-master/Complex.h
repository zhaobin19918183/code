//
//  Complex.h
//  TestFFT
//
//  Created by jiangqin on 16/6/18.
//  Copyright © 2016年 mopellet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Complex : NSObject
@property (assign ,nonatomic) double real;
@property (assign ,nonatomic) double imag;
/**
 *  return a string representation of the invoking Complex object
 */
- (NSString *)toString;

/**
 *  return abs/modulus/magnitude and angle/phase/argument
 */
- (double)abs;

/**
 * 
 */
- (double)phase;
- (instancetype)plus:(Complex* )b;
- (instancetype)minus:(Complex *)b;
- (instancetype)times:(Complex *)b;
- (instancetype)timesAlpha:(double)alpha;
- (instancetype)conjugate;
- (instancetype)reciprocal;
- (instancetype)divides:(Complex *)b;
- (instancetype)exp;
- (instancetype)sin;
- (instancetype)cos;
- (instancetype)tan;
+ (instancetype)plus:(Complex*)a :(Complex *)b;
@end
