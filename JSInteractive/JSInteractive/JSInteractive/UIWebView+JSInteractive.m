//
//  UIWebView+JSInteractive.m
//  JSInteractive
//
//  Created by Silence on 2018/4/24.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import "UIWebView+JSInteractive.h"
#import <objc/runtime.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

const char *JSBridge = "JSBridge";
@implementation UIWebView (JSInteractive)

    
- (void)enableInteractive {
    WebViewJavascriptBridge *bridge = objc_getAssociatedObject(self, JSBridge);
    if (bridge) return ;
#ifdef DEBUG
    [WebViewJavascriptBridge enableLogging];
#endif
    bridge = [WebViewJavascriptBridge bridgeForWebView:self];
    objc_setAssociatedObject(self, JSBridge, bridge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
- (void)setWebViewDelegate:(id)delegate {
    WebViewJavascriptBridge *bridge = objc_getAssociatedObject(self, JSBridge);
    if (!bridge) {
        [self enableInteractive];
        bridge = objc_getAssociatedObject(self, JSBridge);
    }
    [bridge setWebViewDelegate:delegate];
}
    
- (void)JS_registerNative:(NSString*)handlerName handle:(OBJCHandler)handler{
    WebViewJavascriptBridge* bridge = objc_getAssociatedObject(self, JSBridge);
    if (!bridge) {
        [self enableInteractive];
        bridge = objc_getAssociatedObject(self, JSBridge);
    }
    
    [bridge registerHandler:handlerName handler:^(id data, WVJBResponseCallback responseCallback) {
        id resposeData = handler(data);
        responseCallback(resposeData);
    }];
}
    
- (void)JS_executeJS:(NSString*)handlerName data:(id)data callback:(Callback)callback{
    WebViewJavascriptBridge* bridge = objc_getAssociatedObject(self, JSBridge);
    if (!bridge) {
        [self enableInteractive];
        bridge = objc_getAssociatedObject(self, JSBridge);
    }
    
    [bridge callHandler:handlerName data:data responseCallback:callback];
}
    
@end
