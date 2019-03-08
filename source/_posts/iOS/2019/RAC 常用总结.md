---
title: RAC 常用总结

date: 2019-02-19 18:14:21

tags: RAC

categories: RAC

---

## RAC 常用类

### 1、RAC()

用于给某个对象的某个属性绑定。把一个对象的某个属性绑定一个信号,只要发出信号,就会把信号的内容给对象的属性赋值。

```
RAC(self.collectionView, headArray)  = RACObserve(self.viewModel, headData);

```
RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定。

意思是：只要 self.viewModel 的 headData 内容改变 就会自动同步到 self.collectionView 的 headArray 上。

### 2、RACObserve()

用于给某个对象的某个属性绑定，快速的监听某个对象的某个属性改变，返回的是一个信号,对象的某个属性改变的信号

```

[RACObserve(self.view, center) subscribeNext:^(id x) {
	NSLog(@"%@",x);
}];

```
RACObserve(TARGET, KEYPATH):监听某个对象的某个属性,返回的是信号

意思是：只要 self.view 的 center 改变，就会触发他后面订阅的 subscribeNext: 然后触发回调。


### 3、RACSignal 冷信号

RACSignal 信号类表示当数据改变时，在信号内部会利用订阅者发送数据，他默认是一个冷信号，创建的时候是不会被触发的，只有被订阅以后才会变成热信号。

```
    // 1.创建信号
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id subscriber) {

        // 3.block调用时刻：每当有订阅者订阅信号，就会调用block。

        // 4.发送信号
        [subscriber sendNext:@1];

        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];

        // 执行完信号后进行的清理工作，如果不需要就返回 nil
        return [RACDisposable disposableWithBlock:^{

            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。

            // 执行完Block后，当前信号就不在被订阅了。

            NSLog(@"信号被销毁");
        }];
    }];

    // 2.订阅信号,才会激活信号.
    [siganl subscribeNext:^(id x) {
        // 5.block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@", x);
    }];
```

### 4、RACSubscriber 订阅者

RACSubscriber 是一个协议，任何遵循 RACSubscriber 协议的对象并且实现其协议方法都可以是一个订阅者，订阅者可以帮助信号发送数据，RACSubscriber 协议中有四个方法。

```
@required
- (void)sendNext:(nullable id)value;
- (void)sendError:(nullable NSError *)error;
- (void)sendCompleted;
- (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable;

```

### 5、RACDisposable 取消订阅、清理资源

RACDisposable 用于取消订阅和清理资源，当信号发送完成或发送错误时会自动调用。

```
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 3.利用订阅者发送数据
        [subscriber sendNext:@"这是发送的数据"];
        // 如果为未调用,当信号发送完成或发送错误时会自动调用
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"资源被清理了");
        }];
    }];
    
    // 2.订阅信号
    [signal subscribeNext:^(id x) {
       NSLog(@"接收到数据:%@",x);
    }];

```

或者调用 RACDisposable 中的 dispose 方法来取消订阅。


### 6、RACSubject 信号提供者

RACSubject 继承于 RACSignal，又遵循了 RACSubscriber 协议，所以既可以充当信号，又可以发送信号，通常用他代替代理。

```
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];

    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"testRACSubject 第一个订阅者%@", x);
    }];

    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"testRACSubject 第二个订阅者%@", x);
    }];

    // 3.发送信号
    [subject sendNext:@"1"];

```

1. RACSubject 底层实现和 RACSignal 不一样。
2. RACSubject 在执行 [RACSubject subject] 时，会在初始化时创建 disposable 对象属性和 subscribers 订阅者数组。
3. 在执行 subscribeNext 订阅信号时，会创建一个订阅者 RACSubscriber，并将订阅者 RACSubscriber 添加到 subscribers 订阅者数组。
4. 在执行 sendNext 发送信号时，会遍历 subscribers 订阅者数组，挨个执行 sendNext。



### 7、RACCommand 事件处理

RACCommand 是处理事件的类，可以把事件如何处理，事件中的数据如何传递，包装到这个类中。

下面例子：监听按钮的点击，发送网络请求：

```
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"接收到命令:%@", input);
        // 必须返回一个信号,不能为空.(信号中的信号)
        // 3.创建信号用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"信号中的信号发送的数据"];
            // 注意:数据传递完成,要调用sendCompleted才能执行完毕
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    self.command = command;
    
    // 2.订阅信号中的信号(必须要在执行命令前订阅)
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"接收到信号中的信号发送的数据:%@",x);
    }];
    
    
    // 4.执行命令
    [command execute:@1];
    
    // 监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[command.executing skip:1] subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"正在执行");
        }else{
            NSLog(@"未开始/执行完成");
        }
    }];

```


## RAC 常用用法

### 1、代替代理

#### 使用 RACSubject 代替代理

场景：有一个 DelegateView 上面有一个 Button 按钮，通过实现代理来监听按钮的点击事件

1、先在 DelegateView.h 里面定义一个 RACSubject 对象

```
@property (nonatomic, strong) RACSubject *btnClickSignal;

- (RACSubject *)btnClickSignal {
    if (!_btnClickSignal) {
        _btnClickSignal = [RACSubject subject];
    }
    return _btnClickSignal;
}

```

2、在 Button 按钮的点击事件中触发此信号

```
@weakify(self);
[[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
    @strongify(self);
    [self.btnClickSignal sendNext:@"我在代理"];
}];

```

3、在 ViewController 中订阅此信号就行

```
[self.delegateView.btnClickSignal subscribeNext:^(id _Nullable x) {
        NSLog(@"button: %@", x);
}];

```

#### 使用 rac_signalForSelector 方法代替代理

原理：判断一个方法有没有调用，如果调用了就会自动发送一个信号。

1、给此 button 添加响应函数

```
[self.btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

- (void)buttonClick:(UIButton *)sender {
    NSLog(@"xxxxxx");
}
```     

2、在 ViewController 中使用 rac_signalForSelector 订阅

```
[[self.delegateView rac_signalForSelector:@selector(buttonClick:)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"button2: %@", x);
    }];
```

上面说了原理是：只要 @selector 中的方法被调用就可以触发 rac_signalForSelector 来监听，所以其实第一步不一定非得使用 addTarget:action: 来触发调用，我们用下面方式来触发也能达到效果：

```
@weakify(self);
[[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
    @strongify(self);
    [self buttonClick:self.btn];
}];
```

### 2、代替 KVO

不用在像以前那样代码分离的写很多代码，直接使用 rac_valuesAndChangesForKeyPath 

```
[[self.delegateView rac_valuesAndChangesForKeyPath:@"backgroundColor"
                                               options:NSKeyValueObservingOptionNew observer:nil]
     subscribeNext:^(id x) {
         NSLog(@"self.delegateView: %@",x);
    }];

```

### 3、代替 Control Event

```
[[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
	NSLog(@"%@",x);
}];

```

### 4、代替通知（NSNotificationCenter）

```
[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
```

### 5、监听文本框文字改变

```
[[self.textField rac_textSignal] subscribeNext:^(NSString *_Nullable value) {
	@strongify(self);
	self.label.text = value;
}];

```

### 6、rac_liftSelector 多次请求全部完成才触发

处理当界面有多次请求时，需要都获取到数据时，才能展示界面。

```
rac_liftSelector:withSignalsFromArray:Signals:

```
当传入的Signals(信号数组)，每一个signal都至少sendNext过一次，就会去触发第一个selector参数的方法。

注意：

有几个信号，参数一的方法就有几个参数，每个参数对应信号发出的数据。
不需要主动去订阅 signalA、signalB ......,方法内部会自动订阅。

```
// 创建
RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [subscriber sendNext:@"A"];
    });
    return nil;
}];

RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@"B"];
    [subscriber sendNext:@"Another B"];
    [subscriber sendCompleted];
    return nil;
}];

[self rac_liftSelector:@selector(doA:withB:) withSignals:signalA, signalB, nil];


// 响应方法
- (void)doA:(NSString *)A withB:(NSString *)B {
    NSLog(@"A:%@ and B:%@", A, B);
}

```

输出打印：

```

A:A and B:Another B

```

signalB 第一次发送的内容 @“B” 被后面的 @"Another B" 覆盖，因为要等 signalA 也发送一次后，才能触发。

