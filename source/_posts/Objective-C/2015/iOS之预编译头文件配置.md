---
title: iOS之预编译头文件配置

date: 2015-04-10 11:37:42

tags: iOS

categories: iOS技术

---

### 1、在 Other 下面找到 PCH File 创建

### 2、名字随便，最好还是和项目名一样 例如：TestPrefix.pch

### 3、在 Build Settings（All）下搜索 Prefix Header

![](https://github.com/huangzhifei/huangzhifei.github.com/raw/master/images/prefix.png)

将 Precompile Prefix Header 改为 YES
给 Prefix Header 设置刚才的文件路径 $(SRCROOT)/Test/TestPrefix.pch

clean 之后重新编译就行了，如果出现找不到 TestPrefix.pch 文件时，一定是路径出错了
