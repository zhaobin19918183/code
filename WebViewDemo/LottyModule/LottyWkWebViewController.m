//
//  LottyWkWebViewController.m
//  WebViewDemo
//
//  Created by YYDD on 2017/5/4.
//  Copyright © 2017年 com.lotty.web. All rights reserved.
//

#import "LottyWkWebViewController.h"
#import <WebKit/WebKit.h>
#import "MBProgressHUD.h"
#import "LottyApiLogic.h"

@interface LottyWkWebViewController ()<WKNavigationDelegate,WKUIDelegate>
@property(nonatomic,weak)WKWebView *webView;
@property(nonatomic,weak)UIProgressView *progressView;

@property(nonatomic,weak)UIView *actionView;

@property(nonatomic,weak)UIView *backView;

@property(nonatomic,assign)BOOL canRotate;

@property(nonatomic,strong)MBProgressHUD *progressHud;

@end

@implementation LottyWkWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleStr;
    [self changeStatusBarColor];
    [self initUI];
    [self initWebView];

    [self showProgress];
}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self changeStatusBarColor];
}

-(void)showProgress {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.labelText = @"正在加载...";
    _progressHud = hud;
}



-(void)changeStatusBarColor {

    if (!_beChildView) {
        [[LottyApiLogic sharedLogic]changeStatusBar];
    }else {
        [[LottyApiLogic sharedLogic]changeDefaultStatusBar];
        
    }
}

-(void)initWebView {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    WKWebView *webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 20 + _backView.frame.size.height, screenSize.width, screenSize.height - _actionView.frame.size.height - 20 - _backView.frame.size.height)];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    webView.allowsBackForwardNavigationGestures = NO;
    webView.UIDelegate = self;
//    webView.scrollView.bounces = NO;
    
    _webView = webView;
    
    
    
    if (_urlStr) {
        
        NSURL *url=[NSURL URLWithString:_urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        
        [webView loadRequest:request];
        
    }
}


#pragma mark - WebView Delegate
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"=====准备开始加载");
}

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"====已经开始加载");
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"====加载完成");

    [_progressHud hide:YES];
    if (_webView.title.length != 0) {
        self.title = _webView.title;
    }

    
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"=====加载失败");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
    
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    
    NSLog(@"==========");
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    for (NSHTTPCookie *cookie in cookies) {
        NSLog(@"****************%@",cookie);
    }
    

    
    
    
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *urlStr = navigationAction.request.URL.absoluteString;
    if ([urlStr rangeOfString:@"orientation=l"].length != 0) {
        self.canRotate = YES;
    }else {
        self.canRotate = NO;
    }

    //暂时不需要
//    if ([urlStr rangeOfString:@"__open__"].length != 0) {
//        if (![urlStr isEqualToString:self.urlStr]) {
//            [self goPresentWebViewWithUrl:urlStr];
//            decisionHandler(WKNavigationActionPolicyCancel);
//            return;
//        }
//    }
    

    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:navigationAction.request.allHTTPHeaderFields forURL:navigationAction.request.URL];
    for (NSHTTPCookie *cookie in cookies) {
        NSLog(@"****************%@",cookie);
    }
    
    
    
    
    if ([navigationAction.request.URL.absoluteString hasPrefix:@"itms-appss://"]) {
        [[UIApplication sharedApplication]openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else
    {
        // 允许跳转
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}



-(void)initUI {
    
    if (_showTabBar && !_beChildView) {
        CGSize mainSize = [UIScreen mainScreen].bounds.size;
        
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor whiteColor];
        view.frame = CGRectMake(0, mainSize.height - 48, mainSize.width, 48);
        [self.view addSubview:view];
        
        CALayer *lineLayer = [[CALayer alloc]init];
        lineLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
        [view.layer addSublayer:lineLayer];
        lineLayer.frame = CGRectMake(0, 0, mainSize.width, 1.0);
        
        
        UIView *homeView = [self view:[UIImage imageNamed:@"webhome"] WithTitle:@"首页" WithSEL:@selector(homeClick)];
        UIView *backView = [self view:[UIImage imageNamed:@"webback"] WithTitle:@"后退" WithSEL:@selector(backClick)];
        UIView *goView = [self view:[UIImage imageNamed:@"webgo"] WithTitle:@"前进" WithSEL:@selector(goClick)];
        UIView *refreshView = [self view:[UIImage imageNamed:@"webrefresh"] WithTitle:@"刷新" WithSEL:@selector(refreshClick)];
        
        CGFloat padding = (view.frame.size.width - (homeView.frame.size.width + backView.frame.size.width + goView.frame.size.width + refreshView.frame.size.width))/5;
        
        CGRect homeRect = homeView.frame;
        homeRect.origin.x = padding;
        
        CGRect backRect = backView.frame;
        backRect.origin.x = homeRect.origin.x + homeRect.size.width + padding;
        
        CGRect goRect = goView.frame;
        goRect.origin.x = backRect.origin.x + backRect.size.width + padding;
        
        CGRect refreshRect = refreshView.frame;
        refreshRect.origin.x = goRect.origin.x + goRect.size.width + padding;
        
        homeView.frame = homeRect;
        backView.frame = backRect;
        goView.frame = goRect;
        refreshView.frame = refreshRect;
        
        [view addSubview:homeView];
        [view addSubview:backView];
        [view addSubview:goView];
        [view addSubview:refreshView];
        
        
        _actionView = view;

    }
    
    if (_beChildView) {
        CGSize mainSize = [UIScreen mainScreen].bounds.size;

        UIView *view = [[UIView alloc]init];
        view.frame = CGRectMake(0, 20, mainSize.width, 40);
        view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:view];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:[UIImage imageNamed:@"navBack"] forState:UIControlStateNormal];
        [backBtn sizeToFit];
        [backBtn addTarget:self action:@selector(navBackClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:backBtn];
        
        _backView = view;
    }
    
}

-(UIView *)view:(UIImage *)ico WithTitle:(NSString *)title WithSEL:(SEL)selector {
    
    UIView *view = [[UIView alloc]init];
    
    UIImageView *imgV = [[UIImageView alloc]init];
    imgV.image = ico;
    [view addSubview:imgV];
    
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:10];
    [label setText:title];
    [view addSubview:label];
    
    [imgV sizeToFit];
    [label sizeToFit];
    
    view.frame = CGRectMake(0, 0, 48, 48);
    
    
    CGFloat top = (view.frame.size.height - imgV.frame.size.height - label.frame.size.height - 2)/2;
    CGFloat imgLeft = (view.frame.size.width - imgV.frame.size.width)/2;
    CGFloat labelLeft = (view.frame.size.width - label.frame.size.width)/2;
    
    CGRect imgRect = imgV.frame;
    imgRect.origin.y = top;
    imgRect.origin.x = imgLeft;
    imgV.frame = imgRect;
    
    CGRect labelRect = label.frame;
    labelRect.origin.y = view.frame.size.height - top - labelRect.size.height;
    labelRect.origin.x = labelLeft;
    label.frame = labelRect;
    
    [view setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:selector];
    [view addGestureRecognizer:tapGesture];
    
    return view;
}

-(void)homeClick {
    
    NSURL *url=[NSURL URLWithString:_urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    [_webView loadRequest:request];
    
}

-(void)backClick {
    
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    
}

-(void)goClick {
    
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}


-(void)refreshClick {
    
    [_webView reload];
}



-(void)navBackClick {

    NSURL *cookieHost = [NSURL URLWithString:self.urlStr];
    NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:[cookieHost host],NSHTTPCookieDomain,[cookieHost path],NSHTTPCookiePath,@"COOKIE_NAME",NSHTTPCookieName,@"COOKIE_VALUE",NSHTTPCookieValue,nil];
    
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:propertiesDict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookie:cookie];
    [_progressHud hide:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    if (size.width > size.height) {
        //可以理解为是横向
        _actionView.hidden = YES;
        _backView.frame = CGRectMake(0, 0, size.width, 40);
        _webView.frame = CGRectMake(0, 0 + _backView.frame.size.height, size.width, size.height - _backView.frame.size.height);
        
    }else {
        _actionView.hidden = NO;
        _backView.frame = CGRectMake(0, 20, size.width, 40);
        _webView.frame = CGRectMake(0, 20 + _backView.frame.size.height, size.width, size.height - 20 - _actionView.frame.size.height - _backView.frame.size.height);
    }
}




-(BOOL)shouldAutorotate {

    return self.canRotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {

    if (self.canRotate) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}


-(BOOL)canRotate {
    
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        //理解为横向
        return YES;
    }
    return _canRotate;
}



-(void)goPresentWebViewWithUrl:(NSString *)urlStr {

    NSURL *cookieHost = [NSURL URLWithString:self.urlStr];
    NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:[cookieHost host],NSHTTPCookieDomain,[cookieHost path],NSHTTPCookiePath,@"COOKIE_NAME",NSHTTPCookieName,@"COOKIE_VALUE",NSHTTPCookieValue,nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:propertiesDict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookie:cookie];
    
    
    
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:self.urlStr]];
    NSEnumerator *enumerator = [cookies objectEnumerator];
    NSHTTPCookie *cookie1;
    while (cookie1 = [enumerator nextObject]) {
        NSLog(@"COOKIE{name: %@, value: %@}", [cookie1 name], [cookie1 value]);
    }
    NSLog(@"----------------------------");
    
    LottyWkWebViewController *vc = [[LottyWkWebViewController alloc]init];
    vc.urlStr = urlStr;
    vc.showTabBar = NO;
    vc.beChildView = YES;
    [self presentViewController:vc animated:YES completion:nil];
}





@end

