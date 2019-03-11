---

title: iOS navigationItem titleView 居中

date: 2019-03-11 15:45:50

tags: iOS

categories: iOS技术

---


## iOS 11 以前

在 iOS 11 以前要让自定义标题居中，那就是蛋疼的一地了。

1、首先要知道 leftBarButtonItems 与 rightBarButtonItems 的个数，因为他会影响标题的位置。

2、要算出标题的实际大小（含有富文本和多行）。

3、在合适的机会以屏幕为中心计算标题相对屏幕中心的坐标。


我们为了不耦合控制器，我们把细节封装到内部，我们就假设自己不知道 leftBarButtonItems 与 rightBarButtonItems 的个数，都假设为 1 个（大小大约为 66）。

然后我们使用 sizeThatFits 去计算出实际的大小，这里有富文本和多行使用 sizeToFit 计算不准确。

最后我们在 layoutSubviews 里面去改变其 frame，让其居中。

代码：

```

// 暴露 API，外部调用，用来设置标题的

if (@available(iOS 11, *)) {
    // 走 AutoLayout 了
} else {
    self.titleSize = [self.nameLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 66 * 2, 44)];
    // 标记为需要 layout (iOS 11以下需要标记)
    [self setNeedsLayout];
}

// 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGSizeEqualToSize(self.titleSize, CGSizeZero)) {
        if (@available(iOS 11, *)) {
            // iOS 11 及以上系统走的是自动布局，设置这里没用
            NSLog(@"do nothing");
        } else {
            // x 轴相对屏幕中心的偏移
            CGFloat title_x = ([UIScreen mainScreen].bounds.size.width * 0.5 - self.origin.x - self.titleSize.width * 0.5) + 0.5;
            // y 轴相对屏幕中心的偏移
            CGFloat title_y = (44 - self.titleSize.height) * 0.5;
            [self.nameLabel setFrame:CGRectMake(title_x, title_y, self.titleSize.width + 1, self.titleSize.height + 1)];
        }
    }
}


```




## iOS 11及以后

在 iOS 11 及以后，系统改变了 navigationItem 的 titleView 的位置及布局方式，他不在 UINavigationBar 的视图层级了，而是加到了 UINavigationBarContentView 上面了。他使用了 AutoLayout，这样一来反而简单了，自定义一个 UIView 后，直接赋值，里面做好 autoLayout，就搞定了。

```

if (@available(iOS 11, *)) {
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }

```

nameLabel （nameLabel 是可以设置多行或富文本的）作为 customTitleView 的载体，外面调用地方：

```

// 添加自定义titleview
self.navigationItem.titleView = self.navTitleView;

```

或者碰到宽度没有正常拉伸的，使用下面方式即可。

```

- (CGSize)intrinsicContentSize {
	return UILayoutFittingExpandedSize;
}

```

