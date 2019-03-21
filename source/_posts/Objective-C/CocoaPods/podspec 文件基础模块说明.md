---
title: podspec 文件基础模块说明

date: 2018-10-20 14:28:48

tags: CocoaPods

categories: CocoaPods
---

参照官方文档:[http://guides.cocoapods.org/syntax/podspec.html]()

文件内容可以根据模板和注释来修改和填写，对其中一些内容进行记录说明

#### s.source_files

指明哪些源文件会被包含进去，比如s.source_files = "KMPinHeaderLayout/Classes/\*\*/\*.{h,m}"，多条之间用逗号,分隔，用\*\*表示匹配所有子目录，用\*表示匹配所有文件，.{h,m}表示匹配其中的.h和.m文件。其中的路径是以.podspec所在目录为根目录。

#### s.exclude_files

规则同上，指定不被包含的文件、目录。

#### s.license

一般写法有s.license = 'MIT' 或 s.license = { :type => 'MIT', :file => 'LICENSE' }， LICENSE对应.podspec所在目录下的名为LICENSE文件

#### s.platform

指定可用平台和版本，s.platform = :ios, "7.0"，s.ios.deployment_target = '7.0'。如果支持多个平台应该使用后者，并指定其他平台的版本如s.osx.deployment_target = "10.7"。

#### s.public_header_files

公开的头文件，如果指定，在pod lint验证时，会以framework的形式验证，一般可以不用这个配置

#### s.framework(s)、s.libraries

指定依赖的系统库。两者内容都需要去除后缀，其中s.libraries需要去除前缀lib，如静态库依赖是libz.tbd，则s.libraries = 'z'。

#### s.vendored_libraries 、s.vendored_frameworks

如果开源库中是一个静态库，使用这个指定静态库。如微博的podspec中s.vendored_libraries = 'libWeiboSDK/libWeiboSDK.a'

#### s.xcconfig

指定项目配置，如HEADER_SEARCH_PATHS 、OTHER_LDFLAGS等，e.g s.xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }


#### s.resource

指定包含的资源文件 bundle

	spec.resource = 'Resources/HockeySDK.bundle'
	
可以参照 MJRefresh.podspec

#### s.resources

指定包含的资源文件 (图片、音视频、storyboard,xib,png,plist,xcassets,lproj等）
	
	spec.resources = ['Images/*.png', 'Sounds/*']
	
	或
	
	spec.resources = 'test/**/*.{storyboard,xib,png,plist,xcassets,lproj}'

这些资源文件在 build 时会被直接拷贝到 client target 的 mainBundle 里,这样就实现了把图片、音频、NIB等资源打包进最终应用程序
的目的。但是，这就带来了一个问题，那就是 client target 的资源和各种 pod 所带来的资源都在同一 bundle 的同一层目录下，很容易产生命名冲突。例如，我的 app 里有张按钮图片叫 “button.png"，而你的 pod 里也有张图片叫 "button.png"，拷贝资源时，我很担心 pod 里的文件会不会把我 app 里的同名文件给覆盖掉。


#### s.dependency

指定依赖，如s.dependency = 'AFNetworking'

#### s.source

指定源，s.source = { :git => 'https://github.com/sleepEarlier/PinHeaderLayout.git', :tag => s.version.to_s }


#### 使用三方 .a 或 .framework 的样例

拿微信当作例子

1、先从微信开放平台下载微信sdk

2、在NCKFoundation/NCKFoundation/Classes 目录下创建ThirdParty文件夹，并将.a和.h文件拖到ThirdParty文件夹下。（注意不要拖到工程目录下，而是文件目录）在podspec文件里修改source_file 为

	spec.source_files = 'NCKFoundation/Classes/*.{h,m}', 'NCKFoundation/Classes/ThirdParty/*.{h}'
	
3、添加.a静态库的依赖,.a依赖的系统framework以及library

	spec.vendored_libraries  = 'NCKFoundation/Classes/ThirdParty/*.{a}'
	spec.frameworks = 	'SystemConfiguration','CoreGraphics','CoreTelephony','Security','CoreLocation','JavaScriptCore'
	spec.libraries  = 'iconv','sqlite3','stdc++','z'

4、参数说明

	vendored_libraries: 第三方.a文件

	frameworks: 该pod依赖的系统framework

	libraries: 该pod依赖的系统library
	
