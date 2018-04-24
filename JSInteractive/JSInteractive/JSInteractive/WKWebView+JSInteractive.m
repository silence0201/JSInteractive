//
//  WKWebView+JSInteractive.m
//  JSInteractive
//
//  Created by Silence on 2018/4/24.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "WKWebView+JSInteractive.h"
#import <objc/runtime.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

const char *JSWKBridge = "JSWKBridge";
@implementation WKWebView (JSInteractive)

- (void)enableInteractive {
    WKWebViewJavascriptBridge *bridge = objc_getAssociatedObject(self, JSWKBridge);
    if (bridge) return ;
#ifdef DEBUG
    [WKWebViewJavascriptBridge enableLogging];
#endif
    bridge = [WKWebViewJavascriptBridge bridgeForWebView:self];
    objc_setAssociatedObject(self, JSWKBridge, bridge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setWebViewDelegate:(id)delegate {
    WKWebViewJavascriptBridge *bridge = objc_getAssociatedObject(self, JSWKBridge);
    if (!bridge) {
        [self enableInteractive];
        bridge = objc_getAssociatedObject(self, JSWKBridge);
    }
    [bridge setWebViewDelegate:delegate];
}

- (void)JS_registerNative:(NSString *)handlerName handle:(WKOBJCHandler)handler {
    WKWebViewJavascriptBridge *bridge = objc_getAssociatedObject(self, JSWKBridge);
    if (!bridge) {
        [self enableInteractive];
        bridge = objc_getAssociatedObject(self, JSWKBridge);
    }
    
    [bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
        id resposeData = handler(data);
        responseCallback(resposeData);
    }];
}


- (void)JS_executeJS:(NSString *)handlerName data:(id)data callback:(WKCallback)callback {
    WKWebViewJavascriptBridge *bridge = objc_getAssociatedObject(self, JSWKBridge);
    if (!bridge) {
        [self enableInteractive];
        bridge = objc_getAssociatedObject(self, JSWKBridge);
    }
    [bridge callHandler:handlerName data:data responseCallback:callback];
}

@end
