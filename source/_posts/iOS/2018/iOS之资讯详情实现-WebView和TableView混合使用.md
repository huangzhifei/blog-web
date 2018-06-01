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



