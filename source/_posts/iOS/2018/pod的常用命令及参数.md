---

title: pod的常用命令及参数

date: 2018-10-17 13:47:30

tags: CocoaPods

categories: CocoaPods

---

参照官方文档 [CocoaPods 官方文档](https://guides.cocoapods.org/terminal/commands.html)

### 添加仓库

	pod repo add DSSPecs https://github.com/walkdianzi/DSSpecs.git

### 删除仓库
	
	pod repo remove DSSPecs

### 更新仓库

	pod repo update DSSpecs

### 查看当前安装的pod仓库
	
	pod repo
	
### 提交.podspec
	
	pod repo push DSSpecs xxxx.podspec
	
### 验证.podspec文件
	
	pod lib lint name.podspec
	
	pod spec lint name.podspec

pod spec相对于pod lib会更为精确，pod lib相当于只验证一个本地仓库，pod spec会同时验证本地仓库和远程仓库。

### --sources

当你的.podspec文件依赖其他私有库时要引入source
	
	pod lib lint name.podspec --sources='https://github.com/walkdianzi/DSSpecs'
	
或者直接用仓库名,就是~/.cocoapods/repos/文件夹下对应仓库的名字
	
	pod lib lint name.podspec --sources=DSSPecs,master
	
### --no-repo-update
	
有时候当你使用pod update时会发现特别慢，那是因为pod会默认先更新一次podspec索引。使用--no-repo-update参数可以禁止其做索引更新操作。

	pod update --no-repo-update
	
和git一样，本地有个pod repo，和github上的版本对应，如果你不想更新这个的话后面加上--no-repo-update就可以了，但是这样会有个问题，如果github上pods的一些插件像AF有新版本了，你本地搜索的af还是旧版本如果用的新版本号是无法装配的，所以每隔一段时间我都会执行一下pod repo update。

### --verbose

打印详细信息

### --only-errors和--allow-warnings

--allow-warnings是允许warning的存在，也就是说当你在pod lib lint验证podspec的时候，如果不加这句，而你的代码里又一些警告的话，是验证不通过的。而加上这句话的话，有警告也能验证通过。

--only-errors这句话是只显示出错误，就是你在验证的时候就算--allow-warnings，但是那些warnings也还是会打印出来和errors混杂在一起，这会让你很难找error。所以这里使用--only-errors来只打印error，不打印warning。

### --fail-fast

出现第一个错误的时候就停止

这个参数非常好用，默认出现出错后，他是不会停下来的，如果是 podspec 里面模块很多，会花费大量的时间。

### --use-libraries

pod在提交或验证的时候如果用到的第三方中需要使用.a静态库文件的话，则会用到这个参数。如果不使用--use-libraries则会验证不通过。

但是比如你用swift创建了一个pod的话，你使用--use-libraries就会报错，因为swift开始，生成的就不是.a静态库了，它是不支持编译为静态库的，只能生成.Framework动态库。

