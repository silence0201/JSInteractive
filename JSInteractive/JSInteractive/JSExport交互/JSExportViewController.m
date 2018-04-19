//
//  JSExportViewController.m
//  JSInteractive
//
//  Created by Silence on 2018/4/19.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "JSExportViewController.h"


@interface JSExportViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) JSContext *context;

@end

@implementation JSExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"JSExportAPI" ofType:@"html"];
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

#pragma mark -- 注册的Action
- (void)JSCallObjcParam:(NSString *)param1 with:(NSString *)param2 {
    NSLog(@"有参，无返回值");
    NSString *message = [NSString stringWithFormat:@"%@:%@",param1,param2];
    UIAlertController *alterVC = [UIAlertController alertControllerWithTitle:@"objc弹框" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alterVC addAction:okAction];
    [self presentViewController:alterVC animated:YES completion:nil];
}

- (void)JSCallObjc {
    NSLog(@"无参，无返回值");
}

- (NSString *)JSCallObjcReturn {
    NSLog(@"无参，有返回值");
    return @"ljt";
}

- (void)nativeCall:(NSString *)msg {
    NSLog(@"NativeCall:%@",msg);
}


#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.context) {
        self.context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    }
    
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        [JSContext currentContext].exception = exception;
        NSLog(@"Exception:%@",exception);
    };
    
    // 注册命名空间
    self.context[@"OBJC"] = self;
}


@end
