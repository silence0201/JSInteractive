//
//  WKWebView+JSInteractive.h
//  JSInteractive
//
//  Created by Silence on 2018/4/24.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import <WebKit/WebKit.h>


typedef void (^WKCallback)(id responseData);
typedef id (^WKOBJCHandler)(id data);
@interface WKWebView (JSInteractive)

// 使用这个设置代理,会自动开启JS交互
- (void)setWebViewDelegate:(id)delegate;

- (void)JS_registerNative:(NSString*)handlerName handle:(WKOBJCHandler)handler;
- (void)JS_executeJS:(NSString*)handlerName data:(id)data callback:(WKCallback)callback;

@end
