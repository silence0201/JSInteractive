//
//  NativeAPIViewController.m
//  JSInteractive
//
//  Created by Silence on 2018/4/17.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "NativeAPIViewController.h"

@interface NativeAPIViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation NativeAPIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"原生API交互";
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"NativeAPI" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    self.webView.delegate = self;
    [self.webView loadRequest:urlRequest];
}

- (IBAction)callJSAction:(id)sender {
    NSLog(@"开始调用JS函数,有返回值");
    NSString *returnStr = [self.webView stringByEvaluatingJavaScriptFromString:@"objcCallJS()"];
    NSLog(@"返回值为:%@",returnStr);
}

- (IBAction)callJSNoReturnAction:(id)sender {
    NSLog(@"开始调用JS函数,没有返回值");
    [self.webView stringByEvaluatingJavaScriptFromString:@"objcCallJSNoReturn()"];
}

- (IBAction)callJSWithParamAction:(id)sender {
    NSLog(@"开始调用JS函数,带有参数");
    [self.webView stringByEvaluatingJavaScriptFromString:@"objcCallJSParam('Hello','World')"];
}

#pragma mark -- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"将要开始加载页面");
    NSURLComponents *components = [NSURLComponents componentsWithURL:[request URL] resolvingAgainstBaseURL:YES];
    
    // 在这里定义某种协议,对URL进行判断
    if ([[components scheme] isEqualToString:@"alert"]) {
        NSString *title = components.host;
        NSString *msg = components.query;
        UIAlertController *alterVC = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alterVC addAction:okAction];
        [self presentViewController:alterVC animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"开始加载页面");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"页面加载完成");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"页面加载失败");
}

@end
