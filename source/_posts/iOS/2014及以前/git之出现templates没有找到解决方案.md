---
title: git之出现templates没有找到解决方案

date: 2014-04-10 11:37:42

tags: git

categories: git常用命令与技巧

---

在 Mac 上用 SourceTree 克隆的时候, 偶尔出现了
warning: templates not found /usr/local/git/share/git-core/templates 警告，然后clone一直卡住，最开始以为是网络的问题，但是挂了VPN也这样，怎么办呢？

解决办法

```
sudo mkdir /usr/local/git

sudo mkdir /usr/local/git/share

sudo mkdir /usr/local/git/share/git-core

sudo mkdir /usr/local/git/share/git-core/templates

sudo chmod -R 755 /usr/local/git/share/git-core/templates

```

然后重新 clone 就好了。
