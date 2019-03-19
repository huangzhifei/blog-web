---
title: git之pull与fetch区别

date: 2014-05-07 11:37:42

tags: git

categories: git常用命令与技巧

---

作者很懒，就留下了一句话

pull 的作用就相当于 fetch 和 merge，自动合并。

```
git fetch origin master
git merge FETCH_HEAD
```

相当于

```
git pull origin master
```

有冲突解决冲突吧。
