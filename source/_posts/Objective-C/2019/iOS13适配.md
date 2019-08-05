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

