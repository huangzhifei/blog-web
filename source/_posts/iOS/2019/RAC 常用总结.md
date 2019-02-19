---
title: RAC 常用总结

date: 2019-02-19 18:14:21

tags: RAC

categories: RAC

---

## RAC 常用总结

### 1、RAC()

```
RAC(self.collectionView, headArray)  = RACObserve(self.viewModel, headData);

```
RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定。

意思是：只要 self.viewModel 的 headData 内容改变 就会自动同步到 self.collectionView 的 headArray 上。

### 2、RACObserve()

```

[RACObserve(self.view, center) subscribeNext:^(id x) {
	NSLog(@"%@",x);
}];

```
RACObserve(TARGET, KEYPATH):监听某个对象的某个属性,返回的是信号

意思是：只要 self.view 的 center 改变，就会触发他后面订阅的 subscribeNext: 然后触发回调


