---
title: CocoaPods 私有库搭建

date: 2018-10-12 16:07:58

tags: CocoaPods

categories: CocoaPods
---

参照官方文档 [CocoaPods 官方文档](https://guides.cocoapods.org/terminal/commands.html#pod_repo_push)

### 一、创建两个 git 仓库

我们创建两个 git 仓库，一个用来做私有 Spec Repo，一个是我们自己的公共组件：

第一个仓库名称是 Spec，专门用来做私有Spec Repo。

第二个仓库名称是 BGNetwork，这个就是我们公共组件库。

在这里，我们来说一下什么是Spec Repo?

	他是所有的 Pods 的一个索引，就是一个容器，所有公开的 Pods 都在这个里面，他实际是一个 Git 仓库 remote 端。
	在 GitHub 上，当你使用了 Cocoapods 后他会被 clone 到本地的 ~/.cocoapods/repos 目录下，
	可以进入到这个目录看到 master 文件夹就是这个官方的 Spec Repo 了。

### 二、添加私有Spec repo（索引库） 到 Cocoapods

主要命令是pod repo add REPO_NAME SOURCE_URL。其中，REPO_NAME 是私有 repo 的名字，取一个容易记住的名字，后面还会用到，以后公司内部的组件对应的 podspec 都可以推送到这个 repo 中；SOURCE_URL 就是刚刚我们创建的 Spec 仓库链接。

	$ pod repo add eric https://github.com/eric/Spec.git
	$ ls ~/.cocoapods/repos  
	  eric	master


这时，你会发现有两个文件夹 eric 和 master，master 是 Cocoapods 官方的 repo，而 eric 就是我刚刚创建的。
进入 eric 文件夹查看，你会发现它是 clone 了一份 https://github.com/eric/Spec.git。

在这里，我们是一个空的仓库，可以不检查，但是你的仓库如果有什么其他东西的话，可以检查一下。

	$ cd ~/.cocoapods/repos/eric
	$ pod repo lint .


### 三、制作自己的公共组件


#### 1、将我们前面创建的 BGNetwork 项目克隆到本地

	$ git clone https://github.com/eric/BGNetwork.git

#### 2、在本地我们使用了 xcode 创建了项目，并且写了一个网络框架，运行没有问题，我们准备提交到 github，并打上版本号。

	$ git add .
	$ git commit -m 'add file'
	$ git push origin master
	$ git tag -m 'add tag' '0.1.1'
	$ git push --tags

#### 3、我们开始制作 Podspec 文件。

BGNetwork 是一个基于 AFNetworking 而封装的网络框架，它主要的源文件都在 BGNetwork/BGNetwork 路径下。我们将它放在 CocoaPods 给第三方使用，主要是将这个文件夹下的源文件加载到第三方的项目中以供使用。
下面是供第三方使用的源文件结构，具体可以下载 BGNetwork 代码查看

	____BGNetwork
	| |____BGAFHTTPClient.h
	| |____BGAFHTTPClient.m
	| |____BGAFRequestSerializer.h
	| |____BGAFRequestSerializer.m
	| |____BGAFResponseSerializer.h
	| |____BGAFResponseSerializer.m
	| |____BGNetworkCache.h
	| |____BGNetworkCache.m
	| |____BGNetworkConfiguration.h
	| |____BGNetworkConfiguration.m
	| |____BGNetworkConnector.h
	| |____BGNetworkConnector.m
	| |____BGNetworkManager.h
	| |____BGNetworkManager.m
	| |____BGNetworkRequest.h
	| |____BGNetworkRequest.m
	| |____BGNetworkUtil.h
	| |____BGNetworkUtil.m
	
在 BGNetwork 项目的根目录下创建一个 BGNetwork.podspec 文件，对应上面的需求，我们的 podspec 可以这么写

	Pod::Spec.new do |spec|
	  #项目名称
	  spec.name         = 'BGNetwork'
	  #版本号
	  spec.version      = '0.1.1'
	  #开源协议
	  spec.license      = 'MIT'
	  #对开源项目的描述
	  spec.summary      = 'BGNetwork is a request util based on AFNetworking'
	  #开源项目的首页
	  spec.homepage     = 'https://github.com/eric/BGNetwork'
	  #作者信息
	  spec.author       = {'eric' => 'eric@126.com'}
	  #项目的源和版本号
	  spec.source       = { :git => 'https://github.com/eric/BGNetwork.git', :tag => '0.1.1' }
	  #源文件，这个就是供第三方使用的源文件
	  spec.source_files = "BGNetwork/*"
	  #适用于ios7及以上版本
	  spec.platform     = :ios, '7.0'
	  #使用的是ARC
	  spec.requires_arc = true
	  #依赖AFNetworking2.0
	  spec.dependency 'AFNetworking', '~> 2.0'
	end
	
**注意：spec.source 源是 BGNetwork 的 git 仓库，版本号是我们上一步打上的版本号 0.1.1。**


#### 4、验证并推送到服务器

在推送前，我们先验证Podspec(检查本地pod)，验证的时候是验证BGNetwork.podspec文件，所以我们需要保证进入的目录和 BGNetwork.podspec 同级的，
验证命令如下：

	$ pod lib lint BGNetwork.podspec --no-clean --allow-warnings --verbose
	或
	$ pod lib lint 

	# 注意可以在最后面 带上 --sources = ‘’
	$ pod lib lint BGNetwork.podspec --no-clean --allow-warnings --verbose --sources = 'xxxx,https://github.com/CocoaPods/Specs.git'
	
	# The sources from which to pull dependent pods(defaults to https://github.com/CocoaPods/Specs.git). Multiple sources must be comma-delimited.
	# 意思是 这个podspec里面依赖了另一个私有库，为了能找到依赖私有库的地址，需要带上私有库的spec(索引库地址),其中 'xxxx'就是其地址
	

**注意：验证的时候，会获取 BGNetwork.podspec 文件中的 spec.source 来获取 git 服务器上面对应版本的代码，
然后再找到 spec.source_files 中的源代码，通过 xcode 命令行工具建立工程并且进行编译。所以这一步的过程会比较久，如果编译没有错误，就验证通过。
建议加上 --fail-fast ，不然每次都是全部编译完成后才报错，当 podspec 很大的时候，会特别费时，加上此参数可以让其停止在错误的地方**


如果没有错误和警告我们就可以推送到服务器了，推送使用的命令如下：

	$ pod repo push REPO_NAME SPEC_NAME.podspec --allow-warnings --verbose
	
	# 注意可以在最后面 带上 --sources = ‘’
	$ pod repo push REPO_NAME SPEC_NAME.podspec --allow-warnings --verbose --sources = 'xxxx,https://github.com/CocoaPods/Specs.git'
	
	# The sources from which to pull dependent pods(defaults to https://github.com/CocoaPods/Specs.git). Multiple sources must be comma-delimited.
	# 意思是 这个podspec里面依赖了另一个私有库，为了能找到依赖私有库的地址，需要带上私有库的spec(索引库地址),其中 'xxxx'就是其地址

它也会先验证，然后再推送。我这里推送 BGNetwork 命令是：

	$ pod repo push eric BGNetwork.podspec


如果没有错误，但是有警告，我们就将警告解决，也可以加 --allow-warnings 来提交

	$ pod repo push eric BGNetwork.podspec --allow-warnings

如果有错误，我们可以去查看错误信息对应下的Note信息并解决。在这错误当中，常常会遇到找不到对应文件的错误，这个时候你需要查看
BGNetwork.podspec 文件中 spec.source 下 git 仓库链接是否没问题，git 仓库下对应的 tag 版本中 spec.source_files 路径下是否正确。

如果查看 Note 信息看不出什么问题，可以加上 verbose 参数进行更详细的查看。


	$ pod repo push eric BGNetwork.podspec --allow-warnings --verbose

**注意事项：碰到本地使用 pod lib lint 验证通过，但是 push 到服务器却失败了，这个时候很可能就是服务器 tag 版本不对，使用 --verbose 能查看详细的错误信息。**


#### 5、搜索我们的框架

到这一步，我们就可以通过 pod search BGNetwork 来搜索了，搜索到了说明我们私有源建立成功。

	$ pod search BGNetwork
	-> BGNetwork (0.1.2)
	   BGNetwork is a request util based on AFNetworking
	   pod 'BGNetwork', '~> 0.1.2'
	   Homepage: https://github.com/eric/BGNetwork
	   Source:   https://github.com/eric/BGNetwork.git
	   Versions: 0.1.1, 0.1.0 [eric repo] - 0.1.2, 0.1.1 [master repo]

由上面的搜索知道，BGNetwork 在 eric 这个私有 repo 中存在 0.1.1 和 0.1.0 版本，在 master 中存在 0.1.2 和 0.1.1 版本。
搜索成功之后，我们将 BGNetwork.podspec 也推送到远程服务器。


### 四、注意

#### 1、途中遇到了几次问题，就是pod repo push不上去，显示没有找到对应文件，后来发现是版本的问题，没有打上版本号或者Podspec中版本错了。

#### 2、若是在框架当中，存在不同的文件夹，请使用 subspec。如果不同文件夹之间的文件有相互导入的情况，请将被导入的头文件设置为 public_header_files，
#### 并且通过 dependency 设置依赖，具体可以参考 AFNetworking 的 podspec 文件。

#### 3、若是需要提交给官方，请使用

	$ pod trunk register youremail
	# 查看信息
	$ pod trunk me
	# 将对应的pod推送到服务器
	$ pod trunk push

#### 4、使用 pod install 时，它首先会更新整个官方的源，而 Cocoapods 每天都有很多人提交，所以更新比较慢。所以，建议每过一段时间更新一下官方库，平常的时候，咱们可以在 install 或 update 加一个参数 --no-repo-update 让它不用更新。

	$ pod install --verbose --no-repo-update
	$ pod update --verbose --no-repo-update


#### 5、多个模块

但如果我们需要拆分出几个子模块让开发者去选择, 这里有两种方案:

开启多一个Git仓库, 分开来存储
通过编写podspec文件的技巧拆分，（参照 AFNetworking)
