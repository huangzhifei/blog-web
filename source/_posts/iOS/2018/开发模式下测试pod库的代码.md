---
title: 开发模式下测试pod库的代码

date: 2018-10-19 14:14:04

tags: CocoaPods

categories: CocoaPods
---

参照文章 [http://blog.wtlucky.com/blog/2015/02/26/create-private-podspec/]()

前期版本肯定会有大的升级与维护，如何方便的测试？

自己可以创建一个新项目，在Podfile中指定自己编辑好的podspec文件，如下：（两种方式填写一种就行）

```
	pod 'ZJPodPrivateTest', :path => '~/Desktop/ZJPodPrivateTest'      # 指定路径
	# pod 'PodTestLibrary', :podspec => '~/Desktop/ZJPodPrivateTest/ZJPodPrivateTest.podspec'  # 指定podspec文件
	
```

然后执行 pod update 命令安装，然后打开项目发现库文件已经被加载到 Pods 子项目中了，不过没有在 Pods 目录下，而是在 Development Pods/ZJPodPrivateTest 目录下，因为是本地测试项目，没有把 podspec 文件添加到 Spec Repo 中的缘故。

通过这种方式集成后，我们可以很方便的更改 Development Pods/ZJPodPrivateTest 下面的内容从而同步到对应的源文件中。


