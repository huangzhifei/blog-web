---
title: iOS之多window总结

date: 2018-02-01 18:07:58

tags: iOS

categories: iOS技术
---

## 概述

默认情况下，iOS App 只有一个 UIWindow，也就是在 applicationDidFinishLaunching 里面创建出来的。

但是即使我们什么也不做，在我们的 App 里面也会有其他的 UIWindow：

1、键盘对应的 UITextEffectWindow

2、状态栏对应的 UIStatusBarWindow

但是上面两种 UIWindow 我们基本是没法去操作与更改，所以我们想到要创建多个 UIWindow，场景:

1、全局的 HUD，Alert 等

2、需要展示的界面要盖住 UIStatusBar

对于第一种，我们可以不新建一个 UIWindow 实例，只需要添加到 keyWindow上面。但是这样有个坑：

1、iOS8 之前，UIWindow 的 bounds 不会随着旋转而改变的，需要他的 rootViewController 去处理，所以我们一般都设置一个 rootViewController

对于第二种，创建一个 UIWindow 盖住 UIStatusBar 上面，只需要设置 windowLevel 大于 UIWindowStatusBar 就行，疑问：

1、我们并没有 addSubview，他是怎么显示的？

2、UIStatusBar 是系统级别的，而我们只是在应用内添加了一个 UIWindows 却能影响他？

其实大家都知道 CALayer 有一个 zIndex 的属性，三维的概念，通过这个值来调整视频渲染的前后关系，zIndex 越大视图越靠前，也就是最上面。


## 注意

1、我们最好通过 window.rootViewController.view 去添加子 view，而不是通过 window 本身去添加，理由如下：

	a、上面也说过 window 本身在某些版本不处理旋转。
	
	b、iOS9 以后，苹果推荐每个 UIWindow 都必须有一个 rootViewController，否则在启动过程使用了不包含 		rootViewController 的 UIWindow 中会导致必现的 crash。
	
2、学习 JDStatusBarNotification 的源码还是蛮不错的。

