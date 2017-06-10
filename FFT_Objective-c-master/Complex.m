//
//  Complex.m
//  TestFFT
//
//  Created by jiangqin on 16/6/18.
//  Copyright © 2016年 mopellet. All rights reserved.
//

#import "Complex.h"

@implementation Complex

- (instancetype)plus:(Complex* )b {
    if(self){
        self.real = self.real + b.real;
        self.imag = self.imag + b.imag;
    }
    return self;
}

- (instancetype)minus:(Complex *)b{
    if(self){
        self.real = self.real - b.real;
        self.imag = self.imag - b.imag;
    }
    return self;
}

- (instancetype)times:(Complex *)b{
    Complex *complex = [[Complex alloc] init];
    if (self) {
        complex.real = self.real * b.real - self.imag * b.imag;
        complex.imag = self.real * b.imag + self.imag * b.real;
    }
    return complex;
}

- (instancetype)timesAlpha:(double)alpha{
    if (self) {
        self.real = self.real * alpha;
        self.imag = self.imag * alpha;
    }
    return self;
}
- (instancetype)conjugate{
    if (self) {
        self.real = self.real;
        self.imag = -self.imag;
    }
    return self;
}

- (instancetype)reciprocal{
    if (self) {
        double scale = self.real * self.real + self.imag * self.imag;
        self.real = self.real/scale ;
        self.imag = -self.imag/scale;
    }
    return self;
}

- (instancetype)divides:(Complex *)b{
    return [self times:[b reciprocal]];;
}


- (NSString *)toString{
    if (self.imag == 0) {
        return [NSString stringWithFormat:@"%.3f",self.real];
    }
    if (self.real == 0) {
        return [NSString stringWithFormat:@"%.3f",self.imag];
    }
    if (self.imag < 0) {
        return [NSString stringWithFormat:@"%.3f - %.3fi",self.real,(-self.imag)];
    }
    return [NSString stringWithFormat:@"%.3f + %.3f",self.real,self.imag];
}

- (double)abs{
    return hypot(self.real, self.imag);
}

- (double)phase{
    return atan2(self.imag,self.real);
}

- (instancetype)exp{
    Complex *complex = [[Complex alloc] init];
    complex.real = exp(self.real) * cos(self.imag);
    complex.imag = exp(self.real) * sin(self.imag);
    return complex;
}

- (instancetype)sin{
    Complex *complex = [[Complex alloc] init];
    if (self) {
        complex.real = sin(self.real) * cosh(self.imag);
        complex.imag = cos(self.real) * sinh(self.imag);
    }
    return complex;
}

- (instancetype)cos{
    Complex *complex = [[Complex alloc] init];
    if (self) {
        complex.real = cos(self.real) * cosh(self.imag);
        complex.imag = -sin(self.real) * sinh(self.imag);
    }
    return complex;
}

- (instancetype)tan{
    return  [[self sin] divides:[self cos]];
}

+ (instancetype)plus:(Complex*)a :(Complex *)b{
    Complex * sum = [[Complex alloc] init];
    sum.real = a.real + b.real;
    sum.imag = a.imag + b.imag;
    return sum;
}

@end
