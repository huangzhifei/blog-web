---

title: podspec的subspec使用

date: 2018-10-17 11:05:05

tags: CocoaPods

categories: CocoaPods

---

参照官方文档 [subspec](https://guides.cocoapods.org/syntax/podspec.html#group_subspecs)

### 预处理宏配置

#### 什么是预处理

上一段 JSPatch 的经典代码

	[JSPatch startWithAppKey:@"YOU_GUESS"];
	#ifdef DEBUG
	[JSPatch setupDevelopment];
	#endif
	[JSPatch sync];
	
上面代码中那个 DEBUG 就是预处理宏，这是编译器给我们内置好了的，我们可以自己定义一个，但是我们使用外部第三方的时候，可能并不知道要定义什么样子的预编译宏，如果外部能帮我们做那不太好了，cocoapods 就可以。

#### subspec 配置预编译宏

一个第三方库会有很多功能，其中有一部分功能需要在编译阶段就决定是否引入。比如 IDFA，Apple 要求使用的话需要在提交审核的时候声明，不然就被拒。此时如果应用不用，那就会被你拖累。所以需要提供一个方法从代码里删除，这就需要用到预处理宏。用类似上面的方式改好后，让用户在 Build Settings 里设置一下就 OK。
如果这个库支持 CocoaPods，可以建一个 subspec 省去用户手动修改：

	s.subspec 'IDFA' do |f|
	  f.dependency 'YOUR_SPEC/core'
	  f.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'ENABLE_IDFA=1'}
	end

可以多看看 FMDB、SDWebImage 等流行库的 podspec 写法。

当有多个预处理宏需要设置，可以都写在这一个里面。
可如果不想写在一起，想让用户自己选择开启某些的话，怎么办？
答案很简单，多写几个 subspec。用户需要哪个，就引入哪个。

### subspec 的模块化配置

使用 subspec 可以实现良好的代码分层，依赖也更清晰

```

Pod::Spec.new do |s|

  #设置 podspec 的默认 subspec
  s.default_subspec = 'core'
  #主要 subspec
  s.subspec 'core' do |c|
    c.source_files  = "*.{h,m}"
    c.public_header_files = "*.h"
    c.frameworks = 'UIKit',
    c.libraries = 'icucore', 'sqlite3', 'z'
    c.platform = :ios, "7.0"
  end
  #功能1，引入则开启
  s.subspec 'IDFA' do |f|
    # 子模块的个自的源码路径
    f.source_files = 'FSLib/**/*'
    # 子模块要暴露的头文件
    f.public_header_files='FSLib/A/A.h'
    f.dependency 'YOUR_SPEC/core'
    f.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'ENABLE_IDFA=1'}
  end

  #功能2，引入则开启
  s.subspec 'IDFB' do |f|
    f.dependency 'YOUR_SPEC/core'
    f.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'ENABLE_IDFB=1'}
  end  

end

```

这里面通过两个 subpec 来开关功能。当用户用的时候，则在 Podfile 里这么引入

```
# 远程引用
pod 'YOUR_SPEC', :subspecs => ['IDFA', 'IDFB'] 或
pod 'YOUR_SPEC', '0.1.2', :subspecs => ['IDFA', 'IDFB']

# 本地相对路径引用
pod 'YOUR_SPEC', :path =>'../../sources' , :subspecs => ['IDFA', 'IDFB']

```

通过上面的方式就能控制 pod 下来是哪个 subspec 的代码，不用把整个都 pod 下来，也能自动配置好预处理宏。

### subspec 常用三方库的使用

一般一个大的项目写成pod的时候，它可能会分为多个subspec，这样的话当你用一个庞大的库时，只需要其中的一小部分，那么就可以使用其中的某个subspec了。我们拿AFNetworking.podspec来看，比如只引入其中的Reachability：

```
pod 'AFNetworking/Reachability'
或者
pod 'AFNetworking',:subspecs=>['Reachability','Security']

```

所以一般subspec之间最好不要有互相依赖，不然的话，你用了其中一个subspec，而它其中一个文件依赖了另一个你未引入的subspec中的文件的话是会报错的。

如果有多个subspec互相依赖的话，可以像AFNetworking.podspec里这样写，UIKit依赖于NSURLSession:

```

s.subspec 'NSURLSession' do |ss|
    //省略一大段代码
end

s.subspec 'UIKit' do |ss|
    ss.ios.deployment_target = '7.0'
    ss.tvos.deployment_target = '9.0'
    ss.dependency 'AFNetworking/NSURLSession'

    ss.public_header_files = 'UIKit+AFNetworking/*.h'
    ss.source_files = 'UIKit+AFNetworking'
end

```


### 结论

所以可以把subspec当做一个小型的pod来看，我们可以看一下pod AFNetworking安装之后，Podfile.lock中的pod安装目录。可以看出那些subspec也算是一个pod。

```

PODS:
  - AFNetworking (3.0.0):
    - AFNetworking/NSURLSession (= 3.0.0)
    - AFNetworking/Reachability (= 3.0.0)
    - AFNetworking/Security (= 3.0.0)
    - AFNetworking/Serialization (= 3.0.0)
    - AFNetworking/UIKit (= 3.0.0)
  - AFNetworking/NSURLSession (3.0.0):
    - AFNetworking/Reachability
    - AFNetworking/Security
    - AFNetworking/Serialization
  - AFNetworking/Reachability (3.0.0)
  - AFNetworking/Security (3.0.0)
  - AFNetworking/Serialization (3.0.0)
  - AFNetworking/UIKit (3.0.0):
    - AFNetworking/NSURLSession
DEPENDENCIES:
  - AFNetworking (= 3.0)
SPEC CHECKSUMS:
  AFNetworking: 932ff751f9d6fb1dad0b3af58b7e3ffba0a4e7fd

PODFILE CHECKSUM: f38d14cf91adf9e2024f841ce5336dae96aa6fa6

COCOAPODS: 1.6.0.beta.1

```

