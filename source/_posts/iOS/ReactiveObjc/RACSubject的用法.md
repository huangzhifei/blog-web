---

title: RACSubject的用法

date: 2019-03-20 21:52:21

tags: RAC

categories: RAC

---


在 `ReactiveCocoa` 中除了不可变的信号 `RACSignal`，也有用于桥接非 `RAC` 代码到 `ReactiveCocoa` 世界的『可变』信号 `RACSubject`。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Mutable-RACSignal—RACSubject.png)


`RACSubject ` 到底是什么？根据其字面意思，可以将其理解为一个可以订阅的主题，我们在订阅主题之后，向主题发送新的消息时，所有的订阅者都会接收到最新的消息。

但是这么解释确实有点羞涩，也不易于理解，`ReactiveCocoa` 团队对 `RACSubject ` 的解释是 `RACSubject ` 其实就是一个可以手动控制的信号。


## RACSubject 简介

`RACSubject` 是 `RACSignal` 的子类，与 `RACSignal` 以及 `RACSequence` 有着众多的类簇不同，`RACSubject` 在整个工程中并没有多少子类，不过在大多数情况下，我们也只会使用 `RACSubject` 自己或者 `RACReplaySubject`。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACSubject - Subclasses.png)


相比于 `RACSignal` 丰富的头文件，`RACSignal` 对外的接口并没有提供太多的方法：

```

@interface RACSubject : RACSignal <RACSubscriber>

+ (instancetype)subject;

@end

```

在笔者看来它与 `RACSignal` 最大的不同就是：`RACSubject` 实现了 `RACSubscriber` 协议，也就是下面的这些方法：

```

@protocol RACSubscriber <NSObject>
@required

- (void)sendNext:(nullable id)value;
- (void)sendError:(nullable NSError *)error;
- (void)sendCompleted;
- (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable;

@end

```

我们并不能在一个 `RACSignal` 对象上执行这些方法，只能在创建信号的 `block` 里面遵循 `RACSubscriber` 协议的对象发送新的值或者错误，这也是 `RACSubject` 和父类最大的不同：在 `RACSubject` 实例初始化之后，也可以通过这个实例向所有的订阅者发送消息。


## 冷信号与热信号

提到 RACSubject 就不得不提 ReactiveCocoa 中的另一对概念，冷信号和热信号。

对于冷热信号概念，我们借用 Rx 中的描述：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Hot-Signal-And-Cold-Signal.png)


冷信号是被动的，只会在订阅时向订阅者发送通知；

热信号是主动的，它会在任意时间发出通知，与订阅者的订阅时间无关。

也就是说冷信号所有的订阅者会在订阅时收到完全相同的序列，而订阅热信号之后，只会收到在订阅之后发出的序列。

```

热信号的订阅者能否收到消息取决于订阅的时间。

```

热信号在我们生活中很多的例子，比如订阅杂志时并不会把之前所有的期刊都送到我们手中，只会接收到订阅之后的期刊，而对于冷信号的话，举个不恰当的例子，每一年的高考生在订阅高考之后，收到往年所有的试卷，并在高考之后会取消订阅。

## 热信号 RACSubject

在 `ReactiveCocoa` 中，我们使用 `RACSignal` 来表示冷信号，也就是每一个订阅者在订阅信号时都会收到完整的序列；`RACSubject` 用于表示热信号，订阅者接收到多少值取决于它订阅的时间。

前面的文章中已经对 `RACSignal` 冷信号有了很多的介绍，这里也就不会多说了；这一小节主要的内容是想通过一个例子，简单展示 `RACSubject` 的订阅者收到的内容与订阅时间的关系：


```

RACSubject *subject = [RACSubject subject];

// Subscriber 1
[subject subscribeNext:^(id  _Nullable x) {
    NSLog(@"1st Sub: %@", x);
}];
[subject sendNext:@1];

// Subscriber 2
[subject subscribeNext:^(id  _Nullable x) {
    NSLog(@"2nd Sub: %@", x);
}];
[subject sendNext:@2];

// Subscriber 3
[subject subscribeNext:^(id  _Nullable x) {
    NSLog(@"3rd Sub: %@", x);
}];
[subject sendNext:@3];
[subject sendCompleted];

```

这里以图的方式来展示整个订阅与订阅者接收消息的过程：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Track-RACSubject-Subscription-Process.png)


从图中我们可以清楚的看到，几个订阅者根据**订阅时间**的不同收到了不同的数字序列，`RACSubject` 是**时间相关**的，它在发送消息时只会向已订阅的订阅者推送消息。


## RACSubject 的实现

`RACSubject` 的实现并不复杂，它『可变』的特性都来源于持有的订阅者数组 `subscribers`，在每次执行 `subscribeNext:error:completed:` 一类便利方法时，都会将传入的 `id<RACSubscriber>` 对象加入数组：

```
- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
	RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];
	subscriber = [[RACPassthroughSubscriber alloc] initWithSubscriber:subscriber signal:self disposable:disposable];

	NSMutableArray *subscribers = self.subscribers;
	@synchronized (subscribers) {
		[subscribers addObject:subscriber];
	}

	[disposable addDisposable:[RACDisposable disposableWithBlock:^{
		@synchronized (subscribers) {
			NSUInteger index = [subscribers indexOfObjectWithOptions:NSEnumerationReverse passingTest:^ BOOL (id<RACSubscriber> obj, NSUInteger index, BOOL *stop) {
				return obj == subscriber;
			}];

			if (index != NSNotFound) [subscribers removeObjectAtIndex:index];
		}
	}]];

	return disposable;
}

```

订阅的过程分为三个部分：

1、初始化一个 `RACPassthroughSubscriber` 实例；

2、将 `subscriber` 加入 `RACSubject` 持有的数组中；

3、创建一个 `RACDisposable` 对象，在当前 `subscriber` 销毁时，将自身从数组中移除。


![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Send-Subscibe-to-RACSubject.png)

`-subscribe:` 将所有遵循 `RACSubscriber` 协议的对象全部加入当前 `RACSubject` 持有的数组 `subscribers` 中。

在上一节的例子中，我们能对 `RACSubject` 发送 `-sendNext:` 等消息也都取决于它实现了 `RACSubscriber` 协议：

```

- (void)sendNext:(id)value {
	[self enumerateSubscribersUsingBlock:^(id<RACSubscriber> subscriber) {
		[subscriber sendNext:value];
	}];
}

- (void)sendError:(NSError *)error {
	[self.disposable dispose];

	[self enumerateSubscribersUsingBlock:^(id<RACSubscriber> subscriber) {
		[subscriber sendError:error];
	}];
}

- (void)sendCompleted {
	[self.disposable dispose];

	[self enumerateSubscribersUsingBlock:^(id<RACSubscriber> subscriber) {
		[subscriber sendCompleted];
	}];
}

```

`RACSubject` 会在自身接受到这些方法时，下发给持有的全部的 `subscribers`。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Send-Messages-to-RACSubject.png)

代码中的 `-enumerateSubscribersUsingBlock:` 只是一个使用 `for` 循环遍历 `subscribers` 的安全方法：

```
- (void)enumerateSubscribersUsingBlock:(void (^)(id<RACSubscriber> subscriber))block {
	NSArray *subscribers;
	@synchronized (self.subscribers) {
		subscribers = [self.subscribers copy];
	}

	for (id<RACSubscriber> subscriber in subscribers) {
		block(subscriber);
	}
}

```

`RACSubject` 就是围绕一个 `NSMutableArray` 数组实现的，实现还是非常简单的，只是在需要访问 `subscribers` 的方法中使用 `@synchronized` 避免线程竞争。


```

@interface RACSubject ()

@property (nonatomic, strong, readonly) NSMutableArray *subscribers;

@end

```

`RACSubject` 提供的初始化类方法 `+subject` 也只是初始化了几个成员变量：

```

+ (instancetype)subject {
	return [[self alloc] init];
}

- (instancetype)init {
	self = [super init];
	if (self == nil) return nil;

	_disposable = [RACCompoundDisposable compoundDisposable];
	_subscribers = [[NSMutableArray alloc] initWithCapacity:1];

	return self;
}

```

至此，对于 RACSubject 的分析就结束了，接下来会分析更多的子类。


## RACBehaviorSubject 与 RACReplaySubject

### RACBehaviorSubject

### RACReplaySubject


## 总结