//
//  JSExportViewController.h
//  JSInteractive
//
//  Created by 杨晴贺 on 2018/4/19.
//  Copyright © 2018年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJsExport <JSExport>

JSExportAs(test, - (void)nativeCall:(NSString *)msg);

- (void)JSCallObjcParam:(NSString *)param1 with:(NSString *)param2;
- (NSString *)JSCallObjcReturn;
- (void)JSCallObjc;

@end

@interface JSExportViewController : UIViewController<TestJsExport>

@end
