---

title: iOS状态栏自定义操作

date: 2018-04-28 10:30:02

tags: iOS

categories: iOS技术

---

## 场景

外层一个 UITableView，内部三个 Tab，即一个横向的 UIScrollView，里面包含三个 UITableView

![](https://github.com/huangzhifei/UtilityKits/raw/master/UtilityKits/TableNestTable-45/tableview.gif)

## 详解

### 1、大体思路

要使用内层的 UITableView（TAB 栏里面）和外层的 UITableView 同时响应用户的手势滑动事件，当用户从页面顶端从下往上滑动到 TAB 栏的过程中，使用外层的 UITableView 跟随用户手势滑动，内层的 UITableView 不跟随手势滑动。当用户继续往上滑动的时候，让外层的 UITableView 不跟随手势滑动，让内层的 UITableView跟随手势滑动，反之从下往上滑动也一样。

外层的 section0 为价格区，可以自定义；
section1 为 sku 区，也可以自定义；
section2 为 TAB 区域，该区域采用 Runtime 反射机制，动态配置完成。


### 2、具体实现

#### 1、UtYXIgnoreHeaderTouchTableView

我们顶部的图片其实是覆盖在外层 UITableView 的 headerView 下面的，我们把 headerView 设置为透明，这样实现是为了方便我们在滑动的时候，动态的改变图片的宽高，实现列表头能够动态拉伸的效果。

但是我们对于 UITableView 不做处理的时候，该图片是无法响应点击事件，因为被 headerView 提前消费掉了这个事件。

所以我们要让 headerView 不消费掉这个响应，让其传给别人处理，我们在 UtYXIgnoreHeaderTouchTableView 中实现 hitTest 方法

```
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (self.tableHeaderView && CGRectContainsPoint(self.tableHeaderView.frame, point)) {
		return NO;
	}
	return [super pointInside:point withEvent:event];
}
```

#### 2、UtYXIgnoreHeaderTouchAndRecognizeSimultaneousTableView

该文件继承于 UtYXIgnoreHeaderTouchTableView，除此之外，主要是为了让外层的 UITableView 能够显示外层 UITableView 的滑动事件，我们增加手势代理方法

```
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
```

#### 3、UtYXTabView

该文件是 TAB 区域主要文件，显示的标题的内容都是通过以下字典动态生成的

```
if(section==2){
	NSArray *tabConfigArray = @[@{
            @"title":@"图文介绍",
            @"view":@"PicAndTextIntroduceView",
            @"data":@"图文介绍的数据",
            @"position":@0
        },
        @{
            @"title":@"商品详情",
            @"view":@"ItemDetailView",
            @"data":@"商品详情的数据",
            @"position":@1
        },
        @{
            @"title":@"评价(273)",
            @"view":@"CommentView",
            @"data":@"评价的数据",
            @"position":@2
         }
    ];
UtYXTabView *tabView = [[UtYXTabView alloc] initWithTabConfigArray:tabConfigArray];
[cell.contentView addSubview:tabView];
}
```

title：TAB每个Item的标题。

view：TAB每个Item的内容。

data：TAB每个Item内容渲染需要的数据。

position：TAB的位置。从0开始。

该 TAB 其实是有 UtYXTabTitleView（标题栏）和一个横向的 ScrollView（内层多个 UITableView 的容器）构成。内层多个 UITableView 通过以上配置文件动态生成。如下如示：

```
for (int i=0; i<tabConfigArray.count; i++) {
	NSDictionary *info = tabConfigArray[i];
	NSString *clazzName = info[@"view"];
	Class clazz = NSClassFromString(clazzName);
	YXTabItemBaseView *itemBaseView = [[clazz alloc] init];
	[itemBaseView renderUIWithInfo:tabConfigArray[i]];
	[_tabContentView addSubview:itemBaseView];
}
```

#### 4、UtYXTabItemBaseView

该文件是内层 UITableView 都应该继承的 BaseView，在该 View 中我们设置了内层 UITableView 具体在什么时机不响应用户滑动事件，什么时机应该响应用户滑动事件，什么时间通知外层 UITableView 响应滑动事件等等功能：

```
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (!self.canScroll) {
		[scrollView setContentOffset:CGPointZero];
	}
	CGFloat offsetY = scrollView.contentOffset.y;
	if (offsetY<0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kLeaveTopNotificationName object:nil userInfo:@{@"canScroll":@"1"}];
		[scrollView setContentOffset:CGPointZero];
		self.canScroll = NO;
		self.tableView.showsVerticalScrollIndicator = NO;
	}
}
```

#### 5、UtPicAndTextIntroduceView、UtItemDetailView、UtCommentView

这三个文件都继承于 UtYXTabItemBaseView，但是在该文件中我们只需要注意 UI 的渲染就可以了。响应事件的管理都在 UtYXTabItemBaseView 做好了。


#### **6、内外层滑动事件的响应和传递**

重点来了：外层 UITableView 在初始化的时候，需要监听一个 NSNotification，该通知是内层 UITableView 传递给外层的，传递时机为从上往下滑动，当 TAB 栏取消置顶的时候，通知外层 UITableView 可以开始滚动了。

```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kLeaveTopNotificationName object:nil];

-(void)acceptMsg : (NSNotification *)notification{
	//NSLog(@"%@",notification);
	NSDictionary *userInfo = notification.userInfo;
	NSString *canScroll = userInfo[@"canScroll"];
	if ([canScroll isEqualToString:@"1"]) {
	_canScroll = YES;
	}
}
```

在 scrollViewDidScroll 方法中，需要实时监控外层 UItableView 的滑动时机。也要在适当时机发送 NSNotification 给内层 UItableView，通知内层 UITableView 是否可以滑动。



```
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat tabOffsetY = [_tableView rectForSection:2].origin.y - kTopBarHeight;
    CGFloat offsetY = scrollView.contentOffset.y;
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    if (offsetY >= tabOffsetY) {
        scrollView.contentOffset = CGPointMake(0, tabOffsetY);
        _isTopIsCanNotMoveTabView = YES;
    } else {
        _isTopIsCanNotMoveTabView = NO;
    }
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            //NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoTopNotificationName
                                                                object:nil
                                                              userInfo:@{ @"canScroll" : @"1" }];
            _canScroll = NO;
        }
        if (_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView) {
            //NSLog(@"离开顶端");
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabOffsetY);
            }
        }
    }
}
```

这样就处理完了嵌套 TableView 的手势问题及滑动时机，完整代码请看 Demo



