---

title: iOS13适配

date: 2019-08-05 16:28:20

tags: iOS

categories: iOS技术

---

## iOS 13 系统禁止通过 KVC 访问

### 1、UITextField

```
UITextField *textField = [UITextField new];
[textField valueForKey:@"_placeholderLabel"];
```

系统的 UITextField 重写了 valueForKey: 拦截了外部的取值，实现如下:

```
@implementation UITextField

- (id)valueForKey:(NSString *)key {
    if ([key isEqualToString:@"_placeholderLabel"]) {
        [NSException raise:NSGenericException format:@"Access to UITextField's _placeholderLabel ivar is prohibited. This is an application bug"];
    }
    [super valueForKey:key];
}

@end
```
简单解决：
去掉下划线即可 `[textField valueForKey:@"placeholderLabel"];`

### 2、UISearchBar

```
UISearchBar *bar = [UISearchBar new];
[bar setValue:@"test" forKey:@"_cancelButtonText"]
UIView *searchField = [bar valueForKey:@"_searchField"];
```

根据 KVC 的实现，会先去找名为 set_cancelButtonText 的方法，所以系统内部重写了这个方法，什么事都不干，专门用来拦截 KVC，实现如下：

```
- (void)set_cancelButtonText:(NSString *)text {
    [NSException raise:NSGenericException format:@"Access to UISearchBar's set_cancelButtonText: ivar is prohibited. This is an application bug"];
    [self _setCancelButtonText];
}
```

拦截 _searchField：

```
- (void)_searchField {
    [NSException raise:NSGenericException format:@"Access to UISearchBar's _searchField ivar is prohibited. This is an application bug"];
    [self searchField];
}
```
简单解决：
直接调用 `_setCancelButtonText, searchField`

根据上面提到的原理，这里提供一种全局绕过这个禁止的方法供参考。
请注意：这只是一种临时的参考方案，我们 不推荐 开发者这么做， 因为访问私有属性会带来了不确定和不稳定性，少了苹果的警告会让你无节制去访问使用各种属性，随着系统的升级这私有属性会面临改动和失效的风险。

```
@implementation NSException (DisableUIKVCAccessProhibited)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getClassMethod(self, @selector(raise:format:));
        Method swizzlingMethod = class_getClassMethod(self, @selector(sw_raise:format:));
        method_exchangeImplementations(originalMethod, swizzlingMethod);
        
    });
}

+ (void)sw_raise:(NSExceptionName)raise format:(NSString *)format, ... {
    if (raise == NSGenericException && [format isEqualToString:@"Access to %@'s %@ ivar is prohibited. This is an application bug"]) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    NSString *reason =  [[NSString alloc] initWithFormat:format arguments:args];
    [self sw_raise:raise format:reason];
    va_end(args);
}

@end
```

### 3、推送的 deviceToken 获取到的格式发生变化

原本可以直接将 NSData 类型的 deviceToken 转换成 NSString 字符串，然后替换掉多余的符号即可：

```
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [deviceToken description];
    for (NSString *symbol in @[@" ", @"<", @">", @"-"]) {
        token = [token stringByReplacingOccurrencesOfString:symbol withString:@""];
    }
    NSLog(@"deviceToken:%@", token);
}
```

在 iOS 13 中，这种方法已经失效，NSData类型的 deviceToken 转换成的字符串变成了：

```
{length = 32, bytes = 0xd7f9fe34 69be14d1 fa51be22 329ac80d ... 5ad13017 b8ad0736 } 
```

**解决方案**

需要进行一次数据格式处理，[友盟](https://developer.umeng.com/docs/66632/detail/126489)提供了一种做法，可以适配新旧系统：

```
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    const unsigned *tokenBytes = [deviceToken bytes];
    // 数据格式处理
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"deviceToken:%@", hexToken);
}

```

但是注意到这种方法限定了长度，而[官网文档](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622958-application?language=objc)对此方法的说明中提到，APNs device tokens are of variable length. Do not hard-code their size. ，因此可以对数据格式处理部分进行优化：

```
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (![deviceToken isKindOfClass:[NSData class]]) {
        return;
    }
    NSMutableString *deviceTokenString = [NSMutableString string];
    const unsigned char *tokenBytes = deviceToken.bytes; 
    NSInteger count = deviceToken.length;
    
    // 数据格式处理
    NSMutableString *hexToken = [NSMutableString string];
    for (int i = 0; i < count; ++i) {
        [hexToken appendFormat:@"%02x", tokenBytes[i]];
    }
    NSLog(@"deviceToken:%@", hexToken);
}
```

### 4、还有不少需要适配的地址详见下面的地址

[iOS 13 适配要点总结](https://juejin.im/post/5d8af88ef265da5b6e0a23ac)

