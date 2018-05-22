---

title: React Native之外边距与内边距

date: 2018-03-01 10:42:36

tags: RN

categories: React Native

---

## 边距

对于外边距（margin）和内边距（padding）可以很直观的看下图：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/margin和padding.png)


### 注意

### 垂直外边距叠加

垂直方向上的外边距会叠加，假设有 3 个段落，前后相接，他们的规则都如下：

{
	height: 50px;
	border: 1px;
	backgroundColor: #FFFFFF
	marginTop: 50px
	marginBottom: 50px
}

由于第一段的下外边距与第二段的上外边距相邻，可能自然就会认为他们之间的外边距是80（50+30），但是你错了，他们实际是 50，像这种上下外边距相遇时，他们就会相互重叠，直到一个外边距碰到另一个元素的边框，就上面例子：
第二段较宽的上外边距会碰到第一段的边框，也就是说，较宽的外边距决定两个元素最终离多远，没错 50 像素。这个过程就叫外边距叠加。

### 水平外边距不叠加

叠加的只是垂直外边距，水平外边距不叠加。对于水平相邻的元素，它们的水平间距是相邻外边距之和。

