---

title: RACSignal的用法

date: 2019-03-22 22:48:42

tags: RAC

categories: RAC

---


## ReactiveCocoa 与信号

`RAC` 将原有的各种设计模式，包括代理、`Target-Action`、通知中心以观察者模式各种各种『输入』，都抽象成信号（也可以理解为状态流）让单一的组件能够对自己的响应动作进行控制，简化了视图控制器的负担。

在 `RAC` 中最重要的信号，也就是 `RACSignal` 对象是这一篇文章的核心，文章主要会介绍下面的代码片段：

```
RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:@1];
    [subscriber sendNext:@2];
    [subscriber sendCompleted];
    return [RACDisposable disposableWithBlock:^{
        NSLog(@"dispose");
    }];
}];
[signal subscribeNext:^(id  _Nullable x) {
    NSLog(@"%@", x);
}];

```

在上述代码执行时，会在控制台中打印出以下内容：

```
1
2
dispose

```

代码片段基本都是围绕 `RACSignal` 类进行的，接下来主要分成以下几点来展开：

* 简单了解 `RACSignal`
* 信号的创建
* 信号的订阅与发送
* 订阅的回收过程

## RACSignal 简介

RACSignal 其实是抽象类 RACStream 的子类，在整个 RAC 工程中有另一个类 RACSequence 也继承自抽象类 RACStream：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACSignal-Hierachy.png)


RACSignal 是 RAC 的核心，他可以简单理解为一连串的状态:

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/What-is-RACSignal.png)


在状态改变时，对应的订阅者 RACSubscriber	就会收到通知执行相应的指令，在 RAC 的世界中所有的消息都是通过信号的方式来传递的，原有的设计模式都会简化为一种模型。

## RACStream

RACStream 作为抽象类本身不提供方法的实现，其实现内部原生提供的而方法都是抽象方法，会在调用时直接抛出异常：

```

+ (__kindof RACStream *)empty {
	NSString *reason = [NSString stringWithFormat:@"%@ must be overridden by subclasses", NSStringFromSelector(_cmd)];
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
}

- (__kindof RACStream *)bind:(RACStreamBindBlock (^)(void))block;
+ (__kindof RACStream *)return:(id)value;
- (__kindof RACStream *)concat:(RACStream *)stream;
- (__kindof RACStream *)zipWith:(RACStream *)stream;

```


![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACStream-AbstractMethod.png)


上面的这些抽象方法都需要子类覆写，不过 RACStream 在 Operations 分类中使用上面的抽象方法提供了丰富的内容，比如说 -flattenMap: 方法：

```

- (__kindof RACStream *)flattenMap:(__kindof RACStream * (^)(id value))block {
	Class class = self.class;

	return [[self bind:^{
		return ^(id value, BOOL *stop) {
			id stream = block(value) ?: [class empty];
			NSCAssert([stream isKindOfClass:RACStream.class], @"Value returned from -flattenMap: is not a stream: %@", stream);

			return stream;
		};
	}] setNameWithFormat:@"[%@] -flattenMap:", self.name];
}

```

其他方法比如 -skip:、-take:、-ignore： 等等实例方法都构建在这些抽象方法之上，只要子类覆写了所有抽象方法就能自动获得所有的 Operation 分类中的方法。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACStream-Operation.png)


## RACSignal 细说

`RAC` 框架借鉴了很多平台的概念，就比如 `RACStream` 的抽象方法 `+return:` 和 `-bind:`
首先我们来看一下 `+return:` 方法：

```

+ (RACSignal *)return:(id)value {
	return [RACReturnSignal return:value];
}

```

改方法接受一个 `NSObject` 对象，并返回一个 `RACSignal` 的实例，它会将一个 `Foundation` 世界的对象 `NSObject` 转换成 `RAC` 中的 `RACSignal`

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACSignal-Return.png)

而 `RACReturnSignal` 也仅仅是把 `NSObject` 对象包装一下，并没有做什么复杂的事情：

```

+ (RACSignal *)return:(id)value {
	RACReturnSignal *signal = [[self alloc] init];
	signal->_value = value;
	return signal;
}

```

但是 -bind: 方法的实现相比之下就十分复杂了：

```

- (RACSignal *)bind:(RACSignalBindBlock (^)(void))block {
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        RACSignalBindBlock bindingBlock = block();
        return [self subscribeNext:^(id x) {
            BOOL stop = NO;
            id signal = bindingBlock(x, &stop);

            if (signal != nil) {
                [signal subscribeNext:^(id x) {
                    [subscriber sendNext:x];
                } error:^(NSError *error) {
                    [subscriber sendError:error];
                } completed:^{
                    [subscriber sendCompleted];
                }];
            }
            if (signal == nil || stop) {
                [subscriber sendCompleted];
            }
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendCompleted];
        }];
    }] setNameWithFormat:@"[%@] -bind:", self.name];
}


```

`上面对 bind 方法进行一些省略，省掉了对 RACDisposable 的处理。`

-bind: 方法会在原信号每次发出消息时，都执行 RACSignalBindBlock 对原有的信号中的消息进行变换，生成一个新的信号：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACSignal-Bind.png)


`在原有的 RACSignal 对象上调用 -bind：方法传入 RACSignalBindBlock，图示中的右侧就是具体的执行过程，原信号在变换之后变成了新的蓝色的 RACSignal 对象。`

`RACSignalBindBlock` 可以简单理解为一个接受 `NSObject` 对象返回 `RACSignal` 对象的函数：

```

typedef RACSignal * _Nullable (^RACSignalBindBlock)(id _Nullable value, BOOL *stop);

```

其函数签名可以理解为 `id -> RACSignal`，然而这种函数是无法直接对 `RACSignal` 对象进行变换的；不过通过 `-bind:` 方法就可以使用这种函数操作 `RACSignal`，其实现如下：

1. 将 RACSignal 对象『解包』出 NSObject 对象；
2. 将 NSObject 传入 RACSignalBindBlock 返回 RACSignal。

如果不考虑 RACSignal 会发出错误或者完成信号时，-bind：可以简化为下面简单的形式：

```

- (RACSignal *)bind:(RACSignalBindBlock (^)(void))block {
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        RACSignalBindBlock bindingBlock = block();
        return [self subscribeNext:^(id x) {
            BOOL stop = NO;
            [bindingBlock(x, &stop) subscribeNext:^(id x) {
                [subscriber sendNext:x];
            }];
        }];
    }] setNameWithFormat:@"[%@] -bind:", self.name];
}

```

调用 `-subscribeNext:` 方法订阅当前信号，将信号中的状态解包，然后将原信号中的状态传入 `bindingBlock` 中并订阅返回的新的信号，将生成的新状态 `x` 传回原信号的订阅者。

这里通过两个简单的例子来了解 `-bind：`方法的作用：

```

RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:@1];
    [subscriber sendNext:@2];
    [subscriber sendNext:@3];
    [subscriber sendNext:@4];
    [subscriber sendCompleted];
    return nil;
}];
RACSignal *bindSignal = [signal bind:^RACSignalBindBlock _Nonnull{
    return ^(NSNumber *value, BOOL *stop) {
        value = @(value.integerValue * value.integerValue);
        return [RACSignal return:value];
    };
}];
[signal subscribeNext:^(id  _Nullable x) {
    NSLog(@"signal: %@", x);
}];
[bindSignal subscribeNext:^(id  _Nullable x) {
    NSLog(@"bindSignal: %@", x);
}];

```

上面的代码直接使用了 +return：方法将 value 打包成了 RACSignal * 对象：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Before-After-Bind-RACSignal.png)

`在 BindSignal 中的每一个数字其实都是由一个 RACSignal 包裹的，这里没有画出，在下一个例子中，可以清晰的看到他们的区别。`

上图简要展示了变化前后的信号中包含的状态，在运行上述代码时，会在终端中打印出：

```

signal: 1
signal: 2
signal: 3
signal: 4
bindSignal: 1
bindSignal: 4
bindSignal: 9
bindSignal: 16

```

这是一个最简单的例子，直接使用 -return: 打包 NSObject 返回一个 RACSignal，接下来用一个更复杂的例子来帮助我们更好的了解 -bind: 方法：

```

RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:@1];
    [subscriber sendNext:@2];
    [subscriber sendCompleted];
    return nil;
}];
RACSignal *bindSignal = [signal bind:^RACSignalBindBlock _Nonnull{
    return ^(NSNumber *value, BOOL *stop) {
        NSNumber *returnValue = @(value.integerValue * value.integerValue);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            for (NSInteger i = 0; i < value.integerValue; i++) [subscriber sendNext:returnValue];
            [subscriber sendCompleted];
            return nil;
        }];
    };
}];
[bindSignal subscribeNext:^(id  _Nullable x) {
    NSLog(@"%@", x);
}];

```

下图相比上面例子中的图片更能精确的表现出 -bind：方法都做了什么：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Before-After-Bind-RACSignal-Complicated.png)

信号中原有的状态经过 -bind: 方法中传入 RACSignalBindBlock 的处理实际上返回了多个 RACSignal。

在源代码的注释中清楚地写出了方法的实现过程：

1. 订阅原信号中的值；
2. 将原信号发出的值传入 RACSignalBindBlock 进行转换；
3. 如果 RACSignalBindBlock 返回一个信号，就会订阅该信号并将信号中的所有值传给订阅者 subscriber；
4. 如果 RACSignalBindBlock 请求终止信号就会向原信号发出 -sendCompleted 消息；
5. 当所有信号都完成时，会向订阅者发送 -sendCompleted；
6. 无论何时，如果信号发出错误，都会向订阅者发送 -sendError: 消息。

## 信号的创建

信号的创建过程十分简单，-createSignal: 是推荐的创建信号的方法，方法其实只做了一次转发：

```
+ (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe {
	return [RACDynamicSignal createSignal:didSubscribe];
}

+ (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe {
	RACDynamicSignal *signal = [[self alloc] init];
	signal->_didSubscribe = [didSubscribe copy];
	return [signal setNameWithFormat:@"+createSignal:"];
}

```

改方法其实只是创建了一个 RACDynamicSignal 实例并保存了传入的 didSubscribe 代码块，在每次有订阅者订阅当前信号时，都会执行一遍，向订阅者发送消息。

## RACSignal 类簇

虽然 -createSignal: 的方法签名上返回的是 RACSignal 对象的实例，但是实际上这里返回的是 RACDynamicSignal，也就是 RACSignal 的子类；同样，在 ReactiveCocoa 中也有很多其他的 RACSignal 子类。

使用类簇的方式设计的 RACSignal 在创建实例时可能会返回 RACDynamicSignal、RACEmptySignal、RACErrorSignal 和 RACReturnSignal 对象：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACSignal-Subclasses.png)

其实这几种子类并没有对原有的 RACSignal 做出太大的改变，它们的创建过程也不是特别复杂，只需要调用 RACSignal 不同的类方法：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACSignal-Instantiate-Object.png)


RACSignal 只是起到了一个代理的作用，最后的实现过程还是会指向对应的子类：

```

+ (RACSignal *)error:(NSError *)error {
	return [RACErrorSignal error:error];
}

+ (RACSignal *)empty {
	return [RACEmptySignal empty];
}

+ (RACSignal *)return:(id)value {
	return [RACReturnSignal return:value];
}

```

以 RACReturnSignal 的创建过程为例：

```
+ (RACSignal *)return:(id)value {
	RACReturnSignal *signal = [[self alloc] init];
	signal->_value = value;
	return signal;
}

```

这个信号的创建过程和 RACDynamicSignal 的初始化过程一样，都非常简单；只是将传入的 value 简单保存一下，在有其他订阅者 -subscribe: 时，向订阅者发送 value：

```

- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
	return [RACScheduler.subscriptionScheduler schedule:^{
		[subscriber sendNext:self.value];
		[subscriber sendCompleted];
	}];
}

```

RACEmptySignal 和 RACErrorSignal 的创建过程也异常的简单，只是对传入的数据进行简单的存储，然后在订阅时发送出来：

```

// RACEmptySignal
+ (RACSignal *)empty {
	return [[[self alloc] init] setNameWithFormat:@"+empty"];
}

- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
	return [RACScheduler.subscriptionScheduler schedule:^{
		[subscriber sendCompleted];
	}];
}

// RACErrorSignal
+ (RACSignal *)error:(NSError *)error {
	RACErrorSignal *signal = [[self alloc] init];
	signal->_error = error;
	return signal;
}

- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
	return [RACScheduler.subscriptionScheduler schedule:^{
		[subscriber sendError:self.error];
	}];
}


```

这两个创建过程的唯一区别就是一个发送的是『空值』，另一个是 NSError 对象。


## 信号的订阅与信息的发送

ReactiveCocoa 中信号的订阅与信息的发送过程主要是由 RACSubscriber 类来处理的，而这也是信号的处理过程中最重要的一部分，这一小节会先分析整个工作流程，之后会深入代码的实现。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACSignal-Subcribe-Process.png)

在信号创建之后调用 -subscribeNext: 方法返回一个 RACDisposable，然而这不是这一流程关心的重点，在订阅过程中生成了一个 RACSubscriber 对象，向这个对象发送消息 -sendNext: 时，就会向所有的订阅者发送消息。

### 信号的订阅

信号的订阅与 -subscribe: 开头的一系列方法有关：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACSignal-Subscribe-Methods.png)

订阅者可以选择自己想要感兴趣的信息类型 next/error/completed 进行关注，并在对应的信息发生时调用 block 进行处理回调。

所有的方法其实只是对 nextBlock、completedBlock 以及 errorBlock 的组合，这里以其中最长的 -subscribeNext:error:completed: 方法的实现为例（也只需要介绍这一个方法）：

```

- (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock error:(void (^)(NSError *error))errorBlock completed:(void (^)(void))completedBlock {
	RACSubscriber *o = [RACSubscriber subscriberWithNext:nextBlock error:errorBlock completed:completedBlock];
	return [self subscribe:o];
}

```

拿到了传入的 block 之后，使用 +subscriberWithNext:error:completed: 初始化一个 RACSubscriber 对象的实例：

```

+ (instancetype)subscriberWithNext:(void (^)(id x))next error:(void (^)(NSError *error))error completed:(void (^)(void))completed {
	RACSubscriber *subscriber = [[self alloc] init];

	subscriber->_next = [next copy];
	subscriber->_error = [error copy];
	subscriber->_completed = [completed copy];

	return subscriber;
}

```

在拿到这个对象之后，调用 RACSignal 的 -subscribe: 方法传入订阅者对象：

```

- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
	NSCAssert(NO, @"This method must be overridden by subclasses");
	return nil;
}

```

RACSignal 类中其实并没有实现这个实例方法，需要在上文提到的四个子类对这个方法进行覆写，这里仅分析 RACDynamicSignal 中的方法：

```

- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
    RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];
    subscriber = [[RACPassthroughSubscriber alloc] initWithSubscriber:subscriber signal:self disposable:disposable];

    RACDisposable *schedulingDisposable = [RACScheduler.subscriptionScheduler schedule:^{
        RACDisposable *innerDisposable = self.didSubscribe(subscriber);
        [disposable addDisposable:innerDisposable];
    }];

    [disposable addDisposable:schedulingDisposable];
    
    return disposable;
}

```

RACPassthroughSubscriber 就像它的名字一样，只是对上面创建的订阅者对象进行简单的包装，将所有的消息转发给内部的 innerSubscriber，也就是传入的 RACSubscriber 对象：

```

- (instancetype)initWithSubscriber:(id<RACSubscriber>)subscriber signal:(RACSignal *)signal disposable:(RACCompoundDisposable *)disposable {
	self = [super init];

	_innerSubscriber = subscriber;
	_signal = signal;
	_disposable = disposable;

	[self.innerSubscriber didSubscribeWithDisposable:self.disposable];
	return self;
}

```

如果直接简化 -subscribe: 方法的实现，你可以看到一个看起来极为敷衍的代码：

```

- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber {
    return self.didSubscribe(subscriber);
}

```

方法只是执行了在创建信号时传入的 RACSignalBindBlock：

```

[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:@1];
    [subscriber sendNext:@2];
    [subscriber sendCompleted];
    return [RACDisposable disposableWithBlock:^{
        NSLog(@"dispose");
    }];
}];

```

总而言之，信号的订阅过程就是初始化 RACSubscriber 对象，然后执行 didSubscribe 代码块的过程。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Principle-of-Subscribing-Signals.png)

### 信息的发送

在 RACSignalBindBlock 中，订阅者可以根据自己的兴趣选择自己想要订阅哪种消息；我们也可以按需发送三种消息：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RACSignal-Subcription-Messages-Sending.png)

而现在只需要简单看一下这三个方法的实现，就能够明白信息的发送过程了（真是没啥好说的，不过为了凑字数完整性）：

```

- (void)sendNext:(id)value {
	@synchronized (self) {
		void (^nextBlock)(id) = [self.next copy];
		if (nextBlock == nil) return;

		nextBlock(value);
	}
}

```

-sendNext: 只是将方法传入的值传入 nextBlock 再调用一次，并没有什么值得去分析的地方，而剩下的两个方法实现也差不多，会调用对应的 block，在这里就省略了。

## 订阅的回收过程

### RACDisposable

### RACSerialDisposable

### RACCompoundDisposable

## 订阅的销毁过程

## 总结

RAC 中绝大多数的方法都相当简洁，行数并不多，代码的组织方式很多，值得大家去阅读与学习。

