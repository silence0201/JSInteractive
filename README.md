# JSInteractive
JS与iOS交互

近几年移动开发使用网页嵌套的形式越来越多,这就不可避免的出现原生和网页的JS交互,本篇大概总结了一下目前iOS开发中原生控件与JS交互的几种形式

iOS开发中使用的UIWebView空间来加载网页页面资源,所以本文主要围绕这几个空间进行总结,大体分为三种形式: 

1. 原生API交互,直接执行脚本,拦截代理
2. 第三方库WebViewJavaScriptBridge交互,实质上还是拦截代理
3. JavaScriptCore框架

	> 3.1 Context上下文交互  
	> 3.2 JSExport协议,通过挟制设置方法调用

------
### 原生API交互

使用原生API实现交互,是实际上主要用到了一个函数和协议:  

函数为:  

```
- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
```

协议为:

```
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
```

#### 1.OBJC调用JS

首先我们在JS定义一个函数`objcCallJS`:

```
function objcCallJS() {
    var data = 'Hello,World'
    alert('来自objc的调用，有返回值:' + data);
    return data
}
```

调用的话直接用对应的函数调用即可:

```
- (IBAction)callJSAction:(id)sender {
    NSLog(@"开始调用JS函数,有返回值");
    NSString *returnStr = [self.webView stringByEvaluatingJavaScriptFromString:@"objcCallJS()"];
    NSLog(@"返回值为:%@",returnStr);
}
```

如果我们调用的JS代码有返回值的话,就会赋值到`returnStr`变量中,可供我们后续使用  

当然我们也可以传参数给JS函数

JS代码:

```
function objcCallJSParam(param1,param2) {
    alert('来自objc的调用，带有参数:' + param1 + '  ' + param2);
}
```

OC调用代码:

```
- (IBAction)callJSWithParamAction:(id)sender {
    NSLog(@"开始调用JS函数,带有参数");
    [self.webView stringByEvaluatingJavaScriptFromString:@"objcCallJSParam('Hello','World')"];
}
```

#### 2.JS调用OC

原生API需要连接UIWebView的代理来实现,代理`- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType` 会在UIWebView开始加载页面的时候调用,如果我们返回NO则这个页面什么也不会做,如果返回YES则会加载这个页面.我们正式拦截这个来实现JS调用OBJC代码

具体流程:

在页面相应时,重新设置页面的href,并将OBJC所用的参数以及所谓的指定函数,封装成一个指定的格式的URL.然后我们在UIWebView的协议中拦截这个链接,然后解析出来,最后根据固定的格式作出相应的处理

JS代码:

```
function JSCallObjc() {
    window.location.href="alert://我是标题?param=这是参数";
}
```

我们需要在OBJC中这样拦截:

```
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
```

### 第三方库WebViewJavaScriptBridge交互

使用第三方库WebViewJavaScriptBridge,首先需要导入这个第三方库

第三方库直接通过pod引入:

```
pod 'WebViewJavascriptBridge', '~> 6.0'
```

并且需要一个JS固定写法:

```
//固定函数，必须这样写
function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'https://__bridge_loaded__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}

//所有交互的函数都写在这里面
setupWebViewJavascriptBridge(function(bridge) {
	...
})
```

#### 1.OBJC调用JS
首先我们需要在JS中注册一个函数,工OBJC调用:

```
// 注册需要在OC中回调的函数
bridge.registerHandler('objcCallJS', function(data, responseCallback) {
    myAlert(data)
	var responseData = { 'Javascript Says':'Right back atcha!' }
	responseCallback(responseData)
})
```

在OC中我们就可以向下面这样调用了:

```
[self.bridge callHandler:@"objcCallJS" data:@{@"key":@"Hello,World"}];
```

注意:
1. 名称必须对应上
2. OBJC中调用JS的函数是通过`- (void)callHandler:(NSString *)handlerName data:(id)data`这个第三方库提供的接口实现的
3. 调用对应JS函数必须需要注册`bridge.registerHandler('objcCallJS', function(data, responseCallback)`

#### 2.JS调用OBJC
与OBJC调用JS的逻辑类似

首先需要在OBJC中注册JS中能都调用的函数:

```
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
```

注册完后,我们就可以在JS中调用这个注册好的函数:

```
bridge.callHandler('JSCallObjc',{'key': 'Hello,World'})
```

这个逻辑和接口与OBJC调用JS的接口类似,具体参数也差不多.

到此我们可以利用这个第三方库对实现OBJC与JS之间的相互调用,其实这个库内部还是通过拦截协议来实现交互过程的

### JavaScriptCore框架

JavaScriptCore框架是iOS7之后引入的框架,这个框架在JS交互上给我们提供了很大帮助,可以在html界面上调用OC方法,也可以在OC上调用JS方法并传参.使用这个框架需要先导入JavaScriptCore这个框架

#### 1) Context上下文交互

##### 1.OBJC调用JS

OBJC调用JS之前,需要获取JS的上下文:

```
self.context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
```

获取这个上下文之后,我们就可以对JS执行环境处理,加入我们需要调用JS中已经实现的函数,我们可以直接调用对饮改的函数:

```
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
```

以上代码中我们展示了三种不同的调用方式,第三种我们需要从上下文中获取要执行的方法,并将它保存到一个JSValue变量中,然后调用函数获取对应的返回值

##### 2.JS调用OBJC
首先我们需要在上下中注册我们需要执行的OBJC方法:

```
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
```

执行完后我们就可以在JS中调用我们注册的方法:

```
//调用OBJC
function callObjcParam(param1,param2) {
    var data = JSCallObjcParam('Hello','World')
    alert('来自objc(callObjcParam)的返回值:' + data);
}
function callObjc() {
    var data = JSCallObjc()
    alert('来自objc(callObjc)的返回值:' + data);
}
    
function callObjcReturn() {
    var data = JSCallObjcReturn()
    alert('来自objc(callObjcReturn)的返回值:' + data);
}
```

Demo中分别实现了相互调用的传参和不传参,有返回值和没有返回值的情况.完整代码请看Demo

#### 2) JSExport结合上下文交互

JSExport是一个协议,我们可以直接定义一个协议,继承这个协议,在协议中声明可以在JS用的OBJC函数

```
@protocol TestJsExport <JSExport>

JSExportAs(test, - (void)nativeCall:(NSString *)msg);

- (void)JSCallObjcParam:(NSString *)param1 with:(NSString *)param2;
- (NSString *)JSCallObjcReturn;
- (void)JSCallObjc;

@end
```

`JSExportAs`提供了对接口重新命名的快速定义

在这里我们需要知道的是,这个协议所晟敏改的接口都是提供JS调用的,也就是JS代码调用的OBJC的相关借楼,可以放在这个协议中,而OBJC调用JS还是通过上下文调用:

我们需要实现一个类,实现我们自定义的协议:

```
@interface JSExportViewController : UIViewController<TestJsExport>

@end
```

然后实现这些接口:

```
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
```

然后我们需要让JS知道我们所需的函数,这个时候需要注册下上下文:

```
// 注册命名空间
self.context[@"OBJC"] = self;
```

这样,我们就在JS注册上了对应的命名空间对应上的就是`self`实现的相关方法,我们在JS调用如下:

```
//调用OBJC
function callObjcParam(param1,param2) {
    var data = OBJC.JSCallObjcParamWith('Hello','World')
    alert('来自objc(callObjcParam)的返回值:' + data);
}
function callObjc() {
    var data = OBJC.JSCallObjc()
    alert('来自objc(callObjc)的返回值:' + data);
}
    
function callObjcReturn() {
    var data = OBJC.JSCallObjcReturn()
    alert('来自objc(callObjcReturn)的返回值:' + data);
}

function callTestNoReturn() {
    var data = OBJC.test('Hello,World')
    alert('来自objc(callTestNoReturn)的返回值:' + data);
}
```

这样实现就可以实现JS调用OBJC

-------

Demo详见项目文件

