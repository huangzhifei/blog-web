---

title: RAC 一些高级用法总结

date: 2019-03-08 13:53:07

tags: RAC

categories: RAC

---


### bind 绑定/包装

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

### distinctUntilChanged 对比上一次信号内容

实现是用 bind 来完成的，每次变换中都记录一下原信号上一次发送过来的值，并与这一次进行比较，如果是相同的值，就“吞掉”，返回 empty 信号，只有和原信号上一次发送的值不同才会变换成新信号把这个值发送出去。

```

RACSubject *signal = [RACSubject subject];
[[signal distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
    NSLog(@"distinctUntilChanged : %@", x); // will only print "eric", "eric hzf", "eric"
}];

// 发送一次信号，内容为 eric
[signal sendNext:@"eric"];

// 发送二次信号，内容依然为 eric，但是使用 distinctUntilChanged 后不会在接收与上一次重复的内容
[signal sendNext:@"eric"];

// 发送三次信号，内容为 eric hzf
[signal sendNext:@"eric hzf"];


```


### flattenMap & map 映射

flattenMap 和 map 都是用于把源信号内容映射成新的内容

##### flattenMap 的底层实现是通过 bind 实现的
##### map 的底层实现是通过 flattenMap 实现的

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

前提条件：订阅者必须调用完成，因为只有完成，才知道总共有多少个信号。

```

RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@"signal1"];
    [subscriber sendNext:@"signal2"];
    [subscriber sendNext:@"signal3"];
    [subscriber sendNext:@"signal4"];
    [subscriber sendCompleted];
    // 上面调用 sendCompleted 之后，会直接进入下面的订阅回调，打印最后 3 条信号，然后在打印下面的 "send completed"
    NSLog(@"send completed");
    return nil;

}] takeLast:3];

[signal subscribeNext:^(id x) {
    NSLog(@"testTakeLast : %@",x); // 会打印最后 3 条，并且所有的信号都已经发送完成了。
}];

```


### switchToLatest

获取信号中信号最近发出信号，订阅最近发出的信号。

注意：switchToLatest 使用的对象是信号中的信号（signalOfsignals)，即 sendNext 的参数也是信号。


```

RACSubject *signalOfSignals = [RACSubject subject];
RACSubject *signalA = [RACSubject subject];
RACSubject *signalB = [RACSubject subject];
// 获取信号中信号最近发出信号，订阅最近发出的信号。
// 注意switchToLatest：只能用于信号中的信号
[signalOfSignals.switchToLatest subscribeNext:^(id x) {
    NSLog(@"switchToLatest: %@", x); // will only print signalB
}];
[signalOfSignals sendNext:signalA];
[signalOfSignals sendNext:signalB];
[signalA sendNext:@"signalA"];
[signalB sendNext:@"signalB"];

```

### doNext 

执行 next 之前，会先执行这个 block


```

[[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    NSLog(@"testDoNextAndDoCompleted start sendNext");
    [subscriber sendNext:@"hello do next"];
    NSLog(@"testDoNextAndDoCompleted end sendNext");
    
    NSLog(@"testDoNextAndDoCompleted start sendCompleted");
    [subscriber sendCompleted];
    NSLog(@"testDoNextAndDoCompleted end sendCompleted");
    
    return nil;
}] doNext:^(id  _Nullable x) {
    // 在执行 [subscriber sendNext:@"hello do next"]; 之前会先执行 doNext：
    NSLog(@"test do next");
}] doCompleted:^{
    // 在执行 [subscriber sendCompleted]; 之前会先执行 doCompleted：
    NSLog(@"test do completed");
}] subscribeNext:^(id  _Nullable x) {
    NSLog(@"testDoNextAndDoCompleted: %@", x);
}];

/*
 最终打印顺序：
 
 testDoNextAndDoCompleted start sendNext
 test do next
 testDoNextAndDoCompleted: hello do next
 testDoNextAndDoCompleted end sendNext
 testDoNextAndDoCompleted start sendCompleted
 test do completed
 testDoNextAndDoCompleted end sendCompleted

 **/


```


### doCompleted

执行 sendCompleted 之前，会先执行这个Block。

详细例子见上面 doNext


### timeout 超时

如果一个信号在指定时间内没有发送信号，就会超时，可以让一个信号在一定的时间后，自动报错。

```

[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    
    //无任何操作 等超时
    
//        [subscriber sendNext:@"signal A"];
//        NSError *error = [[NSError alloc]initWithDomain:@"unknwn domain" code:600 userInfo:@{@"error":@"超时"}];
//        [subscriber sendError:error];
//        [subscriber sendCompleted];
    return nil;
}] timeout:3.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id  _Nullable x) {
    NSLog(@"timeout :%@", x); // 超时后不会进入到这里
} error:^(NSError * _Nullable error) {
    NSLog(@"timeout 超时: %@", error); // 3 秒超时后，会打印超时错误
}];


```


### retry 重试 或 retry:count

重试，只要失败，就会重新执行创建信号中的 block，一直重试，直到成功。
如果后面指定次数，就会在相应的次数之后结束。


```

// 重试，不执行 error block，一直到执行 sendNext 成功才结束
__block NSInteger count = 1;
[[[RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (count == 5) {
            [subscriber sendNext:@"retry 执行 sendNext 成功"];
            [subscriber sendCompleted];
        } else {
            // 注意：这里一定要发送一个错误信号，不然就不会继续往下面走，也就永远不会达到错误重试的次数和效果
            // 但是这个 error 是不会被下面的 error：订阅到的，也就是说不会触发下面那个 error：的监听
            [subscriber sendError:[NSError errorWithDomain:@"unknown domain"
                                                      code:500
                                                  userInfo:@{
                                                      @"msg" : [NSString stringWithFormat:@"次数：%ld", count]
                                                  }]];
        }
        ++count;
    });
    return nil;
}] retry:6] subscribeNext:^(id _Nullable x) {
    NSLog(@"retry: %@", x);
} error:^(NSError *_Nullable error) {
    NSLog(@"retry error: %@", error);
}];

```

注意上面代码中的注释，必须要发送一个 error 信号的，并且要知道他是错误重试，如果不发生错误就不会重试的。



### replay 反复播放（不是重新触发执行）

多个订阅者，只执行一遍副作用，如果没有 replay 就要重复执行副作用。


```

__block NSInteger count = 1; // 副作用
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:[NSString stringWithFormat:@"signal A with count = %ld", count]];
        ++ count;
        [subscriber sendNext:[NSString stringWithFormat:@"signal B with count = %ld", count]];
        ++count;
        return nil;
    }] replay];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"test replay 订阅1: %@", x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"test replay 订阅2: %@", x);
    }];
    
    // 使用 replay 打印输出：
    /*
     test replay 订阅1: signal A with count = 1
     test replay 订阅1: signal B with count = 2
     test replay 订阅2: signal A with count = 1
     test replay 订阅2: signal B with count = 2
     **/
    
    // 不使用 replay 打印输出：
    /*
     test replay 订阅1: signal A with count = 1
     test replay 订阅1: signal B with count = 2
     test replay 订阅2: signal A with count = 3
     test replay 订阅2: signal B with count = 4
     **/

```

从上面的打印可以看出来：
1. 使用 replay 之后，就像是一个镜像一样了，之后的订阅都是在重复播放之前的镜像，所以外面的副作用 count 的值不会在继续增长。
2. 不使用 replay 的话，那么下面的每一次的订阅都会重新触发一次发送信号，副作用 count 的值就会持续增长。




### repeat 无限循环的重复执行


```

RACSignal *signal = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
    [subscriber sendNext:@"signal A"];
    [subscriber sendCompleted];
    return nil;
}];

// 使用 repeat 之后，将无限循环的接收信号
[[[signal delay:1.0] repeat] subscribeNext:^(id  _Nullable x) {
    NSLog(@"testRepeat: %@", x); // 无限循环打印：testRepeat: signal A
}];

```

由于使用 delay:1.0，所以会每隔 1 秒打印一次，如果不使用将会没有间隔的重复打印。



### throttle 节流

当某个信号发送比较频繁时，可以使用节流，在某一段时间差不发送信号内容，过一段时间差后获取信号最新发出的内容，常用场景：

1. 阻止 “快速点击” 重复响应等问题。
2. 输入框内容不是一变化就请求后台（后台扛不住)，可以延迟一会在请求或者输入很快可以让其快速只响应最终的结果。



```

RACSubject *subject = [RACSubject subject];
[[subject throttle:0.5] subscribeNext:^(id _Nullable x) {
    NSLog(@"throttle: %@", x); // 打印：signalB、signalC、signalD、signalE
}];

[subject sendNext:@"signalA"];
[subject sendNext:@"signalB"];
// 1、signalA 和 signalB 之间间隔不足 0.5 秒，但是 signalB 与 signalC 间隔超过 0.5 秒，所以先打印 signalB
// 2、signalC 和 signalD 之间间隔超过 0.5 秒，所以会打印 signalC
// 3、signalD 和 signalE 之间间隔超过 0.5 秒，所以会打印 signalD
// 4、signalE 之后没有了，所以会打印 signalE
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [subject sendNext:@"signalC"];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [subject sendNext:@"signalD"];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [subject sendNext:@"signalE"];
    });
});

```

打印输出：

```

打印：signalB、signalC、signalD、signalE

```

分析：

1. signalA 和 signalB 之间间隔不足 0.5 秒，但是 signalB 与 signalC 间隔超过 0.5 秒，所以先打印 signalB。
2. signalC 和 signalD 之间间隔超过 0.5 秒，所以会打印 signalC。
3. signalD 和 signalE 之间间隔超过 0.5 秒，所以会打印 signalD。
4. signalE 之后没有了，所以会打印 signalE。


### zip

给定一个信号数组 signal_array[N]，创建一个信号 zip_return，当订阅 zip_return 时，会等待 signal_array 中每一个信号都 sendNext:value 后，zip_return 才会 sendNext，zip_return 传出的值是 [value1, value2, ......, valueN];

```
RACSignal *signalA = [RACSignal createSignal:
                                   ^RACDisposable *(id<RACSubscriber> subscriber) {
                                       [subscriber sendNext:@"signal A1"];
                                       [subscriber sendNext:@"signal A2"];
                                       [subscriber sendCompleted];
                                       return [RACDisposable disposableWithBlock:^{
                                           NSLog(@"signalA dispose");
                                       }];
                                   }];

RACSignal *signalB = [RACSignal createSignal:
                                    ^RACDisposable *(id<RACSubscriber> subscriber) {
                                        [subscriber sendNext:@"signal B1"];
                                        [subscriber sendNext:@"signal B2"];
                                        [subscriber sendNext:@"signal B3"];
                                        [subscriber sendCompleted];
                                        return [RACDisposable disposableWithBlock:^{
                                            NSLog(@"signalB dispose");
                                        }];
                                    }];

RACSignal *signalC = [RACSignal createSignal:
                      ^RACDisposable *(id<RACSubscriber> subscriber) {
                          [subscriber sendNext:@"signal C1"];
//                              [subscriber sendNext:@"signal C2"];
                          [subscriber sendCompleted];
                          return [RACDisposable disposableWithBlock:^{
                              NSLog(@"signalC dispose");
                          }];
                      }];

[[RACSignal zip:@[ signalA, signalB, signalC ]] subscribeNext:^(id x) {
    NSLog(@"testZip: %@", x); // 打印元组 RACTuple
}];

// 打印
// 因为 signalC 只发出了一个信号，所以没法消耗掉其他的，只会有一组打印
/*
 testZip: <RACTuple: 0x6000039c3e50> (
 "signal A1",
 "signal B1",
 "signal C1"
 )
 **/
 
```

可以看出来，他其实是 zipWith 的加强版本。



### zipWith

两个信号压缩！要两个信号都发出信号，会将其内容合并成一个元组给你，然后下一次触发条件依然是两个信号都有发送。

```

RACSubject *subjectA = [RACSubject subject];
RACSubject *subjectB = [RACSubject subject];

RACSignal *zipSignal = [subjectA zipWith:subjectB];
[zipSignal subscribeNext:^(id  _Nullable x) {
    NSLog(@"testZipWith: %@", x); // 这里会压缩成一个元组
}];

[subjectA sendNext:@"subjectA 1"];
[subjectA sendNext:@"subjectA 2"];
[subjectA sendNext:@"subjectA 3"];

[subjectB sendNext:@"subjectB 1"];
[subjectB sendNext:@"subjectB 2"];


// 打印
// 1: 当 subjectB 只发送了一个信号 @"subjectB 1"，他只会消耗 subjectA 一个信号 @"subjectA 1"，所以 subjectA 之后的两个信号是没法被消耗的。
/*
 testZipWith: <RACTwoTuple: 0x600001983eb0> (
 "subjectA 1",
 "subjectB 1"
 )
 **/

// 2: 如果 subjectB 发送了两个信号 @"subjectB 1"、@"subjectB 2"，他相应的就会消耗 subjectA 的两个信号。
/*
 testZipWith: <RACTwoTuple: 0x600003ef1460> (
 "subjectA 1",
 "subjectB 1"
 )
 
 testZipWith: <RACTwoTuple: 0x600003eec180> (
 "subjectA 2",
 "subjectB 2"
 )
 **/

```



### startWith

在发送消息之前，先发送一个消息。

```

[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:@"signal A"];
    [subscriber sendCompleted];
    return nil;
}] startWith:@"start with"] subscribeNext:^(id  _Nullable x) {
    NSLog(@"testStartWith: %@", x); // 先打印：testStartWith: start with 然后在打印：testStartWith: signal A
}];

```


