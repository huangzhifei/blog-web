---

title: iOS状态栏自定义操作

date: 2018-01-31 15:30:02

tags: iOS

categories: iOS技术

---


有时候，我们想在状态上显示一些自定义的信息，比如显示正在发送之类的，告诉用户正在处理。

我们自定义一个状态栏，里面就简单的含一个显示信息的label



```
@interface CustomStatusBar : UIWindow
{
    UILabel *_messageLabel;
}

- (void)showStatusMessage:(NSString *)message;
- 
- (void)hide;

@end
```

我们设置其大小和系统状态栏一致，假设让其背景为黑色:

```
self.frame = [UIApplication sharedApplication].statusBarFrame;
self.backgroundColor = [UIColor blackColor];
```


为了能让自定义的状态栏让用户看到，我们还需要设置他的  windowLevel

在 iOS 中, windowLevel 属性决定了 UIWindow 的显示层次，默认的 windowLevel 为 UIWindowLevelNormal，那为 0，系统定义了三个层次：

```
UIKIT_EXTERN const UIWindowLevel UIWindowLevelNormal;
UIKIT_EXTERN const UIWindowLevel UIWindowLevelAlert;
UIKIT_EXTERN const UIWindowLevel UIWindowLevelStatusBar __TVOS_PROHIBITED;

typedef CGFloat UIWindowLevel;
```

为了能够覆盖系统默认的状态栏，我们把自定义的状态栏 windowLevel 调高点

```
self.windowLevel = UIWindowLevelStatusBar + 1.0;
```

注意 UIWindow 是不需要使用 addSubview 去添加才显示的，他是通过 zIndex 控制的，也就是上面的 UIWindowLevel

最后给他添加一个基本的动画吧：

```
- (void)showStatusMessage:(NSString *)message {
    self.hidden = NO;
    self.alpha = 1.0f;
    _messageLabel.text = @"";
    
    CGSize totalSize = self.frame.size;
    self.frame = (CGRect){ self.frame.origin, 0, totalSize.height };
    
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = (CGRect){ self.frame.origin, totalSize };
    } completion:^(BOOL finished) {
        _messageLabel.text = message;
    }];
}

- (void)hide {
    self.alpha = 1.0f;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _messageLabel.text = @"";
        self.hidden = YES;
    }];
}
```

这样一个最基本的状态栏 tip 就完成了。

最后推荐一个三方很不错的状态栏通知库 [JDStatusBarNotification](https://github.com/calimarkus/JDStatusBarNotification)