---

title: RAC 一些高级用法总结

date: 2019-03-08 13:53:07

tags: RAC

categories: RAC

---


### 1、bind 绑定/包装

没弄明白


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


### concat 合并

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

