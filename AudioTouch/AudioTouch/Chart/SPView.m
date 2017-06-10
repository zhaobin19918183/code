//
//  SPView.m
//  StockPlotting
//
//  Created by EZ on 13-11-5.
//  Copyright (c) 2013年 cactus. All rights reserved.
//
#define NLSystemVersionGreaterOrEqualThan(version)  ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
#define IOS7_OR_LATER   NLSystemVersionGreaterOrEqualThan(7.0)
#define GraphColor      [[UIColor greenColor] colorWithAlphaComponent:0.5]
#define str(index)                                  [NSString stringWithFormat : @"%.f", [[self.values objectAtIndex:(index)] floatValue] * kYScale]
#define point(x, y)                                 CGPointMake((x) * kXScale, yOffset + (y) * kYScale)
#import "SPView.h"
#import <AVFoundation/AVFoundation.h>

@interface SPView ()
{
  AVAudioRecorder  *recorder;
     NSTimer   *levelTimer;
     NSString *fbString;
}
@property (nonatomic, strong)   dispatch_source_t timer;

@end
@implementation SPView

const CGFloat   kXScale = 15.0;
const CGFloat   kYScale = 1;

static inline CGAffineTransform
CGAffineTransformMakeScaleTranslate(CGFloat sx, CGFloat sy,
    CGFloat dx, CGFloat dy)
{
    return CGAffineTransformMake(sx, 0.f, 0.f, sy, dx, dy);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        // Initialization code
        [self awakeFromNib];
    }

    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
//    [self setContentMode:UIViewContentModeRight];
   
    _values = [NSMutableArray array];
    [self dbActionString];
//
//    __weak id   weakSelf = self;
//    double      delayInSeconds = 0.1;
//    self.timer =
//        dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
//            dispatch_get_main_queue());
//    dispatch_source_set_timer(
//        _timer, dispatch_walltime(NULL, 0),
//        (unsigned)(delayInSeconds * NSEC_PER_SEC), 0);
//    dispatch_source_set_event_handler(_timer, ^{
//            [weakSelf updateValues];
//        });
//    dispatch_resume(_timer);
}

-(void)dbActionString
{
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (recorder)
    {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }
    else
    {
        NSLog(@"%@", [error description]);
    }
    
    
    
}

- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    
    float   level;                // The linear 0.0 .. 1.0 value we need.
    float   minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float   decibels    = [recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels)
    {
        level = 0.0f;
    }
    else if (decibels >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * decibels);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        
        level = powf(adjAmp, 1.0f / root);
    }
    fbString = [NSString stringWithFormat:@"db:%f",level*120];
    
    [self setContentMode:UIViewContentModeRight];
    
    __weak id   weakSelf = self;
    double      delayInSeconds = 1;
    self.timer =
    dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                           dispatch_get_main_queue());
    dispatch_source_set_timer(
                              _timer, dispatch_walltime(NULL, 0),
                              (unsigned)(delayInSeconds * NSEC_PER_SEC), 0);
    dispatch_source_set_event_handler(_timer, ^{
        [weakSelf updateValues:level*120];
    });
    dispatch_resume(_timer);
    
}

- (void)updateValues:(float )db
{
    double nextValue = sin(CFAbsoluteTimeGetCurrent())
        + ((double)rand() / (double)RAND_MAX);
  
    [self.values addObject:
    [NSNumber numberWithDouble:db]];
    CGSize size = self.bounds.size;

    /*
     *   UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
     *   if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
     *
     *
     *   }
     */
    CGFloat     maxDimension = size.width; // MAX(size.height, size.width);
    NSUInteger  maxValues =
        (NSUInteger)floorl(maxDimension / kXScale);

    if ([self.values count] > maxValues) {
        [self.values removeObjectsInRange:
        NSMakeRange(0, [self.values count] - maxValues)];
    }

    [self setNeedsDisplay];
}

- (void)dealloc
{
    dispatch_source_cancel(_timer);
}

- (void)drawRect:(CGRect)rect
{
    if ([self.values count] == 0) {
        return;
    }

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx,
        [[UIColor redColor] CGColor]);

    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, 2);

    CGMutablePathRef path = CGPathCreateMutable();

    CGFloat             yOffset = self.bounds.size.height / 2;
    CGAffineTransform   transform =
        CGAffineTransformMakeScaleTranslate(kXScale, kYScale,
            0, yOffset);
    CGPathMoveToPoint(path, &transform, 0, 0);
    CGPathAddLineToPoint(path, &transform, self.bounds.size.width, 0); // self.bounds.size.width其实大了kXScale倍

    CGFloat y = [[self.values objectAtIndex:0] floatValue];
    CGPathMoveToPoint(path, &transform, 0, -y);
    [self drawAtPoint:point(0, -y) withStr:str(0)];

    for (NSUInteger x = 1; x < [self.values count]; ++x) {
        y = [[self.values objectAtIndex:x] floatValue];
        CGPathAddLineToPoint(path, &transform, x, -y);
        [self drawAtPoint:point(x, -y) withStr:str(x)];
    }

    CGContextAddPath(ctx, path);
    CGPathRelease(path);
    CGContextStrokePath(ctx);
}

- (void)drawAtPoint:(CGPoint)point withStr:(NSString *)str
{
    
    if (IOS7_OR_LATER) {
       #if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
        [str drawAtPoint:point withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:8], NSStrokeColorAttributeName:GraphColor}];
       #endif
    } else {
        [str drawAtPoint:point withFont:[UIFont systemFontOfSize:8]];
    }
     
}

@end
