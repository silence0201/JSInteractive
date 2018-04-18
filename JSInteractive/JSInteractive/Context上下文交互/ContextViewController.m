//
//  ContextViewController.m
//  JSInteractive
//
//  Created by Silence on 2018/4/18.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "ContextViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ContextViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) JSContext *context;

@end

@implementation ContextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"ContextAPI" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)callJSAction:(id)sender {
    NSLog(@"开始调用JS函数,有返回值");
    
    //第一种
    /*
    NSString *returnStr = [self.webView stringByEvaluatingJavaScriptFromString:@"objcCallJS()"];
    NSLog(@"返回值为:%@",returnStr);
     */
    
    //第二种
    /*
    NSString *js = @"objcCallJS()";
    JSValue *value = [self.context evaluateScript:js];
    NSLog(@"%@",[value toString]);
     */
    
    //第三种
    JSValue *valueFuc = self.context[@"objcCallJS"];
    JSValue *value = [valueFuc callWithArguments:nil];
    NSLog(@"%@",[value toString]);
}

- (IBAction)callJSNoReturnAction:(id)sender {
    NSLog(@"开始调用JS函数,没有返回值");
    
    //第一种
    /*[self.webView stringByEvaluatingJavaScriptFromString:@"objcCallJSNoReturn()"];*/
    
    //第二种
    /*
    NSString *js = @"objcCallJSNoReturn()";
    JSValue *value = [self.context evaluateScript:js];
    NSLog(@"%@",[value toString]);
    */
    
    //第三种
    JSValue *valueFuc = self.context[@"objcCallJSNoReturn"];
    JSValue *value = [valueFuc callWithArguments:nil];
    NSLog(@"%@",[value toString]);
}

- (IBAction)callJSWithParamAction:(id)sender {
    NSLog(@"开始调用JS函数,带有参数");
    
    //第一种
    /*[self.webView stringByEvaluatingJavaScriptFromString:@"objcCallJSParam('ljt','ths')"];*/
    
    //第二种
    /*
    NSString *js = @"objcCallJSParam('ljt','ths')";
    JSValue *value = [self.context evaluateScript:js];
    NSLog(@"%@",[value toString]);
    */
    
    //第三种
    JSValue *valueFuc = self.context[@"objcCallJSParam"];
    JSValue *value = [valueFuc callWithArguments:@[@"ljt",@"ths"]];
    NSLog(@"%@",[value toString]);
}

#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.context) {
        self.context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    }
    [self registMethods];
}

- (void)registMethods {
    __weak typeof(self) weakSelf = self;
    self.context[@"JSCallObjcParam"] = (id)^(NSString *param1, NSString *param2) {
        NSLog(@"有参，无返回值");
        NSString *message = [NSString stringWithFormat:@"%@:%@",param1,param2];
        UIAlertController *alterVC = [UIAlertController alertControllerWithTitle:@"objc弹框" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alterVC addAction:okAction];
        [weakSelf presentViewController:alterVC animated:YES completion:nil];
    };
    
    self.context[@"JSCallObjc"] = ^(){
        NSLog(@"无参，无返回值");
    };
    self.context[@"JSCallObjcReturn"] = ^(){
        NSLog(@"无参，有返回值");
        return @"ljt";
    };
}

@end
