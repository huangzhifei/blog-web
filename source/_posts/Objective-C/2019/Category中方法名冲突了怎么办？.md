---

title: Category中方法名冲突了怎么办？

date: 2019-04-01 22:42:56

tags: iOS

categories: iOS技术

---

我们知道，在 Category 里写了与主类同名的方法后，按照 oc 的消息机制调用，会调用 Category 的方法，而主类的同名方法看起来像是被覆盖了。是否真的是被覆盖了？

## Category 方法存在位置

实际上，Category 并没有覆盖主类的同名方法，只是 Category 的方法排在主类方法的前面，而主类的方法被移到了方法列表的后面，对于 oc 的消息发送机制，他是根据方法名在 method_list 中查找方法，找到第一个名字匹配的方法之后就不继续往下找了，所以每次调用的都是 method_list 中最前面的同名方法，实际上其他同名的方法还在 method_list 中。

所以我们可以根据 selector 查找到这类的所有同名 method，然后倒序调用（主类的同名方法在最后面）

```

// 获取类的方法列表
    uint count;
    Method *list = class_copyMethodList([target class], &count);

    // 找到主类的方法，并执行，主类的肯定在分类的后面，所以我们倒序，找到就退出，防止循环嵌套调用后列循环。
    for ( int i = count - 1 ; i >= 0; i--) {
        Method method = list[i];
        SEL name = method_getName(method);
        IMP imp = method_getImplementation(method);
        if (name == selector) {
            ((void (*)(id, SEL))imp)(target, name);
            break;
        }
    }
    free(list);

```

## 多个 Category 的情况？

我们来看看同时定义了多个分类，且都有方法重名的问题，那调用情况是什么样子的？哪个分类的方法会生效？（主类肯定不会生效）

其实这里根编译时的顺序有关（原先我一直以为是随机的，真是孤陋寡闻），我们主要看这几个分类在 Build Phases -> Compile Sources 下面的顺序，分类的顺序靠后，那么他就会后编译，谁后编译，谁就会被调用。

为什么？

因为最后编译的那个 Category，其方法被放在了方法列表的前面，所以会最先找到他。

## 源码分析

我们在分类中触发调用主类的方法时，要注意不能造成死循环，也要注意一下父类的方法调用等。

创建个 NSObject 的分类，留个方法入参 class + selector
`NSObject+InvokeOriginalMethod.h`
```
@interface NSObject (InvokeOriginalMethod)

+ (void *)invokeOriginalMethod:(id)target selector:(SEL)selector;

@end
```

`NSObject+InvokeOriginalMethod.m`
```
+ (void *)invokeOriginalMethod:(id)target selector:(SEL)selector {
    void *result = NULL;

    // Get the class method list
    uint count;
    Method *methodList = class_copyMethodList([target class], &count);

    // check the number of same name
    int number = 0;
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        SEL name = method_getName(method);
        if (name == selector) {
            number++;
        }
    }

    // if only one (just itself), then call super, forbid recursively call.
    if (number == 1) {
        IMP implementation = [self getSuperClassImplementation:target selector:selector];
        // id (*IMP)(id, SEL, ...)
        result = ((void *(*) (id, SEL)) implementation)(target, selector);
    } else {
        // Call original method . Note here take the last same name method as the original method
        for (int i = count - 1; i >= 0; i--) {
            Method method = methodList[i];
            SEL name = method_getName(method);
            IMP implementation = method_getImplementation(method);
            if (selector == name) {
                // id (*IMP)(id, SEL, ...)
                result = ((void *(*) (id, SEL)) implementation)(target, selector);
                break;
            }
        }
    }

    free(methodList);
    return result;
}

+ (IMP)getSuperClassImplementation:(id)target selector:(SEL)selector {
    IMP implementation = NULL;
    Class superClazz = [target superclass];
    while (superClazz) {
        uint count;
        Method *methodList = class_copyMethodList(superClazz, &count);
        for (int i = 0; i < count; i++) {
            Method method = methodList[i];
            SEL name = method_getName(method);
            if (name == selector) {
                implementation = method_getImplementation(method);
                break;
            }
        }
        if (implementation) {
            break;
        } else {
            superClazz = [superClazz superclass];
        }
    }
    return implementation;
}
```

注意上面的一些注释的地方。

## 使用

我们可以给 `ViewController` 的 ` - viewDidLoad ` 方法增加一个分类，方法名一样。

先看主类：

`ViewController.m`

```
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ViewController %@", NSStringFromSelector(_cmd));
}
```

分类：
`ViewController+AViewControllerCategory.h`

```
@interface ViewController (AViewControllerCategory)

- (void)viewDidLoad;

@end
```

`ViewController+AViewControllerCategory.m`
```
@implementation ViewController (AViewControllerCategory)

- (void)viewDidLoad {
    
    NSLog(@"AViewControllerCategory %@", NSStringFromSelector(_cmd));
    [NSObject invokeOriginalMethod:self selector:_cmd];
}

@end
```

在分类中使用我们 hook 方法去触发主类的同名方法调用。

打印输出：

```
AViewControllerCategory viewDidLoad
ViewController viewDidLoad
```

参考链接：[https://blog.csdn.net/WOTors/article/details/52576433]()
