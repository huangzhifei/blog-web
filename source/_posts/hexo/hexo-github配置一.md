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

## Hexo 部署

执行如下命令创建所需要的文件

```
$ hexo init folder
$ cd folder
$ npm install
```

这样就新建完成了，完成后的目录如下

	.
	├── _config.yml     // 全局配置文件，可以在里面设置一些基本信息，一看就明白
	├── package.json		// 应用程序的信息，基本上可以不用管
	├── scaffolds			// 新建md文件时的模版，使用默认的就行，基本上也不用管
	├── source	
	|   ├── _drafts
	|   └── _posts		// 我们的md源文件
	└── themes			// 主题，自带一个主题
	
## Hexo 常用命令

### 1、新建 md 文件

	$ hexo new [layout] title (或者 hexo n title)
	
新建一篇文章，如果没有设置 layout 的话，就会使用默认的，注意如果文件名中含有空格，请用引号括起来。

### 2、生成静态文件

	$ hexo generate (或者 hexo g)

### 3、本地调试查看

生成完静态文件后，我们可以本地先查看一下样式是否正确

	$ hexo server (或 hexo s)

启动本地服务器，默认情况下访问网址：http://localhost:4000/

### 4、部署到远端
	
	$ hexo deploy (或 hexo d)

部署之前记得先生成静态文件。

### 5、清除缓存

	$ hexo clean

清除缓存文件 (db.json) 和已生成的静态文件 (public)。

在某些情况（尤其是更换主题后），如果发现您对站点的更改无论如何也不生效，您可能需要运行该命令。

**ps：远端的网站很多时候可能不会立即生效，可以等等或多刷新刷新。**

### 6、显示 hexo 版本

	 $ hexo version (或 hexo v)
	 
显示当前安装及使用的 hexo 的版本。


## hexo 与 github pages 的配置

### 1、github 账号及配置

在 github 上创建一个仓库，仓库名字必须为 youraccount.github.io 比如 huangzhifei.github.io

### 2、_config.yml 文件的配置

在 _config.yml 文件中翻到最下面，修改如下：

	# Deployment
	## Docs: https://hexo.io/docs/deployment.html
	deploy:
  		type: git
  		repo: https://github.com/huangzhifei/huangzhifei.github.io.git
  		branch: master
  
注意冒号与后面内容有空格，branch 只能填 master 分支

这要就和 github pages 关联上了，然后执行以下命令去看看是否正确关联成功：

	$ hexo clean
	$ hexo g
	$ hexo d

至此，个人博客就搭建成功了，访问网址为 youraccount.github.io 如：huangzhifei.github.io

注意：访问出现404，可能会有延迟，所以可以先等等。


## hexo 与 github pages 的多端同步与管理

仔细看 hexo 生成的目录，里面会有一个隐藏文件夹 .deloy_git ，看名字就知道这是生成静态文件后，会上传到远端去部署的内容，我们发现并没有源文件（md文件，也就是source/_posts/*）这样我们在其他地方想更改源文件去重新生成新的内容就很蛋疼了。

所以我们最好在 github 上面在创建另一个仓库，然后和这个本地的关联起来，把所有的源文件上传到 github就好了，在其他地方 clone 下来使用，不过还是要配置相应的 hexo 环境。



