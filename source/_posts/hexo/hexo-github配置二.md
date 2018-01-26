---

title: hexo-github配置二

date: 2018-01-26 16:17:46

tags: hexo+github

categories: hexo配置

---

## hexo 下的 _config.yml 配置

下面会贴出根目录下的 _config.yml 的内容，直接看里面的注释不会懂的。

```
# Hexo 配置
## Docs: https://hexo.io/docs/configuration.html
## Source: https://github.com/hexojs/hexo/

# Site
title: EricHuang's blog					# 网站的标题
subtitle:									# 网站的副标题
description: ~ 生活不止苟且，还有诗和远方，迎着朝阳前进，看风与雪。  # 网站的描述
author: Eric Huang						# 你的昵称
language: zh-Hans						# 网站使用的语言(英文：en，简体中文：zh-Hans）
timezone:									# 网站时区，用于生成页面填充相关时间，默认为电脑时区

# URL
## 如果你的站点要放入子目录, 请将url设置为'http://yoursite.com/child' 并将根目录设置为'/child/'
url: https://huangzhifei.github.io	# 站点网址
root: /									# 站点根目录
permalink: :year/:month/:day/:title/		# 文单的永久链接格式
permalink_defaults:							# 永久链接中各部分的默认值

# Directory		# 目录
source_dir: source			# 资源文件夹，这个文件夹用来存放博客内容
public_dir: public			# 公共文件夹，这个文件夹用来存放生成的站点静态文件
tag_dir: tags					# 标签文件夹
archive_dir: archives		# 归档文件夹
category_dir: categories	# 分类文件夹
code_dir: downloads/code	
i18n_dir: :lang
skip_render:					# 跳过指定文件的渲染

# Writing		# 写作
new_post_name: :title.md 	# 新文章的名称
default_layout: post		# 预设布局
titlecase: false # Transform title into titlecase
external_link: true 		# 在新标签中打开链接
filename_case: 0				# 把文件名称转换为 1：小写 2：大写
render_drafts: false
post_asset_folder: false
relative_link: false
future: true
highlight:					# 代码块的设置
  enable: true
  line_number: true
  auto_detect: false
  tab_replace:
  
# Home page setting
# path: Root path for your blogs index page. (default = '')
# per_page: Posts displayed per page. (0 = disable pagination)
# order_by: Posts order. (Order by date descending by default)
index_generator:
  path: ''
  per_page: 10			
  order_by: -date		# 按时间排序
  
# Category & Tag
default_category: uncategorized
category_map:
tag_map:

# Date / Time format
## Hexo uses Moment.js to parse and display date
## You can customize the date format as defined in
## http://momentjs.com/docs/#/displaying/format/
date_format: YYYY-MM-DD
time_format: HH:mm:ss

# 分页
## Set per_page to 0 to disable pagination
per_page: 10				# 每页显示的文章数，0 表示关闭分页功能
pagination_dir: page

# 扩展
## Plugins: https://hexo.io/plugins/
## Themes: https://hexo.io/themes/
theme: hexo-theme-next	# 主题，使用对应的主题名字就行了

# 部署
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repo: https://github.com/huangzhifei/huangzhifei.github.io.git
  branch: master
  
# RSS订阅支持
plugin: 
- hexo-generator-feed

# Feed Atom
feed:
type: atom
path: atom.xml
limit: 20

```

其实对于站点的配置，需要我们更改的并不多，我们只需要对网站标题、描述、语言及作者昵称做出更改，其他的使用默认的就行了。



## hexo 的主题

hexo 之所以如此受欢迎，很大的一个原因是他有很多主题够大家去选择，下面是 hexo 官网提供的主题列表

[hexo 主题](https://github.com/hexojs/hexo/wiki/Themes)

找到自己喜欢的主题后，直接 clone 下来，比如我目前选择就是公认最舒服的主题 NextT，如下：

```
$ cd themes
$ git clone https://github.com/iissnan/hexo-theme-next
```

注意：由于我们已经对我们的整个站点做了 git 管理，上面命令 clone 下来的主题会自带一个 git 管理，这两是不一样的，所以我们要删掉主题下面的 .git 文件，这样我们就上传到我们自己的仓库去了，不然是不行，这会导致在其他没有这个主题的终端我们部署后，会失败，因为找不到对应的主题。

### 主题设定

#### 选择 scheme
借助 scheme，NextT 提供了多种不同的外观，目前主要支持以下几种：

* Muse		默认 scheme，黑白主调，大量留白
* Mist		紧凑版本，整洁有序的单栏外观
* Pisces	双栏，小家碧玉的清新
* Gemini	和 Pisces 相似

开启对应的主题，注视掉其他的就好了。


### 设置菜单

找到 menu 字段，菜单内容的设置格式是：item name: link，其中 itme name 是一个名称，他并不会直接显示在页面上，他是用来匹配图标及翻译的。

```
menu:
  home: / || home
  about: /about/ || user
  tags: /tags/ || tags
  categories: /categories/ || th
  archives: /archives/ || archive
  #schedule: /schedule/ || calendar
  #sitemap: /sitemap.xml || sitemap
  #commonweal: /404/ || heartbeat
```

喜欢哪个开启哪个就行了，开启后生成对应的配置，下面会讲解常用的几个。

有了对应菜单还需要对应的图标，格式是 item name: icon name 注意后面是图标的名字。

```
menu_icons:
  enable: true	# 用来控制是否显示图标
  home: home
  about: user
  categories: th
  tags: tags
  archives: archive
  #commonweal: heartbeat
```

### 首页文章自动收起

默认首页的文章全展示出来的，很不方便，通过下面设置来更改：

```
# Automatically Excerpt. Not recommend.
# Please use <!-- more --> in the post to control excerpt accurately.
auto_excerpt:
  enable: true	# true 表示自动收起
  length: 150		# 收起后默认展示的最长内容
```

### 头像设置

找到 avatar 字段，后面贴上完整的图片url地址就好了。

```
avatar: https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/avatar-photo.png
```

我直接用的 github 的图床，其他的懒得弄了。


### 添加 “标签” 页面

新建页面

```
$ hexo n page tags
```

会在 source 文件夹下面生成一个 tags 文件夹，其他文章在使用的时候在头部带上 tags：tags名字，就会自己解析后对应的 tags 了。

### 添加 “分类” 页面

新建页面

```
$ hexo n page categories
```

会在 source 文件夹下面生成一个 categories 文件夹，其他文章在使用的时候在头部带上 categories：categories 名字，就会自己解析后对应的 categories 了。

### 添加 “关于” 页面

新建页面

```
$ hexo n page about
```

会在 source 文件夹下面生成一个 about 文件夹，我们编辑里面的 md 文件，填写个人介绍就好了。


### 添加 404 页面

我们做点公益，使用 腾讯的公益 404 页面，寻找丢失儿童，新建 404.html 页面，放到 source 目录下，内容如下：

```
<!DOCTYPE HTML>
<html>
<head>
  <meta http-equiv="content-type" content="text/html;charset=utf-8;"/>
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
  <meta name="robots" content="all" />
  <meta name="robots" content="index,follow"/>
</head>
<body>

<script type="text/javascript" src="http://www.qq.com/404/search_children.js"
        charset="utf-8" homePageUrl="https://huangzhifei.github.io"
        homePageName="回到我的主页">
</script>

</body>
</html>
```

注意把里面 homePageUrl 替换成你的主页的 Url

### 侧边栏社交链接

```
social:
  GitHub: https://github.com/huangzhifei || github
  Weibo: https://weibo.com/chongzizizizizizi/home?leftnav=1 || weibo
  #E-Mail: mailto:yourname@gmail.com || envelope
  #Google: https://plus.google.com/yourname || google
  #Twitter: https://twitter.com/yourname || twitter
  #FB Page: https://www.facebook.com/yourname || facebook
  #VK Group: https://vk.com/yourname || vk
  #StackOverflow: https://stackoverflow.com/yourname || stack-overflow
  #YouTube: https://youtube.com/yourname || youtube
  #Instagram: https://instagram.com/yourname || instagram
  #Skype: skype:yourname?call|chat || skype

social_icons:
  enable: true
  Github: github
  Weibo: weibo
  icons_only: false
  transition: false
```

上面的是链接，下面的是对应的图标。

### 文章时间分类

我们通过在头部添加 date 来让其文章分到对应的年份目录中。

### 完整的头部内容

```
---
title: 流行库源码解读				# 文章的标题

date: 2017-04-10 11:37:42		# 文章的时间

tags: 源码							# 文章被打上的 tag

categories: iOS源码分析			# 文章的分类

---
```

目录我主要使用到的就这些。


