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