---

title: RAC 一些高级用法总结

date: 2019-03-08 13:53:07

tags: RAC

categories: RAC

---


### 1、bind 绑定/包装

bind 主要作用属于包装，将信号返回的值包装成一个新的值，然后在通过信号返回给订阅者。

1. 传入一个返回值 RACSignalBindBlock 的 block
2. 描述一个 RACSignalBindBlock 类型的 bindBlock 作为 block 的返回值
3. 描述一个返回结果的信号，作为 bindBlock 的返回值，注意在 bindBlock 中做信号结果的处理

```
[[self.textField.rac_textSignal bind:^RACSignalBindBlock _Nonnull {
    return ^RACSignal *(id value, BOOL *stop) {
        // 做好处理，通过信号返回出去.
        return [RACSignal return:[NSString stringWithFormat:@"hello: %@", value]];
    };
}] subscribeNext:^(id _Nullable x) {
    NSLog(@"bind content: %@", x); // hello: xxxxx
}];

```


### flattenMap & map 映射

flattenMap 和 map 都是用于把源信号内容映射成新的内容

##### 1、flattenMap 的底层实现是通过 bind 实现的
##### 2、map 的底层实现是通过 flattenMap 实现的

#### flattenMap 使用步骤：

1. 传入一个block，block 类型是返回值 RACStream，参数 value;
2. 参数 value 就是源信号的内容，拿到源信号的内容做处理；
3. 包装成 RACReturnSignal 信号，返回出去。

```
[[_textField.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
    return  [RACSignal return:[NSString stringWithFormat:@"hello %@", value]];
}] subscribeNext:^(id  _Nullable x) {
    NSLog(@"%@",x); // hello "x"
}];

```

#### map 使用步骤：

1. 传入一个 block，类型是返回对象，参数是 value；
2. value 就是源信号的内容，直接拿到源信号的内容做处理；
3. 把处理好的内容，直接返回就好了，不用包装成信号，返回的值，就是映射的值。

```

[[_textField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
    // 当源信号发出，就会调用这个block，修改源信号的内容
    // 返回值：就是处理完源信号的内容。
    return [NSString stringWithFormat:@"hello:%@",value];
}] subscribeNext:^(id  _Nullable x) {
    NSLog(@"%@",x); // hello: "x"
}];


```

#### flattenMap & map 区别

1. flattenMap 中的 block 返回的是信号
2. map 中的 block 返回的是对象
3. 开发中，如果信号发出的值不是信号，映射一般使用 map
4. 开发中，如果信号发出的值是信号，映射一般使用 flattenMap


### concat 合并，有顺序的处理多个信号

按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号

```

// 创建两个信号 signalA 和 signalB
RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    NSLog(@"signalA sendNext");
    [subscriber sendNext:@"A"];
    [subscriber sendNext:@"AA"];
    [subscriber sendCompleted];
    return nil;
}];

RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    NSLog(@"signalB sendNext");
    [subscriber sendNext:@"B"];
    [subscriber sendCompleted];
    return nil;
}];

// 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活
[[signalA concat:signalB] subscribeNext:^(id  _Nullable x) {
    NSLog(@"contact :%@", x);
}];

```

第一个信号必须发送完成，第二个信号才会被激活。


### then 下一个

用于连接两个信号，当第一个信号完成后，才会连接 then 返回的信号

底层实现

1. 使用 concat 连接 then 返回的信号
2. 先过滤掉之前的信号发出的值

```

[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:@"test1"];
    [subscriber sendCompleted];
    return nil;
}] then:^RACSignal * _Nonnull{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"test2"];
        return nil;
    }];
}] subscribeNext:^(id  _Nullable x) {
    // 只能接收到第二个信号的值，也就是then返回信号的值
    NSLog(@"then content: %@", x);
}];

```

会过滤掉第一个 “test1”，只接收第二个信号发送过来的值。


### merge 合并，合成一个信号

把多个信号合并为一个信号，任何一个信号有新值的时候就会调用，没有先后顺序，依赖关系（和 concat 的区别）

```

RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"merge signal 1"];
        [subscriber sendCompleted];
        return nil;
    }];

    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        [subscriber sendNext:@"merge signal 2"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:signalB];
    [mergeSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"merge content: %@", x);
    }];

```

**注意：只要有一个信号被发出就会被监听**


### combineLatest 结合

将多个信号合并起来，并且拿到各个信号的最新的值，必须每个合并的 signal 至少都有一次 sendNext，才会触发合并的信号。

```

RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@"combineLatest signalA"];
    return nil;
}];

RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@"combineLatest signalB"];
    return nil;
}];

// 把两个信号组合成一个信号,跟zip一样，没什么区别
RACSignal *combineSignal = [signalA combineLatestWith:signalB];

[combineSignal subscribeNext:^(id x) {
    NSLog(@"combineLatest content: %@",x); // (combineLatest signalA, combineLatest signalB)
}];


```



### reduce 聚合

用于信号发出的内容是元组，把信号发出元组的值聚合成一个值，一般都是先组合在聚合。

```

RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@"reduce signalA"];
    return nil;
}];

RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@"reduce signalB"];
    return nil;
}];

// reduceblock的返回值：聚合信号之后的内容。
RACSignal *reduceSignal = [RACSignal combineLatest:@[signalA,signalB] reduce:^id(NSNumber *num1 ,NSNumber *num2){
    return [NSString stringWithFormat:@"%@ %@",num1,num2];
}];

[reduceSignal subscribeNext:^(id x) {
    NSLog(@"reduce content: %@",x); // (reduce signalA, reduce signalB)
}];


```


### filter 过滤

过滤信号，获取满足条件的信号 

获取到位数大于 6 的值

```

[[self.textField.rac_textSignal filter:^BOOL(NSString *value) {
    return value.length > 6;
}] subscribeNext:^(NSString * _Nullable x) {
    NSLog(@"filter content: %@",x); // x 值位数大于6
}];


```

### ignore 忽略

忽略掉指定的值

忽略掉值为 "999" 的信号

```

[[self.textField.rac_textSignal ignore:@"999"] subscribeNext:^(id x) {
    NSLog(@"ignore content: %@",x);
}];

```

### interval 定时

每隔一段时间发出信号

类似于 NSTimer

每隔 1 秒发送一次信号

```

// 这个就是RAC中的GCD
self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate *_Nullable x) {
    self.time--;
    NSString *title = self.time > 0 ? [NSString stringWithFormat:@"请等待 %ld 秒后重试", self.time] : @"发送验证码";
    [self.countDownBtn setTitle:title forState:UIControlStateNormal];
    self.countDownBtn.enabled = (self.time == 0) ? YES : NO;
    if (self.time == 0) {
        // 取消这个订阅
        [self.disposable dispose];
    }
}];

```


### delay 延迟

延迟执行，类似于 GCD 的 after。

下面例子主要是延迟发送 next


```

[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@"delay signalA"];
    return nil;
}] delay:2] subscribeNext:^(id x) {
    NSLog(@"%@",x);
}];


```

延迟 2 秒后收到 信号 @"delay signalA"



### take 取信号

从开始一共取 N 次的信号发送（0 - (N-1))

```

// 取前 N 个
[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:@"signal 1"];
    [subscriber sendNext:@"signal 2"];
    [subscriber sendNext:@"signal 3"];
    [subscriber sendCompleted];
    return nil;
}] take:2] subscribeNext:^(id  _Nullable x) {
    NSLog(@"take content: %@", x); // only 1 and 2 will be print
}];

```

### skip 跳过

从开始一共跳过 N 次的信号发送，只接受之后的信号

```

// 跳过前 N 个
[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:@"signal 1"];
    [subscriber sendNext:@"signal 2"];
    [subscriber sendNext:@"signal 3"];
    [subscriber sendCompleted];
    return nil;
}] skip:2] subscribeNext:^(id  _Nullable x) {
    NSLog(@"skip : %@", x); // only 3 will be print
}];

```

### takeUntil 获取信号当某个信号执行完成就停止订阅

```

// RAC 这个消息是 2 秒后完成, 所以 signal1 signal2 这两个消息是可以发送到 而 3 秒后的 signal3 signal4 就不会发送.
RACSignal *signal = [[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
    [subscriber sendNext:@"signal1"];
    [subscriber sendNext:@"signal2"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [subscriber sendNext:@"signal3"];
        [subscriber sendNext:@"signal4"];
        [subscriber sendCompleted];
    });
    [subscriber sendCompleted];
    return nil;
}] takeUntil:[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [subscriber sendNext:@"RAC"];
           [subscriber sendCompleted];
       });
       return nil;
   }]];

[signal subscribeNext:^(id _Nullable x) {
    NSLog(@"takeUntil: %@", x); // only signal1 & signal2 will be print
}];

```

### takeLast 获取最后 N 次的信号

前提条件：订阅者必须调用完成，因为只有完成，才知道总共有多少个信号

