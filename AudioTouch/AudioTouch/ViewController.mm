//
//  ViewController.m
//  AudioTouch
//
//  Created by newland on 2017/5/24.
//  Copyright © 2017年 newland. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "mo_audio.h" //stuff that helps set up low-level audio
#import "FFTHelper.h"
#import "SPView.h"

#define SAMPLE_RATE 44100  //22050 //44100
#define FRAMESIZE  512
#define NUMCHANNELS 2

#define kOutputBus 0
#define kInputBus 1

/// Nyquist Maximum Frequency
const Float32 NyquistMaxFreq = SAMPLE_RATE/2.0;

/// caculates HZ value for specified index from a FFT bins vector
Float32 frequencyHerzValue(long frequencyIndex, long fftVectorSize, Float32 nyquistFrequency ) {
    return ((Float32)frequencyIndex/(Float32)fftVectorSize) * nyquistFrequency;
}
// The Main FFT Helper
FFTHelperRef *fftConverter = NULL;



//Accumulator Buffer=====================

const UInt32 accumulatorDataLenght = 131072;  //16384; //32768; 65536; 131072;
UInt32 accumulatorFillIndex = 0;
Float32 *dataAccumulator = nil;
static void initializeAccumulator() {
    dataAccumulator = (Float32*) malloc(sizeof(Float32)*accumulatorDataLenght);
    accumulatorFillIndex = 0;
}

static BOOL accumulateFrames(Float32 *frames, UInt32 lenght) { //returned YES if full, NO otherwise.
    //    float zero = 0.0;
    //    vDSP_vsmul(frames, 1, &zero, frames, 1, lenght);
    
    if (accumulatorFillIndex>=accumulatorDataLenght) { return YES; } else {
        memmove(dataAccumulator+accumulatorFillIndex, frames, sizeof(Float32)*lenght);
        accumulatorFillIndex = accumulatorFillIndex+lenght;
        if (accumulatorFillIndex>=accumulatorDataLenght) { return YES; }
    }
    return NO;
}

static void emptyAccumulator() {
    accumulatorFillIndex = 0;
    memset(dataAccumulator, 0, sizeof(Float32)*accumulatorDataLenght);
}
//=======================================


//==========================Window Buffer
const UInt32 windowLength = accumulatorDataLenght;
Float32 *windowBuffer= NULL;
//=======================================



/// max value from vector with value index (using Accelerate Framework)
static Float32 vectorMaxValueACC32_index(Float32 *vector, unsigned long size, long step, unsigned long *outIndex) {
    Float32 maxVal;
    vDSP_maxvi(vector, step, &maxVal, outIndex, size);
    return maxVal;
}




///returns HZ of the strongest frequency.
static Float32 strongestFrequencyHZ(Float32 *buffer, FFTHelperRef *fftHelper, UInt32 frameSize, Float32 *freqValue) {
    
    
    //the actual FFT happens here
    //****************************************************************************
    Float32 *fftData = computeFFT(fftHelper, buffer, frameSize);
    //****************************************************************************
    
    
    fftData[0] = 0.0;
    unsigned long length = frameSize/2.0;
    Float32 max = 0;
    unsigned long maxIndex = 0;
    max = vectorMaxValueACC32_index(fftData, length, 1, &maxIndex);
    if (freqValue!=NULL) { *freqValue = max; }
    Float32 HZ = frequencyHerzValue(maxIndex, length, NyquistMaxFreq);
    return HZ;
}



__weak NSString *hzString = nil;



//#pragma mark MAIN CALLBACK
void AudioCallback( Float32 * buffer, UInt32 frameSize, void * userData )
{
    //take only data from 1 channel
    Float32 zero = 0.0;
    
    vDSP_vsadd(buffer, 2, &zero, buffer, 1, frameSize*NUMCHANNELS);    
    if (accumulateFrames(buffer, frameSize)==YES) { //if full
        
        //windowing the time domain data before FFT (using Blackman Window)
        if (windowBuffer==NULL) { windowBuffer = (Float32*) malloc(sizeof(Float32)*windowLength); }
        vDSP_blkman_window(windowBuffer, windowLength, 0);
        vDSP_vmul(dataAccumulator, 1, windowBuffer, 1, dataAccumulator, 1, accumulatorDataLenght);
//        //=========================================
//        
//        
       Float32 maxHZValue = 0;
       Float32 maxHZ = strongestFrequencyHZ(dataAccumulator, fftConverter, accumulatorDataLenght, &maxHZValue);
        hzString = [NSString stringWithFormat:@"%0.3f",maxHZ];
     //  NSLog(@" max HZ = %0.3f ", maxHZ);
       
       
        
        emptyAccumulator(); //empty the accumulator when finished
    }
    memset(buffer, 0, sizeof(Float32)*frameSize*NUMCHANNELS);
}



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,LineChartCellDelegate>{
 
    AVAudioRecorder  *recorder;
    NSTimer   *levelTimer;
    UITableView *bgView;
    NSUserDefaults *yData;
    NSMutableArray *yArray;
    NSString *fbString;
    NSTimer *reloadTime;
    UILabel *label;
    SPView *spview;
}


@end
static vDSP_Length const FFTViewControllerFFTWindowSize = 4096;
@implementation ViewController


//------------------------------------------------------------------------------
#pragma mark - Status Bar Style
//------------------------------------------------------------------------------

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)viewWillAppear:(BOOL)animated
{
   yData = [NSUserDefaults standardUserDefaults];
    yArray =[NSMutableArray array];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //折线图
    [self lineChart];
    //底部按钮
    [self bottomBtn];
    //initialize stuff
    fftConverter = FFTHelperCreate(accumulatorDataLenght);
    initializeAccumulator();
    [self initMomuAudio];
    [self hzAudio];
    [self dbAction];
  //  [self  timeFB];
    
    UITapGestureRecognizer *tapHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapHide.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapHide];
    
 
    
    
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [self.view endEditing:YES];
}
-(void)timeFB
{

    reloadTime = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(reloadState:) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:reloadTime forMode:NSRunLoopCommonModes];
}


-(void)hzAudio
{
    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    
    //
    // Setup time domain audio plot
    //
    self.audioPlotTime.plotType = EZPlotTypeBuffer;
   

    
    //
    // Setup frequency domain audio plot
    //
    self.audioPlotFreq.shouldFill = YES;
    self.audioPlotFreq.plotType = EZPlotTypeBuffer;
    self.audioPlotFreq.shouldCenterYAxis = NO;
//
//    //
//    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
//    //
   self.microphone = [EZMicrophone microphoneWithDelegate:self];
//    
//    //
//    // Create an instance of the EZAudioFFTRolling to keep a history of the incoming audio data and calculate the FFT.
//    //
   self.fft = [EZAudioFFTRolling fftWithWindowSize:FFTViewControllerFFTWindowSize
                                         sampleRate:self.microphone.audioStreamBasicDescription.mSampleRate
                                          delegate:self];
//
//    //
//    // Start the mic
//    //
   [self.microphone startFetchingAudio];

}

-(void)dbAction
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
        levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }
    else
    {
        NSLog(@"%@", [error description]);
    }
    

}
/* 该方法确实会随环境音量变化而变化，但具体分贝值是否准确暂时没有研究 */
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
    /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
    [yArray addObject:[NSString stringWithFormat:@"%f", level*120]];

    [yData setValue:yArray forKey:@"ydata"];
 //
    
 
   //
}

- (void)reloadState:(NSTimer *)t{

       // sView.mpointArr = [NSMutableArray arrayWithArray:self.pointArr];
    
    
    if (yArray.count > 100)
    {
        [yArray removeAllObjects];
        [[NSUserDefaults standardUserDefaults]removePersistentDomainForName:@"ydata"];
        [bgView reloadData];
    }
  
    
}

-(void) initMomuAudio {
    bool result = false;
    result = MoAudio::init( SAMPLE_RATE, FRAMESIZE, NUMCHANNELS, false);
    if (!result) { NSLog(@" MoAudio init ERROR"); }
     result = MoAudio::start( AudioCallback, NULL );
     if (!result) { NSLog(@" MoAudio start ERROR"); }
}





-(void)lineChart{
    
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 0.25;
    [self.view addGestureRecognizer:longPressGr];
   
    
    bgView = [[UITableView alloc] initWithFrame:
              CGRectMake(0,
                         0,
                         self.view.frame.size.width,
                         self.view.frame.size.height)];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.delegate = self;
    bgView.dataSource = self;
    bgView.scrollEnabled = NO;
    bgView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.view addSubview:bgView];
    label = [[UILabel alloc]init];
    label.hidden = YES;
    //label.backgroundColor =[UIColor lightGrayColor];
    label.textColor = [UIColor whiteColor];
    
    [self.view addSubview:label];
    
    
}
-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.view];
    label.frame = CGRectMake(point.x, point.y -100, 400, 50);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // do something
        label.hidden= NO;
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        // do something
        label.hidden= YES;
    }
    
    
}
-(void)bottomBtn{
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableView.frame.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuse = @"reuse";
    LineChartCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    if (cell==nil) {
        cell = [[LineChartCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse frame:CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height)];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    _audioPlotTime =[[EZAudioPlot alloc]initWithFrame:CGRectMake(25, cell.bounds.size.height/3, cell.bounds.size.width, cell.bounds.size.height/2)];
    _audioPlotTime.backgroundColor =[UIColor clearColor];
    _audioPlotTime.color =[UIColor whiteColor];
     self.audioPlotTime.gain = 300;
    [cell addSubview:_audioPlotTime];
   /* spview =[[SPView alloc]initWithFrame:CGRectMake(25, 25, cell.bounds.size.width, cell.bounds.size.height - 120)];
    spview.backgroundColor =[UIColor clearColor];
    [cell addSubview:spview];*/
    
    cell.delegate = self;
    return cell;
}
//------------------------------------------------------------------------------
#pragma mark - EZMicrophoneDelegate
//------------------------------------------------------------------------------

-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Calculate the FFT, will trigger EZAudioFFTDelegate
    //
    [self.fft computeFFTWithBuffer:buffer[0] withBufferSize:bufferSize];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlotTime updateBuffer:buffer[0]
                              withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioFFTDelegate
//------------------------------------------------------------------------------

- (void)        fft:(EZAudioFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize
{
    float maxFrequency = [fft maxFrequency];
   // NSString *noteName = [EZAudioUtilities noteNameStringForFrequency:maxFrequency
   //                                                     includeOctave:YES];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
       NSString *string = [NSString stringWithFormat:@"hz:%.2f %@",  maxFrequency,fbString];
       // NSLog(@"%@",string);
        label.text = string;
        [weakSelf.audioPlotFreq updateBuffer:fftData withBufferSize:(UInt32)bufferSize];
    });
}
-(void)reloadView
{

}
@end
