//
//  FFT.m
//  TestFFT
//
//  Created by jiangqin on 16/6/18.
//  Copyright © 2016年 mopellet. All rights reserved.
//

#import "FFT.h"
#import "Complex.h"
@implementation FFT

+ (NSArray<Complex *> *)fft:(NSMutableArray<Complex *> *)input{
    NSUInteger N = input.count;
    if (N == 1) return @[[input firstObject]];
    
    if (N % 2 != 0) {
        NSException *exception = [NSException exceptionWithName:@"Cooley-Tukey FFT" reason:@"N is not a power of 2" userInfo:nil];
        NSLog(@"exception:%@",exception);
        return nil;
    }
    
    // fft of even terms
    NSMutableArray<Complex *> *even = [NSMutableArray arrayWithCapacity:N/2];
        for (int k = 0; k < N / 2; k++) {
            even[k] = input[2 * k];
        }
    NSMutableArray<Complex *> *q = [NSMutableArray arrayWithArray:[FFT fft:even]];
    
     // fft of odd terms
       NSMutableArray<Complex *>  * odd = even;  // reuse the array
        for (int k = 0; k < N / 2; k++) {
            odd[k] = input[2 * k + 1];
        }
        NSMutableArray<Complex *> *r = [NSMutableArray arrayWithArray:[self fft:odd]];
    
         NSMutableArray<Complex *> * output = [NSMutableArray arrayWithCapacity:N];
        for (int k = 0; k < N / 2; k++) {
            double kth = -2 * k * M_PI / N;
            Complex * wk = [[Complex alloc] init];
            wk.real = cos(kth);
            wk.imag = sin(kth);
            if (nil == r[k]) {
                NSLog(@"k = %d r.count:%lu",k,(unsigned long)r.count);
            }
            Complex *qcom =  q[k];
            Complex *rcom =  r[k];
            output[k] = [qcom plus:[wk times:rcom]];
            output[k + N / 2] = [qcom minus:[wk times:rcom]];
        }
    
    return output;
}

// compute the inverse FFT of x[], assuming its length is a power of 2
+ (NSArray<Complex *> *)ifft:(NSMutableArray *)x{
    NSUInteger N = x.count;
    NSMutableArray<Complex *> *y = [NSMutableArray arrayWithCapacity:N];
    // take conjugate
    for (int i = 0; i < N; i++) {
        Complex * complex = x[i];
        y[i] = [complex conjugate];
    }
    // compute forward FFT
    y = [NSMutableArray arrayWithArray:[FFT fft:y]];
    // take conjugate again
    for (int i = 0; i < N; i++) {
        Complex * complex = y[i];
        y[i] = [complex conjugate];
    }
    // divide by N
    for (int i = 0; i < N; i++) {
        Complex * complex = y[i];
        y[i] = [complex timesAlpha:1.0 / N];
    }
    return y;
}


// compute the circular convolution of x and y

+ (NSArray<Complex *> *)cconvolve:(NSMutableArray<Complex *> *)x :(NSMutableArray<Complex *> *)y{
    //should probably pad x and y with 0s so that they have same length
    // and are powers of 2
    if (x.count != y.count) {
        NSLog(@"Dimensions don't agree");
        return nil;
    }
    
    NSUInteger N = x.count;
    
    // compute FFT of each sequence
    NSMutableArray<Complex *> *a = [NSMutableArray arrayWithArray:[FFT fft:x]];
    NSMutableArray<Complex *> *b = [NSMutableArray arrayWithArray:[FFT fft:y]];
    
    // point-wise multiply
    NSMutableArray<Complex *> *c = [NSMutableArray arrayWithCapacity:N];
    
    for (int i = 0; i < N; i++) {
        Complex *complex = a[i];
        c[i] = [complex times:b[i]];
    }
    return [FFT ifft:c];
}


// compute the linear convolution of x and y
+ (NSArray<Complex *> *)convolve:(NSMutableArray<Complex *> *)x :(NSMutableArray<Complex *> *)y{
    Complex *ZERO = [[Complex alloc] init];
    
    NSMutableArray<Complex *> *a = [NSMutableArray arrayWithCapacity:2 * x.count];
    for (NSUInteger i = 0; i < x.count; i++) a[i] = x[i];
    for (NSUInteger i = x.count; i < 2 * x.count; i++) a[i] = ZERO;

    NSMutableArray<Complex *> *b = [NSMutableArray arrayWithCapacity:2 * y.count];
    for (NSUInteger i = 0; i < y.count; i++) b[i] = y[i];
    for (NSUInteger i = y.count; i < 2 * y.count; i++) b[i] = ZERO;

    return [FFT cconvolve:a :b];
}

// display an array of Complex numbers to standard output
- (void)show:(NSMutableArray <Complex *> *)x :(NSString *)title{
    NSLog(@"%@",title);
    NSLog(@"-------------");
    for (int i = 0; i < x.count; i++) {
        NSLog(@"%@",x[i]);
    }
}
@end
