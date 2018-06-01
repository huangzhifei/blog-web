---

title: iOS之资讯详情实现-WebView和TableView混合使用

date: 2018-06-01 12:12:55

tags: iOS

categories: iOS技术

---

## 描述

如果要实现一个底部带有相关推荐和评论的资讯详情页，很自然会想到 WebView 和 TableView 嵌套使用的方案！因为评论使用原生体验好，资讯、文章类使用 WebView 动态与高效。

**我们可以很容易想到最简单的实现方案：**

这个方案是 WebView 作为 TableView 的 TableHeaderView 或者 TableView 的一个 Cell，然后根据网页的高度动态的更新 TableHeaderView 和 Cell 的高度，这个方案逻辑上最简单，也最容易实现，而且滑动效果也比较好。

然而在实际应用中发现如果资讯内容很长而且带有大量图片和GIf图片的时候，APP内存占用会暴增，有被系统杀掉的风险。然而在单纯的使用 WebView 的时候内存占用不会那么大，原因是 WebView 会根据自身可视区域的大小动态渲染 HTML 内容，不会一次性的渲染所有的 HTML 内容。这个方案只是简单的将 WebView 的大小更新为 HTML 的实际大小，WebView 将会一次性的渲染所有的 HTML 内容，因此直接使用这种方案会有内存占用暴增的风险。


## 业界主流App的实现方案

### 1、网易新闻

通过 Reveal 查看网易新闻的视图结构，发现整个新闻详情页都是通过 H5 实现的，包括评论、广告和相关推荐

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Netease.jpeg)

## 2、今日头条

今日头条新闻详情页最外层是 ScrollView，WebView 和 ThemedView（里面包含 TableView）是 ScrollView 同级 SubView。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/toutiao.jpeg)

查看 WebView 的布局属性，发现 WebView 并没有被撑开，但是 Y 的坐标是一直在发生变化

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/toutiao1.png)

查看ThemedView的布局属性，发现其Y坐标是也是发生变化的，ThemedView正好位于WebView的下方。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/toutiao2.png)


通过以上分析基本可以推测出头条的解决方案：

1、ScrollView 是作为 ContainerView，WebView 和 TableView 是 ScrollView 的 subview

2、WebView 和 TableView 禁止掉了滚动，WebView 和 TableView 是由 ScrollView 的滚动驱动的，也就是 WebView 和 TableView 无法通过手指直接改变其 contentOffset，他们的 contentOffset 是由 ScrollView 滚动时的 contentOffset 计算得出

3、ScrollView 在滚动过程中，WebView 和 TableView 的位置也是跟着改变的，这样就能保证 WebView 和 TableView 一直保持在可视的位置


### 简书

在[《UIWebView与UITableView的嵌套方案》](https://www.jianshu.com/p/42858f95ab43)一文中，作者是这样描述的：

```

将 webView 作为主体，其加载的 HTML 最后留一个空白 div，用于确定 tableView 的位置。tableView 加到 webView.scrollView 上，在监听到 
webView.scrollView 的内容尺寸变化后，不断调整 tableView 的位置对应于该空白 div 的位置，同时将该 div 的尺寸设置为 tableView 的尺寸。

```

简书是将 TableView 添加到 WebView 的 ScrollView 上，然后通过 UIPanGestureRecognizer 和 UIDynamicAnimator 模拟滚动产生偏移量来驱动 TableView 滑动。但是需要添加空白 div，预留 TableView 的位置，需要控制的逻辑比较复杂、麻烦，作者自己也说了。

### 腾讯新闻

腾讯新闻的实现方案和今日头条的差不多，只是 ScrollView 下比今日头条添加了更多的 SubView，当然如果理清这个方案的基本思路，就不算很复杂。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/tx.png)

### 总结

看了几款主流新闻资讯客户端资讯页的实现方案，从业务需求上来说，今日头条和腾讯新闻的实现方案是最为灵活的。

**实现过程大体如下：**

其实大概的方法在上面已经分析过，现在通过数学的方法精确的说明一下。在我们资讯详情页中，使用WebView渲染网页内容，使用TableView渲染“相关推荐”和“资讯评论”。最外层是一个ScrollView，WebView和TableView平铺在这个ScrollView中。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/webI.png)

### ScrollView 的 ContentSize

由于ScrollView用来滚动视图，ScrollView可以滚动到所有渲染内容，所以ScrollView的contentSize.height可通过以下公式计算（简单来说ScrollView的ContentSizeHeight是WebView和TableView的ContentSize之和）

```
ScrollView.contentSize.height = WebView.contentSize.height + TableView.contentSize.height
```

### ScrollView 的 ContentOffset

单个控件来看：

1、WebView的ContentOffset.y取值范围是：

```
0 ~ (WebView.contentSize.height - WebView.height)
```

2、TableView的ContentOffset.y取值范围是：

```
0 ~ (TableView.contentSize.height - TableView.Height)
```

3、将 WebView 放在 ScrollView 上来看，WebView 可滚动范围，即 ScrollView.contentOffset.y 取值范围：

```
0 ~ (WebView.contentOffset.y - WebView.height)
```

4、将 TableView 放在 ScrollView 上来看，TableView 可滚动范围，即 ScrollView.contentOffset.y 取值范围：

```
(ScrollView.contentSize.height - TableView.contentSize.Height) ~ (ScrollView.contentSize.height - TableView.height)
```

也就是：

```
(WebView.contentSize.height) ~ （WebView.contentSize.height + TableView.ContentSize.height - TableView.height)
```

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/web2.png)

可以看出ScrollView.contentSzie.height将被分为6个的区间段

### WebView 的 Top 和 TableView 的 Top

由于 WebView 和 TableView 没有完全展开，所以 WebView 和 TableView 需要动态改变它们的 Top 值（frame.origin.y），才能使 WebView 处于ScrollView 的可视位置。

所以我们需要在 2 区间改变 WebView.top, 让 WebView 看起来和相对于 ScrollView 可视位置不变（这个时候 WebView 的 ContentOffset.y 是根据ScrollView 的 contentOffset.y 决定的），在2区间段：

```
WebView.contentOffset.y = ScrollView.contentOffset.y
```

同样需要在 4 区间段改变 TableView.Top 使 TableView 看起来相对于 ScrollView 可视位置不变。在 4 区间段：

```
TableView.contentOffset.y = ScrollView.contentOffset.y - WebView.height
```

### WebView 的 Height 和 TableView 的 Height

从上图我们可以看到在 2 和 4 区间段 WebView 和 TableView 分别要发生滚动。因为 TableView 在 WebView 正下方，如果 WebView.height 小于ScrollView.height ，那么在这个区间段下我们能够同时看到 WebView 和 TableView，因为 WebView 正在滚动，TableView 未发生滚动，看起来会十分诡异，在 4区间段情况也是一样的。

* 所以WebView的height在 其contentSize 大于scrollView.height时：WebView.height = scrollView.height即可；
* TableViewView的height在 其contentSize 大于scrollView.height时：TableViewView.height = scrollView.height；
* WebView的height在 其contentSize 小于于scrollView.height时：WebView.height = WebView.contentSize.height;
* TableViewView的height在 其contentSize 小于scrollView.height时：TableViewView.height = TableViewView.contentSize.height;


## 上代码

主要代码如下：


```
#import "UtWebWithTableViewVC.h"
#import <WebKit/WebKit.h>
#import "UIView+UtDimensions.h"

@interface UtWebWithTableViewVC () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIScrollView *containerScrollView;

@property (nonatomic, strong) UIView *contentView;

@end

@implementation UtWebWithTableViewVC {
    CGFloat _lastWebViewContentHeight;
    CGFloat _lastTableViewContentHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WebView和TablView混合使用";
    [self initValue];
    [self initView];

    NSString *path = @"https://www.jianshu.com/p/f31e39d3ce41";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [self.webView loadRequest:request];
    [self addObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initValue {
    _lastWebViewContentHeight = 0;
    _lastTableViewContentHeight = 0;
}

- (void)initView {

    [self.contentView addSubview:self.webView];
    [self.contentView addSubview:self.tableView];

    [self.view addSubview:self.containerScrollView];
    [self.containerScrollView addSubview:self.contentView];

    self.contentView.frame = CGRectMake(0, 0, self.view.width, self.view.height * 2);
    self.webView.top = 0;
    self.webView.height = self.view.height;
    self.tableView.top = self.webView.bottom;
}

#pragma mark - Observers

- (void)addObservers {
    [self.webView addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers {
    [self.webView removeObserver:self forKeyPath:@"scrollView.contentSize"];
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (object == _webView) {
        if ([keyPath isEqualToString:@"scrollView.contentSize"]) {
            [self updateContainerScrollViewContentSize:0 webViewContentHeight:0];
        }
    } else if (object == _tableView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            [self updateContainerScrollViewContentSize:0 webViewContentHeight:0];
        }
    }
}

- (void)updateContainerScrollViewContentSize:(NSInteger)flag webViewContentHeight:(CGFloat)inWebViewContentHeight {

    CGFloat webViewContentHeight = flag == 1 ? inWebViewContentHeight : self.webView.scrollView.contentSize.height;
    CGFloat tableViewContentHeight = self.tableView.contentSize.height;

    if (webViewContentHeight == _lastWebViewContentHeight && tableViewContentHeight == _lastTableViewContentHeight) {
        return;
    }

    _lastWebViewContentHeight = webViewContentHeight;
    _lastTableViewContentHeight = tableViewContentHeight;

    self.containerScrollView.contentSize = CGSizeMake(self.view.width, webViewContentHeight + tableViewContentHeight);

    CGFloat webViewHeight = (webViewContentHeight < self.view.height) ? webViewContentHeight : self.view.height;
    CGFloat tableViewHeight = tableViewContentHeight < self.view.height ? tableViewContentHeight : self.view.height;
    self.webView.height = webViewHeight <= 0.1 ? self.view.height : webViewHeight;
    self.contentView.height = webViewHeight + tableViewHeight;
    self.tableView.height = tableViewHeight;
    self.tableView.top = self.webView.bottom;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_containerScrollView != scrollView) {
        return;
    }

    CGFloat offsetY = scrollView.contentOffset.y;

    CGFloat webViewHeight = self.webView.height;
    CGFloat tableViewHeight = self.tableView.height;

    CGFloat webViewContentHeight = self.webView.scrollView.contentSize.height;
    CGFloat tableViewContentHeight = self.tableView.contentSize.height;

    if (offsetY <= 0) {
        self.contentView.top = 0;
        self.webView.scrollView.contentOffset = CGPointZero;
        self.tableView.contentOffset = CGPointZero;
    } else if (offsetY < webViewContentHeight - webViewHeight) {
        self.webView.scrollView.contentOffset = CGPointMake(0, offsetY);
        self.contentView.top = offsetY;
    } else if (offsetY < webViewContentHeight) {
        self.tableView.contentOffset = CGPointZero;
        self.webView.scrollView.contentOffset = CGPointMake(0, webViewContentHeight - webViewHeight);
    } else if (offsetY < webViewContentHeight + tableViewContentHeight - tableViewHeight) {
        self.contentView.top = offsetY - webViewHeight;
        self.tableView.contentOffset = CGPointMake(0, offsetY - webViewContentHeight);
        self.webView.scrollView.contentOffset = CGPointMake(0, webViewContentHeight - webViewHeight);
    } else if (offsetY <= webViewContentHeight + tableViewContentHeight) {
        self.webView.scrollView.contentOffset = CGPointMake(0, webViewContentHeight - webViewHeight);
        self.tableView.contentOffset = CGPointMake(0, tableViewContentHeight - tableViewHeight);
        self.contentView.top = self.containerScrollView.contentSize.height - self.contentView.height;
    } else {
        //do nothing
        NSLog(@"do nothing");
    }
}

#pragma mark - UITableViewDataSouce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor orangeColor];
    }

    cell.textLabel.text = @(indexPath.row).stringValue;

    return cell;
}

#pragma mark - setter&getter

- (WKWebView *)webView {
    if (_webView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        _webView.scrollView.scrollEnabled = NO;
        _webView.navigationDelegate = self;
    }

    return _webView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (UIScrollView *)containerScrollView {
    if (_containerScrollView == nil) {
        _containerScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _containerScrollView.delegate = self;
        _containerScrollView.alwaysBounceVertical = YES;
        _containerScrollView.backgroundColor = [UIColor grayColor];
    }

    return _containerScrollView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

#pragma mark - dealloc

- (void)dealloc {
    [self removeObservers];
    NSLog(@"dealloc: %@", [self class]);
}

@end

```

"UIView+UtDimensions.h" 这是一个 View 的 Frame 辅助分类，就是一个大众版本。


文章连接：

[iOS资讯详情页实现—WebView和TableView混合使用](https://www.jianshu.com/p/3721d736cf68)

[UIWebView与UITableView的嵌套方案](https://www.jianshu.com/p/42858f95ab43)

