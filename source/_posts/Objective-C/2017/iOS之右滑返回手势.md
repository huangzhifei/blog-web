---

title: iOS之右滑返回手势

date: 2017-05-21 16:13:42

tags: iOS

categories: iOS技术

---

iOS 中以 UINavigationController 为容器的话，系统自带一个屏幕边缘右滑返回上一层的手势，但是当我们自定义了返回按钮之后，这个手势就会自己无效。

如果我们想自定义返回，还需要滑动返回有效，怎么处理了？

### 解决方案

我们在主 ViewController 中加入代理，其他视图都是以此视图为根视图。

```
self.navigationController.interactivePopGestureRecognizer.delegate = self;
```

加入此代码就可以了。

如果无效，查看一下下面代码是否被设置为 NO了（默认是YES）

```
self.navigationController.interactivePopGestureRecognizer.enabled = NO;
```

如果碰到需求在根根视图不能滑动返回，在代理方法里面处理一下

```
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	//关闭主界面的右滑返回
　　if (self.navigationController.viewControllers.count == 1) {
    　　return NO;
   } else {
    　　return YES;
   }
}
```

