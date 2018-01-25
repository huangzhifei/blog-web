---

title: hexo-markdown简单语法

date: 2018-01-26 16:32:09

tags: hexo+github

categories: hexo配置

---

## 内容目录

如果在段落中填写 toc: ture 将会显示全文内容的目录结构


## 文章头格式

基本格式示例如下：

```
---
title: Hexo Markdown简单语法
date: 2018-01-02 20:09:32
tags: [语法,教程,markdown]
categories: 学习
toc: true
mathjax: true
...
---
```

这样填写后，Hexo 就会自动解析到对应的年份、对应的分类、对应的tags等等

## 斜体和粗体

使用 * 和 ** 包裹表示斜体和粗体

```
*斜体*
**粗体**
```

渲染效果：这是 *斜体*，这是 **粗体**

## 分级标题

使用 === 表示一级标题， 使用 --- 表示二级标题，最少需要一个符号（=和-）

```
这是一级标题
==========

这是二级标题
----------
```

但是我们还是习惯方便使用下 # 号来表示不同级别的标题（H1-H6），格式如下

```
# H1
## H2
### H3
#### H4
##### H5
###### H6
```

## 分割线

在单独的一行使用 *** 或者 --- 就能表示分割线了，记住一定要单独一行，不然就变成二级标题了。

## 删除线

使用 ~~包裹 表示删除线


## 链接

[链接描述](链接地址)

例如：[百度](https://www.baidu.com)

## 图片

![图片描述](图片地址)

例如：
![雪景](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/snow.jpeg)

## 视频

添加外部视频的话，要使用 iframe 代码，并且还需要对应的视频网站支持，问题的关键是我们如何知道对应的视频链接，下面介绍个不错的方法，通过在视频分享键附近寻找把视频分享给朋友的地址，然后就可以使用下面的模板代码插入了：


```
<iframe width="640" height="360" src="https://www.youtube.com/embed/HfElOZSEqn4" frameborder="0" allowfullscreen>
</iframe>
```

例如：

<iframe width="640" height="360" src="https://www.youtube.com/embed/HfElOZSEqn4" frameborder="0" allowfullscreen>
</iframe>



