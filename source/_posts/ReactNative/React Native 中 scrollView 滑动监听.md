---

title: React Native 中 scrollView 滑动监听

date: 2018-04-27 16:13:35

tags: RN

categories: React Native

---

## 场景

我们常见的 App 很多都有上滑时改变 NavigationBar 颜色的功能，在原生上面好弄，在 React Native 上面怎么处理了？

## React Native 处理

基础上都是列表滑动需要处理，所以我们针对 scrollView 来处理

### 1、onScroll

scrollView 有一个 onScroll 的架设函数，带有一个参数 event，此参数中就包含有滑动的距离，上滑时为负，下滑时为正

```
<View style = {{flex: 1}}>
                <ListView dataSource = {this.state.dataSource}
                          enableEmptySections = {true}
                          renderRow = {(data, sectionID, rowID) => this.renderRow(data, sectionID, rowID)}
                          renderSeparator = {(sectionID, rowID) => this.renderSeparator(sectionID, rowID)}
                          onScroll = {(event) => {
                              console.log('(x, y): ' + event.nativeEvent.contentOffset.x + ', ' + event.nativeEvent.contentOffset.y);
                          }}
                          scrollEventThrottle = {16}
                          refreshControl = {
                              <RefreshControl refreshing = {this.state.isLoading}
                                              onRefresh = {() => this.loadData()}
                                              title = {'加载中...'}/>
                          }>
                </ListView>
            </View>
```

我们只需要在他提供的回调里面处理就行了。


### 2、scrollEventThrottle

对于 scrollEventThrottle ，他只在 iOS 上面有效，指的是 onScroll 回调的频率，每秒回调的次数，默认是0，表示每秒回调1次，值越高，每秒回调次数就越多，也就意味着更精确，但是更耗资源。


