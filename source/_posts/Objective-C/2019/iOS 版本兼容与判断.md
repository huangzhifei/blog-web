---

title: iOS 版本兼容与判断

date: 2019-03-22 17:41:06

tags: iOS

categories: iOS技术

---

## 直接获取系统版本

```

NSString *version = [UIDevice currentDevice].systemVersion;
if (version.doubleValue >= 9.0) {
    // 针对 9.0 以上的iOS系统进行处理
} else {
    // 针对 9.0 以下的iOS系统进行处理
}

```

## 通过 Foundation 框架版本号

通过 NSFoundationVersionNumber 判断API 的兼容性。

### 定义

定义文件路径：`#import<Foundation/NSObjecRuntime.h>`

```

#define NSFoundationVersionNumber10_0	397.40
#define NSFoundationVersionNumber10_1	425.00
#define NSFoundationVersionNumber10_1_1	425.00
#define NSFoundationVersionNumber10_1_2	425.00
#define NSFoundationVersionNumber10_1_3	425.00
#define NSFoundationVersionNumber10_1_4	425.00
#define NSFoundationVersionNumber10_2	462.00
#define NSFoundationVersionNumber10_2_1	462.00
#define NSFoundationVersionNumber10_2_2	462.00
#define NSFoundationVersionNumber10_2_3	462.00
#define NSFoundationVersionNumber10_2_4	462.00
#define NSFoundationVersionNumber10_2_5	462.00
#define NSFoundationVersionNumber10_2_6	462.00
#define NSFoundationVersionNumber10_2_7	462.70
#define NSFoundationVersionNumber10_2_8	462.70

```

## 系统宏

### __IPHONE_OS_VERSION_MAX_ALLOWED

当前开发环境版本（当前开发环境的系统SDK版本）

```

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
// 当前开发环境版本在iOS8.0及以上则编译此部分代码
#else
// 如果低于iOS8.0则编译此部分代码
#endif

```

注意：这里最好不要这样去判定一个方法或属性是否可用！此处在编译后已经确定是否包含此部分代码，因为它依赖的是当前的开发环境，而不是当前系统环境，它运行在编译时而不是运行时，所以经过打包后，此处就不会变了，在一些特殊情况下会造成严重问题！慎用！！

### __IPHONE_OS_VERSION_MIN_REQUIRED

系统最低支持版本（也就是当前项目选择的最低版本）

```
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
// 如果选择(iOS Deployment Target)的最低支持版本在iOS8.0及以上才可以使用
- (void)execute;
#endif

```

## 系统版本宏

系统版本宏可以判断当前系统版本是否是大于等于某个版本

```

#define __IPHONE_8_0      80000
#define __IPHONE_8_1      80100
#define __IPHONE_8_2      80200
#define __IPHONE_8_3      80300
#define __IPHONE_8_4      80400
#define __IPHONE_9_0      90000
#define __IPHONE_9_1      90100
#define __IPHONE_9_2      90200
#define __IPHONE_9_3      90300
#define __IPHONE_10_0    100000
#define __IPHONE_10_1    100100
#define __IPHONE_10_2    100200
#define __IPHONE_10_3    100300
#define __IPHONE_11_0    110000
#define __IPHONE_11_1    110100
#define __IPHONE_11_2    110200
......

```


```

#ifdef __IPHONE_8_0
// 系统版本大于 iOS8.0 执行
#endif

#ifdef __IPHONE_10_0
// 系统版本大于 iOS10.0 执行
#endif

```

## @available 运行时检查

```

if (@available(iOS 11, *)) { // >= 11
    NSLog(@"iOS 11");
} else if (@available(iOS 10, *)) { //>= 10
    NSLog(@"iOS 10");
} else { // < 10
    NSLog(@" < iOS 10");
}  
    
```

