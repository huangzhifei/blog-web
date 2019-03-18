---

title: RACCommand的用法

date: 2019-03-18 23:29:54

tags: RAC

categories: RAC

---

## RACCommand

RACCommand 在 ReactiveObjc 中是比较复杂的类，对于大多数人尤其是初学者并不会经常使用他。

在很多情况下，虽然使用 RACSignal 和 RACSubject 就能解决绝大部分问题，但是 RACCommand 的使用会为我们带来巨大的便利，尤其是在与副作用相关的操作中。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/What-is-RACCommand.png)


### 简介

RACCommand 与 RACSignal 等元素是不同的，RACCommand 并不表示数据流，可以看他的继承关系，他是直接继承自 NSObject，但是看他提供的 API，他是可以用来创建和订阅用于响应某些事件的信号。

```

@interface RACCommand<__contravariant InputType, __covariant ValueType> : NSObject

@end

```

他是一个用于管理 RACSignal 的创建与订阅的类。

在 ReactiveObjc 中对 RACCommand 有这样一段直白的描述：

```

A command,represented by the RACCommand class,creates and subscribes to a signal in response to some action.

This makes it easy to perform side-effecting(副作用) work as the user interacts with the app.

```

在用于与 UIKit 组件进行交互或执行包含副作用的操作时，RACCommand 能够帮助我们更快的处理并且响应任务，减少编码以及工程的复杂度。


### 初始化和执行

在 - (instancetype)initWithSignalBlock: 方法的签名上，你可以看到在每次 RACCommand 初始化时都会传入一个类型为 (RACSignal<ValueType> * (^)(InputType _Nullable input))signalBlock: 


```
- (instancetype)initWithSignalBlock:(RACSignal<ValueType> * (^)(InputType _Nullable input))signalBlock;

```

输入为 InputType 返回值为 RACSignal<ValueType> *, 而 InputType 也就是在调用 - excute: 方法传入的对象：

```

- (RACSignal<ValueType> *)execute:(nullable InputType)input;

```

这就是 RACCommand 将外部变量（或副作用）传入 ReactiveObjc 内部的方法，你可以理解为 RACCommand 将外部的变量 InputType 转换成了使用 RACSignal 包裹的 ValueType 对象。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Execute-For-RACCommand.png)

我们以下面的代码为例子，先来看一下 RACCommand 是如何工作的：


```

RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber * _Nullable input) {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSInteger integer = [input integerValue];
        for (NSInteger i = 0; i < integer; i++) {
            [subscriber sendNext:@(i)];
        }
        [subscriber sendCompleted];
        return nil;
    }];
}];


[[command.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
    NSLog(@"command: %@", x);
}];

[command execute:@1];

[RACScheduler.mainThreadScheduler afterDelay:0.1
                                    schedule:^{
                                        [command execute:@2];
                                    }];
                                    
[RACScheduler.mainThreadScheduler afterDelay:0.2
                                    schedule:^{
                                        [command execute:@3];
                                    }];


```

上面的代码打印：

```
command: 0
command: 0
command: 1
command: 0
command: 1
command: 2
```

每次 executionSignals 中发送了新的信号时，switchToLatest 方法返回的信号都会订阅这个最新的信号，这里也就保证了每次都会打印出最新的信号中的值。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Multiple-Executes.png)


在上面的代码中还有最后一个问题，为什么要使用 RACScheduler.mainThreadScheduler 延迟调用之后的 - execute: 方法？

由于在默认情况下 RACCommand 都是不支持并发操作的，需要在上一次命令执行之后才可以发送下一次的操作，否则就会返回错误信号 RACErrorSignal，这些错误可以通过订阅 command.errors 获取。

所以如果你使用如下的方式执行几次 - execute: 方法：

```
[command execute:@1];
[command execute:@2];
[command execute:@3];

```

最终就只打印 command: 0


### 最重要的内部“信号”

RACCommand 中最重要的内部信号就是 addedExecutionSignalsSubject:

```

@property (nonatomic, strong, readonly) RACSubject *addedExecutionSignalsSubject;

```

这个 RACSubject 对象通过各种操作衍生了几乎所有 RACCommand 中的其他信号。

既然 addedExecutionSignalsSubject 是一个 RACSubject，它不能在创建时预设好对订阅者发送的消息，它会在哪里接受数据并推送给订阅者呢？答案就在 -execute: 方法中：

```

- (RACSignal *)execute:(id)input {
	BOOL enabled = [[self.immediateEnabled first] boolValue];
	if (!enabled) {
		NSError *error = [NSError errorWithDomain:RACCommandErrorDomain code:RACCommandErrorNotEnabled userInfo:@{
			NSLocalizedDescriptionKey: NSLocalizedString(@"The command is disabled and cannot be executed", nil),
			RACUnderlyingCommandErrorKey: self
		}];

		return [RACSignal error:error];
	}

	RACSignal *signal = self.signalBlock(input);
	RACMulticastConnection *connection = [[signal
		subscribeOn:RACScheduler.mainThreadScheduler]
		multicast:[RACReplaySubject subject]];
	
	[self.addedExecutionSignalsSubject sendNext:connection.signal];

	[connection connect];
	return [connection.signal setNameWithFormat:@"%@ -execute: %@", self, RACDescription(input)];
}

```

在方法中这里你也能看到连续几次执行 -execute: 方法不能成功的原因：每次执行这个方法时，都会从另一个信号 immediateEnabled 中读取是否能执行当前命令的 BOOL 值，如果不可以执行的话，就直接返回 RACErrorSignal。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Execute-on-RACCommand.png)

- execute: 方法是唯一一个为 addedExecutionSignalsSubject 生产信息的方法。

在执行 signalBlock 返回一个 RACSignal 之后，会将当前信号包装成一个 RACMulticastConnection，然后调用 -sendNext: 方法发送到 addedExecutionSignalsSubject 上，执行 -connect 方法订阅原有的信号，最后返回。

### 复杂的初始化

由于 RACCommand 在初始化方法中初始化了七个高阶信号，它的实现非常复杂，这里先介绍其中的 immediateExecuting 和 moreExecutionsAllowed 两个临时信号。

#### immediateExecuting 表示当前有操作执行的信号

我们看 immediateExecuting 信号：

```

RACSignal *immediateExecuting = [[[[self.addedExecutionSignalsSubject
    flattenMap:^(RACSignal *signal) {
        return [[[signal
            catchTo:[RACSignal empty]]
            then:^{
                return [RACSignal return:@-1];
            }]
            startWith:@1];
    }]
    scanWithStart:@0 reduce:^(NSNumber *running, NSNumber *next) {
        return @(running.integerValue + next.integerValue);
    }]
    map:^(NSNumber *count) {
        return @(count.integerValue > 0);
    }]
    startWith:@NO];
    
```

immediateExecuting 是一个用于表示当前是否有任务执行的信号，如果输入的 addedExecutionSignalsSubject 等价于以下的信号：

```

[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:[RACSignal error:[NSError errorWithDomain:@"Error" code:1 userInfo:nil]]];
    [subscriber sendNext:[RACSignal return:@1]];
    [subscriber sendNext:[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [RACScheduler.mainThreadScheduler afterDelay:1
                                            schedule:^
         {
             [subscriber sendCompleted];
         }];
        return nil;
    }]];
    [subscriber sendNext:[RACSignal return:@3]];
    [subscriber sendCompleted];
    return nil;
}];

```

那么最后生成的高阶信号 immediateExecuting 如下：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/immediateExecuting-Signal-in-RACCommand.png)

1. -catchTo: 将所有的错误转换成 RACEmptySignal 信号
2. -flattenMap: 将每一个信号的开始和结束的时间点转换成 1 和 -1 两个信号
3. -scanWithStart:reduce: 从 0 开始累加原有的信号
4. -map: 将大于 1 的信号转换为 @yes
5. -startWith: 在信号序列最前面加入 @NO，表示在最开始时，没有任何动作在执行

immediateExecuting 使用几个 RACSignal 的操作成功将原有的信号流转换成了表示是否有操作执行的信号流。

#### moreExecutionsAllowed 表示是否允许更多操作执行的信号

相比于 immediateExecuting 信号的复杂，moreExecutionsAllowed 就简单多了：

```
RACSignal *moreExecutionsAllowed = [RACSignal
    if:[self.allowsConcurrentExecutionSubject startWith:@NO]
    then:[RACSignal return:@YES]
    else:[immediateExecuting not]];

```

因为文章中不准备介绍与并发执行有关的内容，所以这里的 then 语句永远不会执行，既然 RACCommand 不支持并行操作，那么这段代码就非常好理解了，当前 RACCommand 能否执行操作就是 immediateExecuting 取反：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/MoreExecutionAllowed-Signal.png)

到此这两个高阶操作就介绍完了。


### RACCommand 接口中的高阶信号


