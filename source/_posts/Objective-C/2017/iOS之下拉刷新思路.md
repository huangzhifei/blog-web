---
title: iOS之下拉刷新思路

date: 2017-07-10 11:37:42

tags: iOS

categories: iOS技术

---

其实下拉刷新一般都是用 KVO 监听 contentOffset 的改变，在配合上 UIScrollViewDelegate 的下面几个代理方法

	- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
	- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
	- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
	- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;


1、任何contentOffset的变化都会触发 scrollViewDidScroll 的回调

2、用户停止拖拽时会触发 scrollViewDidEndDragging:willDecelerate:

3、如果 decelerate 为真，触发 scrollViewWillBeginDecelerating:

4、并且在停止时触发 scrollViewDidEndDecelerating:

当 tableView 下拉的时候，tableView 的 contentOffset 值是会跟随下拉而变化的，那么在下拉到一定距离的时候，这个时候可以开始播放自定义的动画了，同时手指松开 tableView，tableView 自动弹回一定距离，继续动画；一段时间后动画结束，tableView 弹回原来位置；也就是根据 contentOffset 值的值变化来实现逻辑；

最后请去参照或使用 MJRefresh，已经封装的很好了，不需要我们在去造轮子，可以看里面具体实现，上面只是相当简陋的说了一下思路。
