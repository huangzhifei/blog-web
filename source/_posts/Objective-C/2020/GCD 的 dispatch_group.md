---

title: GCD 的 dispatch_group

date: 2020-09-21 17:30:48

tags: iOS

categories: iOS技术

---

# 聊聊 GCD 的 dispatch_group

## 一、概述

`dispatch_group` 可以将 `GCD` 的任务合并到一个组里来管理，也可以同时监听组里所有任务的执行情况。主要的 `API` 有以下几个,先看一下 `Dispatch Group` 的具体使用。

* **dispatch_group_create**
* **dispatch_group_enter**
* **dispatch_group_leave**
* **dispatch_group_wait**
* **dispatch_group_notify**
* **dispatch_group_async**

## 二、使用篇

`dispatch_group` 最多的用法便是用 `dispatch_group_enter` 和`dispatch_group_leave` 实现一组任务完成的监控或回调，见代码示例:

```
- (void)batchRequestConfig {
    dispatch_group_t group = dispatch_group_create();
    NSArray *list = @[@"1",@"2",@"3"];
    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //标记开始本次请求
        dispatch_group_enter(group);
        [self fetchConfigurationWithCompletion:^(NSDictionary *dict) {
            //标记本次请求完成
            dispatch_group_leave(group);
        }];
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //所有请求都完成了,执行刷新UI等操作
    });
}
- (void)fetchConfigurationWithCompletion:(void(^)(NSDictionary *dict))completion {
    //AFNetworking或其他网络请求库
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模拟网络请求
        sleep(2);
        !completion ? nil : completion(nil);
    });
}

```

`dispatch_group` 有两个需要注意的地方：

**1、dispatch_group_enter必须在dispatch_group_leave之前出现**
**2、dispatch_group_enter和dispatch_group_leave必须成对出现**

## 三、原理篇

### 1、dispatch_group_create

dispatch group 的本质是一个初始 value 为 LONG_MAX 的 semaphore，通过信号量来实现一组任务的管理，代码如下：

```
dispatch_group_t dispatch_group_create(void) {
    //申请内存空间
    dispatch_group_t dg = (dispatch_group_t)_dispatch_alloc(
            DISPATCH_VTABLE(group), sizeof(struct dispatch_semaphore_s));
    //使用LONG_MAX初始化信号量结构体
    _dispatch_semaphore_init(LONG_MAX, dg);
    return dg;
}

```

### 2、dispatch_group_enter

```

 void dispatch_group_enter(dispatch_group_t dg) {
    dispatch_semaphore_t dsema = (dispatch_semaphore_t)dg;
    long value = dispatch_atomic_dec2o(dsema, dsema_value, acquire);
    if (slowpath(value < 0)) {
        DISPATCH_CLIENT_CRASH(
                "Too many nested calls to dispatch_group_enter()");
    }
}

```

dispatch_group_enter 的逻辑是将 dispatch_group_t 转换成dispatch_semaphore_t 后将 dsema_value 的**值减一**。


### 3、dispatch_group_leave

```
void dispatch_group_leave(dispatch_group_t dg) {
    dispatch_semaphore_t dsema = (dispatch_semaphore_t)dg;
    long value = dispatch_atomic_inc2o(dsema, dsema_value, release);
    if (slowpath(value < 0)) {
        DISPATCH_CLIENT_CRASH("Unbalanced call to dispatch_group_leave()");
    }
    if (slowpath(value == LONG_MAX)) {
        (void)_dispatch_group_wake(dsema);
    }
}
```

dispatch_group_leave 的逻辑是将 dispatch_group_t 转换成dispatch_semaphore_t 后将 dsema_value 的**值加一**。
当 value 等于 LONG_MAX 时表示所有任务已完成，调用 _dispatch_group_wake 唤醒group，因此 dispatch_group_leave 与 dispatch_group_enter 需成对出现。

当调用了 dispatch_group_enter 而没有调用 dispatch_group_leave 时，会造成value 值不等于 LONG_MAX 而不会走到唤醒逻辑，dispatch_group_notify 函数的 block 无法执行或者 dispatch_group_wait 收不到 semaphore_signal 信号而卡住线程。

当 dispatch_group_leave 比 dispatch_group_enter 多调用了一次时，dispatch_semaphore_t 的 value 会等于 LONGMAX+1（2147483647+1）,即long的负数最小值LONG_MIN(–2147483648)。因为此时value小于0，所以会出现"Unbalanced call to dispatch_group_leave()"的崩溃，这是一个特别需要注意的地方。


### 4、dispatch_group_wait

```
long dispatch_group_wait(dispatch_group_t dg, dispatch_time_t timeout) {
    dispatch_semaphore_t dsema = (dispatch_semaphore_t)dg;

    if (dsema->dsema_value == LONG_MAX) {
        return 0;
    }
    if (timeout == 0) {
        return KERN_OPERATION_TIMED_OUT;
    }
    return _dispatch_group_wait_slow(dsema, timeout);
}
```

如果当前value的值为初始值，表示任务都已经完成，直接返回0，如果timeout为0的话返回超时。其余情况会调用_dispatch_group_wait_slow方法。

代码如下：

```
static long _dispatch_group_wait_slow(dispatch_semaphore_t dsema, dispatch_time_t timeout) {
    long orig;
    mach_timespec_t _timeout;
    kern_return_t kr;
again:
    if (dsema->dsema_value == LONG_MAX) {
        return _dispatch_group_wake(dsema);
    }
    (void)dispatch_atomic_inc2o(dsema, dsema_group_waiters, relaxed);
    if (dsema->dsema_value == LONG_MAX) {
        return _dispatch_group_wake(dsema);
    }
    _dispatch_semaphore_create_port(&dsema->dsema_port);
    switch (timeout) {
    default:
        do {
            uint64_t nsec = _dispatch_timeout(timeout);
            _timeout.tv_sec = (typeof(_timeout.tv_sec))(nsec / NSEC_PER_SEC);
            _timeout.tv_nsec = (typeof(_timeout.tv_nsec))(nsec % NSEC_PER_SEC);
            kr = slowpath(semaphore_timedwait(dsema->dsema_port, _timeout));
        } while (kr == KERN_ABORTED);

        if (kr != KERN_OPERATION_TIMED_OUT) {
            DISPATCH_SEMAPHORE_VERIFY_KR(kr);
            break;
        }
    case DISPATCH_TIME_NOW:
        orig = dsema->dsema_group_waiters;
        while (orig) {
            if (dispatch_atomic_cmpxchgvw2o(dsema, dsema_group_waiters, orig,
                    orig - 1, &orig, relaxed)) {
                return KERN_OPERATION_TIMED_OUT;
            }
        }
    case DISPATCH_TIME_FOREVER:
        do {
            kr = semaphore_wait(dsema->dsema_port);
        } while (kr == KERN_ABORTED);
        DISPATCH_SEMAPHORE_VERIFY_KR(kr);
        break;
    }
    goto again;
 }
```
可以看到跟dispatch_semaphore的_dispatch_semaphore_wait_slow方法很类似，不同点在于等待完之后调用的again函数会调用_dispatch_group_wake唤醒当前group。

### 5、dispatch_group_notify

```
void dispatch_group_notify(dispatch_group_t dg, dispatch_queue_t dq,
        dispatch_block_t db) {
    //封装调用dispatch_group_notify_f函数
    dispatch_group_notify_f(dg, dq, _dispatch_Block_copy(db),
            _dispatch_call_block_and_release);
}
//真正的入口函数
void dispatch_group_notify_f(dispatch_group_t dg, dispatch_queue_t dq, void *ctxt,
        void (*func)(void *)) {
    dispatch_semaphore_t dsema = (dispatch_semaphore_t)dg;
    //封装结构体
    dispatch_continuation_t prev, dsn = _dispatch_continuation_alloc();
    dsn->do_vtable = (void *)DISPATCH_OBJ_ASYNC_BIT;
    dsn->dc_data = dq;
    dsn->dc_ctxt = ctxt;
    dsn->dc_func = func;
    dsn->do_next = NULL;
    _dispatch_retain(dq);
    //将结构体放到链表尾部，如果链表为空同时设置链表头部节点并唤醒group
    prev = dispatch_atomic_xchg2o(dsema, dsema_notify_tail, dsn, release);
    if (fastpath(prev)) {
        prev->do_next = dsn;
    } else {
        _dispatch_retain(dg);
        dispatch_atomic_store2o(dsema, dsema_notify_head, dsn, seq_cst);
        dispatch_atomic_barrier(seq_cst); // <rdar://problem/11750916>
        if (dispatch_atomic_load2o(dsema, dsema_value, seq_cst) == LONG_MAX) {
            _dispatch_group_wake(dsema);
        }
    }
}
```

dispatch_group_notify的具体实现在dispatch_group_notify_f函数里，逻辑就是将block和queue封装到dispatch_continuation_t里，并将它加到链表的尾部，如果链表为空同时还会设置链表的头部节点。如果dsema_value的值等于初始值，则调用_dispatch_group_wake执行唤醒逻辑。

dispatch_group_wake 代码如下：

```
static long _dispatch_group_wake(dispatch_semaphore_t dsema) {
    dispatch_continuation_t next, head, tail = NULL, dc;
    long rval;
   //将dsema的dsema_notify_head赋值为NULL，同时将之前的内容赋给head
    head = dispatch_atomic_xchg2o(dsema, dsema_notify_head, NULL, relaxed);
    if (head) {
        //将dsema的dsema_notify_tail赋值为NULL，同时将之前的内容赋给tail
        tail = dispatch_atomic_xchg2o(dsema, dsema_notify_tail, NULL, relaxed);
    }
    rval = (long)dispatch_atomic_xchg2o(dsema, dsema_group_waiters, 0, relaxed);
    if (rval) {
        // wake group waiters
        _dispatch_semaphore_create_port(&dsema->dsema_port);
        do {
            kern_return_t kr = semaphore_signal(dsema->dsema_port);
            DISPATCH_SEMAPHORE_VERIFY_KR(kr);
        } while (--rval);
    }
    if (head) {
        // async group notify blocks
        do {
            next = fastpath(head->do_next);
            if (!next && head != tail) {
                while (!(next = fastpath(head->do_next))) {
                    dispatch_hardware_pause();
                }
            }
            dispatch_queue_t dsn_queue = (dispatch_queue_t)head->dc_data;
            dc = _dispatch_continuation_free_cacheonly(head);
            //执行dispatch_group_notify的block，见dispatch_queue的分析
            dispatch_async_f(dsn_queue, head->dc_ctxt, head->dc_func);
            _dispatch_release(dsn_queue);
            if (slowpath(dc)) {
                _dispatch_continuation_free_to_cache_limit(dc);
            }
        } while ((head = next));
        _dispatch_release(dsema);
    }
    return 0;
}
```

dispatch_group_wake首先会循环调用semaphore_signal唤醒等待group的信号量，使dispatch_group_wait函数中等待的线程得以唤醒；然后依次获取链表中的元素并调用dispatch_async_f异步执行dispatch_group_notify函数中注册的回调，使得notify中的block得以执行。


### 6、dispatch_group_async

dispatch_group_async 的原理和 dispatch_async 比较类似，区别点在于 group 操作会带上 DISPATCH_OBJ_GROUP_BIT 标志位，添加 group 任务时会先执行 dispatch_group_enter，然后在任务执行时会对带有该标记的执行 dispatch_group_leave 操作。具体代码如下：

```
void dispatch_group_async(dispatch_group_t dg, dispatch_queue_t dq,
        dispatch_block_t db) {
    //封装调用dispatch_group_async_f函数
    dispatch_group_async_f(dg, dq, _dispatch_Block_copy(db),
            _dispatch_call_block_and_release);
}
void dispatch_group_async_f(dispatch_group_t dg, dispatch_queue_t dq, void *ctxt,
        dispatch_function_t func) {
    dispatch_continuation_t dc;
    _dispatch_retain(dg);
    //先调用dispatch_group_enter操作
    dispatch_group_enter(dg);
    dc = _dispatch_continuation_alloc();
    //DISPATCH_OBJ_GROUP_BIT会在_dispatch_continuation_pop方法中用来判断是否为group，如果为group会执行dispatch_group_leave
    dc->do_vtable = (void *)(DISPATCH_OBJ_ASYNC_BIT | DISPATCH_OBJ_GROUP_BIT);
    dc->dc_func = func;
    dc->dc_ctxt = ctxt;
    dc->dc_data = dg;
    if (dq->dq_width != 1 && dq->do_targetq) {
        return _dispatch_async_f2(dq, dc);
    }
    _dispatch_queue_push(dq, dc);
}

```

dispatch_group_async_f与dispatch_async_f代码类似，主要执行了以下操作：
1、调用dispatch_group_enter
2、将block和queue等信息记录到dispatch_continuation_t中，并将它加入到group的链表中。
3、_dispatch_continuation_pop执行时会判断任务是否为group，是的话执行完任务再调用dispatch_group_leave以达到信号量value的平衡。

_dispatch_continuation_pop简化后的代码如下：

```
static inline void _dispatch_continuation_pop(dispatch_object_t dou) {
    dispatch_continuation_t dc = dou._dc, dc1;
    dispatch_group_t dg;
    _dispatch_trace_continuation_pop(_dispatch_queue_get_current(), dou);
    //判断是否为队列，是的话执行队列的invoke函数
    if (DISPATCH_OBJ_IS_VTABLE(dou._do)) {
        return dx_invoke(dou._do);
    } 
    //dispatch_continuation_t结构体，执行具体任务
    if ((long)dc->do_vtable & DISPATCH_OBJ_GROUP_BIT) {
        dg = dc->dc_data;
    } else {
        dg = NULL;
    }
    _dispatch_client_callout(dc->dc_ctxt, dc->dc_func);
    if (dg) {
       //这是group操作，执行leave操作对应最初的enter
        dispatch_group_leave(dg);
        _dispatch_release(dg);
    }
}

```


## 四、总结篇

1. dispatch_group本质是个初始值为LONG_MAX的信号量，等待group中的任务完成其实是等待value恢复初始值。

2. dispatch_group_enter和dispatch_group_leave必须成对出现。

3. 如果dispatch_group_enter比dispatch_group_leave多一次，则wait函数等待的
4. 线程不会被唤醒和注册notify的回调block不会执行；

5. 如果dispatch_group_leave比dispatch_group_enter多一次，则会引起崩溃。