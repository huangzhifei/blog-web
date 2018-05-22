---
title: CocoaPods之安装与更新

date: 2015-01-31 15:10:11

tags: CocoaPods

categories: CocoaPods

---

记录一下 cocoapod 的安装与更新，特别 OSX 新版本之后，经常会出现问题，特别是权限的问题。

## 1、gem 更新源

### 1、更新老版本

老版本更新 gem 命令：

```
$ sudo gem update --system
```

可能会报错误：

```
Updating rubygems-update
ERROR:  While executing gem ... (Errno::EPERM)
Operation not permitted - /usr/bin/update_rubygems
```

解决方案：

```
$ sudo gem update - /usr/bin/update_rubygems
```

### 2、切换国内 gem source

```
$ gem sources --add https://ruby.taobao.org/ --remove https://rubygems.org/
```

使用下面命令查看是否替换成功

```
$ gem sources -l
```

会显示如下内容：

```
*** CURRENT SOURCES ***

https://rubygems.org/
https://gems.ruby-china.org/

```


## 2、安装 cocoapods

安装命令：

```
$ sudo gem install cocoapods
```

如果报错：

```
ERROR:  While executing gem ... (Errno::EPERM)
Operation not permitted - /usr/bin/xcodeproj
```

依然是权限的问题，我们就改用下面的命令来安装：

```
$ sudo gem install -n /usr/local/bin cocoapods
```

如果一切顺利，我们就可以 setup 了

```
$ pod setup
```

这个过程会很慢长，你懂的。

## 3、更新 cocoapods

更新命令下面三个都可以

```
sudo gem install -n /usr/local/bin // 默认最新版本
sudo gem install -n /usr/local/bin cocoapods --pre //安装最新版本
sudo gem install -n /usr/local/bin cocoapods -v <version> //安装指定的 version
```

## 4、总结

cocoapods 在我们项目中使用的还是很多的，有时候出问题了，会浪费很多时间，如果重装更慢。

