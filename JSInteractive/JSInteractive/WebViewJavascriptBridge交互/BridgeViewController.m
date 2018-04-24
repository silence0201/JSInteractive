//
//  BridgeViewController.m
//  JSInteractive
//
//  Created by Silence on 2018/4/23.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "BridgeViewController.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

@interface BridgeViewController ()<UIWebViewDelegate>
    
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) WebViewJavascriptBridge *bridge;

@end

@implementation BridgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"BrigeAPI" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self registMethods];
}
    
- (IBAction)callJSAction:(id)sender {
    NSLog(@"开始调用JS函数,有返回值");
    
    //callHandler有几种形式
    /*
    - (void)callHandler:(NSString *)handlerName 只调用函数
    - (void)callHandler:(NSString *)handlerName data:(id)data 调用的同时携带数据
    - (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback 不但调用和携带数据，而且设置回调函数处理所需的数据(如果需要处理结果数据)
        [self.bridge callHandler:@"objcCallJS" data:@{@"key":@"value"} responseCallback:^(id responseData){
            NSLog(@"%@",responseData);
        }];
        [self.bridge callHandler:@"objcCallJS"];
     */
    [self.bridge callHandler:@"objcCallJS" data:@{@"key":@"Hello,World"}];
}
    
- (IBAction)callJSNoReturnAction:(id)sender {
    NSLog(@"开始调用JS函数,没有返回值");
}
    
- (IBAction)callJSWithParamAction:(id)sender {
    NSLog(@"开始调用JS函数,带有参数");
}
    
#pragma -- 注册方法OC方法
- (void)registMethods {
    //注册js调用函数，并设定回调。js中可以调用JSCallObjc的函数
    [self.bridge registerHandler:@"JSCallObjc" handler:^(id data, WVJBResponseCallback responseCallback){
        NSString *paramStr = [data objectForKey:@"key"];
        UIAlertController *alterVC = [UIAlertController alertControllerWithTitle:@"objc弹框" message:paramStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alterVC addAction:okAction];
        [self presentViewController:alterVC animated:YES completion:nil];
        responseCallback(@"Response from testObjcCallback");
    }];
}


@end
