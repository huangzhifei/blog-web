---
title: iOS 渲染过程

date: 2018-10-11 18:07:58

tags: iOS

categories: iOS技术
---

参照文章 [iOS界面渲染流程分析](https://mp.weixin.qq.com/s/PZfhNiRMSlPSaIFI20gdbQ)


## 问题一

**APP 从点击屏幕到完全渲染出来，这其中发生了一些什么事情？**

1、首先一个视图由CPU进行Frame布局，准备视图和图层的层级关系，查询是否有重写drawRect:或drawLayer:inContext:方法，注意：如果有重写的话，这里的渲染是会占用CPU进行处理的。

2、CPU会将处理视图和图层的层级关系打包，通过IPC（内部处理通信）通道提交给渲染服务，渲染服务由OpenGL ES和GPU组成。

3、渲染服务首先将图层数据交给OpenGL ES进行纹理生成和着色。生成前后帧缓存，再根据显示硬件的刷新频率，一般以设备的Vsync信号和CADisplayLink为标准，进行前后帧缓存的切换。

4、最后，将最终要显示在画面上的后帧缓存交给GPU，进行采集图片和形状，运行变换，应用文理和混合。最终显示在屏幕上。


## 问题二

**一个 UIImageView 添加到视图上以后，内部是如何渲染到手机上的？**

1、获取图片二进制数据。

2、创建一个CGImageRef对象。

3、使用CGBitmapContextCreate()方法创建一个上下文对象。

4、使用CGContextDrawImage()方法绘制到上下文。

5、使用CGBitmapContextCreateImage()生成CGImageRef对象。

6、最后使用imageWithCGImage()方法将CGImage转化为UIImage。

## 问题三

**表中有很多个 cell，每个 cell 上有很多个视图，如何解决卡顿？**

卡顿的定义：当你的主线程操作卡顿超过16.67ms以后，你的应用就会出现掉帧，丢帧的情况。也就是卡顿。

一般来说造成卡顿的原因，就是CPU负担过重，响应时间过长。主要原因有以下几种：

1、隐式绘制 CGContext

2、文本CATextLayer 和 UILabel

3、光栅化 shouldRasterize

4、离屏渲染

5、可伸缩图片

6、shadowPath

7、混合和过度绘制

8、减少图层数量

9、裁切

10、对象回收

11、Core Graphics绘制

12、- renderInContext: 方法

参照 YYAsyncLayer 、 AsyncDisplayKit 等三方库