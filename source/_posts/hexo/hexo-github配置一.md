---

title: hexo+github配置一

date: 2018-01-25 16:17:46

tags: hexo+github

categories: hexo配置

---


一直想弄个自己的blog，最好是免费的，直到今天才下定决心来搭建一个 hexo + github pages 的blog，一是方便记录自己平时的一些总结，二是可以同步，早期是直接写 md 文件，存放在 github 上面，查找与观看不方便，后来发觉 hexo 正好能把 md 转换成 html，简单太棒了！

## Hexo简介

Hexo 是一个快速、简洁且高效的博客框架。 Hexo 使用 Markdown 解析文章，解析速度很快，可以用很多漂亮的主题生成静态网页。

## Hexo 与 Jeky 对比

1、Jeky 生成速度慢，创建分页比较复杂；

2、Jeky 的主题不是怎么好看，个人更喜欢Hexo的；

3、Jeky 需要的依赖环境会多一点，需要 Ruby、Python；Hexo 只需要 Node.js

## 环境

1、Mac OS X

2、git

3、github 账号

4、Node.js

5、XCode 的 Command Line Tools （Mac下编译要用）

## 安装Hexo

1、安装 Node.js 可以使用 Homebrew 去安装很方便

2、安装 Git，对于 Mac OS X 自带就有

3、安装 Hexo
	
	$ npm install -g hexo-cli

> 在 OS X 上面安装后，运行 hexo 之后可能会提示这样的错误

> [SyntaxError: Unexpected token ILLEGAL]

> 安装时，可以使用 npm install hexo --no-optional 来解决

在 Hexo3 中， hexo-server 独立出来了，如要本地调试，还需要安装
	
	$ npm install hexo-server --save

其余独立出来的还包括下面这些,特别是 hexo-deployer-git 这个模块,不安装的话后面在运行 hexo deploy 时会提示找不到 git ，所以我们干脆一次全安装了：

```
npm install hexo-generator-index --save
npm install hexo-generator-archive --save
npm install hexo-generator-category --save
npm install hexo-generator-tag --save
npm install hexo-server --save
npm install hexo-deployer-git --save
npm install hexo-renderer-marked@0.2 --save
npm install hexo-renderer-stylus@0.2 --save
npm install hexo-generator-feed@1 --save
npm install hexo-generator-sitemap@1 --save

```

然后可以到 node_modules 目录下面看自己是不是已经安装了这些模块。

