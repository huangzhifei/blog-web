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
 
 ![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/node-version.png)
 
 用键盘上下健选择版本，然后回车就可以切换默认 Node 版本了。
 
 
 ## 直接启动不同版本的 Node
 
 假如我们将默认的 Node 版本设置为 6.10.0了，而我们要使用 7.6.0 来启动某个应用，我们可以使用下面方式：
 
 ```
 n use 7.6.0 index.js
 ```
 
 ## npm 常用命令
 
 下面补充几条 npm 常用命令
 
 ```
 npm -v  显示版本
 
 npm install express 安装 express 模块
 
 npm install -g express 全局安装 express 模块
 
 npm list  列出已安装的模块
 
 npm show express 显示模块详情
 
 npm update express 升级当前目录下项目的所有模块
 
 npm update -g express 升级全局安装的 express 模块
 
 npm uninstall express 删掉指定的模块
 
 ```
 
 ## 总结
 
 更多的用法建议直接去 n 的官方 github 下面去学习。
 
 