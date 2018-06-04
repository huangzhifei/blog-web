---

title: JavaScript之Node版本管理

date: 2018-06-04 10:01:41

tags: JS

categories: JavaScript

---

Node 的版本更新很快，目前最新的稳定版本都更新到 v10.x.x 了，对于生产环境我们一般选择使用 LTS (Long-term Support)版本。

之前常用的 Node 版本管理工具是 [nvm](https://github.com/creationix/nvm)，这是一个 shell 工具，能够比较方便地切换 Node 版本。

今天我们介绍另一个 Node 版本管理工具，他本身是一个 Node 模块，叫做 [n](https://github.com/tj/n)，强调简单化的版本管理。

## 安装 n

要安装 n 非常简单，他本身就是一个 npm 模块

```
npm -g install n
```


 ## 使用和设置
 
 要使用 n 安装特定环境的 node，只需要如下命令：（更多更详细的命令见 n 的 github 说明）
 
 ```
 n stable #安装最新的稳定版
 n lts #安装最新的 TLS 版
 n 6.9.0 #安装特定的 v6.9.0 版本
 ```
 
 安装完成多个版本后，直接输入不带参数的 n 命令，会出现一个已安装版本的列表：
 
 