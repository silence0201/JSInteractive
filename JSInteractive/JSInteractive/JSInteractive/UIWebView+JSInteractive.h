//
//  UIWebView+JSInteractive.h
//  JSInteractive
//
//  Created by Silence on 2018/4/24.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Callback)(id responseData);
typedef id (^OBJCHandler)(id data);

@interface UIWebView (JSInteractive)

// 使用这个设置代理,会自动开启JS交互
- (void)setWebViewDelegate:(id)delegate;
    
- (void)JS_registerNative:(NSString*)handlerName handle:(OBJCHandler)handler;
- (void)JS_executeJS:(NSString*)handlerName data:(id)data callback:(Callback)callback;

    
@end
