//
//  LottyApiLogic.m
//  WebViewDemo
//
//  Created by YYDD on 2017/5/23.
//  Copyright © 2017年 com.lotty.web. All rights reserved.
//

#import "LottyApiLogic.h"
#import "NSString+AppleJson.h"
#import "NSObject+AppleJson.h"

@implementation LottyApiObject

@end

@interface LottyApiLogic()<UIAlertViewDelegate>



@end

@implementation LottyApiLogic

+(LottyApiLogic *)sharedLogic {

    static LottyApiLogic *logic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logic = [[LottyApiLogic alloc]init];
    });
    return logic;
}

-(LottyApiObject *)checkApiState:(NSString *)appId {

    NSString *urlStr = nil;
    BOOL inSpecialState = YES;
    UIColor *statusBarColor = [UIColor whiteColor];
    NSInteger fontColorFlag = 1;
    BOOL showNavBar = YES;
    
    NSString *appStoreUrl = nil;
    NSString *appVersion = nil;
    
    
    
    NSString *urlAsString = @"https://tzxpsm.com/lotto/api";
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json-rpc" forHTTPHeaderField:@"Accept"];
    
    
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc]init];
    [mutDict setObject:@"2.0" forKey:@"jsonrpc"];
    [mutDict setObject:@"lotto.monitor" forKey:@"method"];
    [mutDict setObject:@1 forKey:@"id"];
    
    NSMutableDictionary *pp = [[NSMutableDictionary alloc]init];
    [pp setObject:appId forKey:@"appid"];
    [mutDict setObject:pp forKey:@"params"];
    NSString *paramStr = [mutDict JSONFragment];
    [urlRequest setHTTPBody:[paramStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:&error];
    
    if (!error && data.length != 0) {
        
        @try {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *dataDict = [str JSONValue];
            
            NSLog(@"%@",dataDict);
            
            NSDictionary *resultDict = dataDict[@"result"];
            if (resultDict) {
                int showWap = [resultDict[@"showWap"]intValue];
                if (showWap) {
                    urlStr = resultDict[@"wapUrl"];
                    if (urlStr.length > 0) {
                        inSpecialState = NO;
                    }
                }
                
                NSString *colorStr = resultDict[@"backgroundColor"];
                if (colorStr && [colorStr isKindOfClass:[NSString class]] && colorStr.length != 0) {
                    statusBarColor = [LottyApiLogic colorWithHexString:colorStr];
                }
                
                fontColorFlag = [resultDict[@"fontColor"]integerValue];

                NSString *verStr = resultDict[@"version"];
                if (verStr && [verStr isKindOfClass:[NSString class]] && verStr.length != 0) {
                    appVersion = verStr;
                }
                
                NSString *storeUrl = resultDict[@"appStoreUrl"];
                if (storeUrl && [storeUrl isKindOfClass:[NSString class]] && storeUrl.length != 0) {
                    appStoreUrl = storeUrl;
                }

                showNavBar = [resultDict[@"showNavBar"]boolValue];
            }
        
        } @catch (NSException *exception) {

        }
    }
    
    
    _apiObject = [[LottyApiObject alloc]init];
    _apiObject.inSpecialState = inSpecialState;
    _apiObject.urlStr = urlStr;
    _apiObject.showNavBar = showNavBar;
    _apiObject.statusBarColor = statusBarColor;
    _apiObject.fontColorFlag = fontColorFlag;
    _apiObject.targetAppVersion = appVersion;
    _apiObject.appStoreUrl = appStoreUrl;
    
    [self changeStatusBar];
    [self checkAppVersion];
    
    return _apiObject;

}


-(void)checkAppVersion {

    if (!_apiObject.targetAppVersion) {
        return;
    }

    NSString *curVersionStr = [LottyApiLogic appVersionInfo];

    NSArray *targetVerArr = [_apiObject.targetAppVersion componentsSeparatedByString:@"."];
    NSArray *curVerArr = [curVersionStr componentsSeparatedByString:@"."];
    
    BOOL needUpdate = NO;
    for (int i = 0; i < MIN(targetVerArr.count, curVerArr.count); i ++) {
        NSInteger targetIndex = [targetVerArr[i]integerValue];
        NSInteger curIndex = [curVerArr[i]integerValue];
        if (targetIndex > curIndex) {
            needUpdate = YES;
            break;
        }
    }

    if (needUpdate) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"有新版本可以更新哦" delegate:self cancelButtonTitle:nil otherButtonTitles:@"点击更新", nil];
            [alert show];
        });
    }

}


-(void)changeStatusBar {

    if (_apiObject.fontColorFlag == 1) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    
    
    if (_apiObject.statusBarColor) {
        
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = _apiObject.statusBarColor;
        }
        [[UIApplication sharedApplication].keyWindow setBackgroundColor:_apiObject.statusBarColor];
    }
}

-(void)changeDefaultStatusBar {
    

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor blackColor];
    }
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSString *urlStr = _apiObject.appStoreUrl;
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]];
}


+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6)
        return [UIColor whiteColor];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor whiteColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (NSString *)appVersionInfo
{
    NSString *versionInfo = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return versionInfo;
}


@end
