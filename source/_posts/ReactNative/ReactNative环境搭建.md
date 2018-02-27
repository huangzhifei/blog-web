---

title: ReactNative环境搭建

date: 2017-11-19 14:54:41

tags: RN

categories: React Native

---


我们使用的环境为 Mac OSX，主要针对 OSX 系统来搭建！

## 安装

### 1、Homebrew

Homebrew 为 Mac 系统下的包管理器，安装软件非常方便。

[Homebrew](https://brew.sh) 安装命令如下：

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

如果碰到 /usr/local 目录不可写的权限问题，可以使用下面的命令修复：

```
sudo chown -R `whoami` /usr/local
```

### 2、Node

React Native 目前需要 Node.js. 5.0及更高的版本，不过目前 homebrew 默认安装的版本都满足要求

```
brew install node
```

安装完 node 后建议设置 npm 的镜像以加速后面的过程。

```
npm config set registry https://registry.npm.taobao.org --global
npm config set disturl https://npm.taobao.org/dist --global
```

### 3、Yarn、React Native的命令行工具（react-native-cli）

[Yarn](https://yarnpkg.com/zh-Hans/) 是 Facebook 提供替代 npm 的工具，据说可以加速 node 模块的下载。

react-native-cli 用于执行、创建、更新项目、运行打包服务等任务

```
npm install -g yarn react-native-cli
```

安装完yarn后同理也要设置镜像源：

```
yarn config set registry https://registry.npm.taobao.org --global
yarn config set disturl https://npm.taobao.org/dist --global
```

### Xcode

React Native 目前需要 Xcode 8.0 或更高版本，这个自行安装就行。

其实主要是需要 Xcode 的命令行工具 Command Line Tools。


## 推荐安装 

### 1、Watchman

watchman 是由 facebook 提供的监视文件系统变更的工具，安装此工具可以提高开发时的性能（packager 可以快速扑捉文件的变化从而实现实时刷新）

```
brew install watchman
```

## 创建工程

由于 RN 0.45 之后要安装第三方库 boostrap，所以我们先使用 0.44.3 来编写用例吧

### 1、创建纯 RN 工程

```
react-native init MyApp --version 0.44.3
```

注意后面的版本号必须精确到两个小数点。

```
cd MyApp
react-native run-ios
```
这样就直接启动程序了

### 2、oc 工程内嵌 RN

1、正常创建 oc 工程，在 .xcworkspace 同级下创建文件夹，假设我们叫 RNComponent ，然后进入 RNComponent，我们先拷贝一个 package.json 文件进来（可以在其他目录创建一个纯RN工程后，拷贝其package.json文件），然后执行

```
npm install
```

在手动创建一个 index.ios.js 文件，作为 RN 的入口。

2、创建一个 podfile 文件，里面以 subspec 的形式填写你所需要集成的 React Native 的组件，如下：

```
platform :ios, '8.0'

target 'RNNative' do

#for react native
#如果你的RN版本 >= 0.42.0，请加入下面这行
	pod 'Yoga',  :path => './RNComponent/node_modules/react-native/ReactCommon/yoga'
    pod 'React', :path => './RNComponent/node_modules/react-native/', :subspecs => [
 	'Core',
  	'ART',
  	'RCTActionSheet',
  	'RCTAdSupport',
  	'RCTGeolocation',
  	'RCTImage',
  	'RCTNetwork',
  	'RCTPushNotification',
  	'RCTSettings',
  	'RCTText',
  	'RCTVibration',
  	'RCTWebSocket',
  	'RCTLinkingIOS',
    'DevSupport']
end
```

### 3、启动服务

执行以下命令来启动 RN 本地的服务

```
react-native start
```

这样原生 iOS 程序就可以调用 js 文件了。

注意：当 RN 的本地服务运行起来后，我们通过 XCode 来运行程序时可能会提示无法链接到 RN 的服务，这是因为我们本地服务是以 http 的方式启动的，由于 ATS 的限制让我们必须使用 https ，所以我们需要在 info.plist 里面增加 http 的允许或者我们增加 Exception Domains 。

```
<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSExceptionDomains</key>
		<dict>
			<key>localhost</key>
			<dict>
				<key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
				<true/>
			</dict>
		</dict>
	</dict>
```
如下图:


### 4、原生添加 RN 入口绑定

我们可以app启动时候去添加如下代码来绑定

```
    NSURL *jsCodeLocation;
    
#ifdef DEBUG
    //开发的时候用，需要打开本地服务器
    //真面调试的话，要让手机和电脑处于同一个路由下面，并且使用电脑端的ip地址
    //    jsCodeLocation = [NSURL URLWithString:@"http://10.1.17.92:8081/index.ios.bundle?platform=ios&dev=true"];
    //localhost是使用模拟器调试的
    jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];
#else
    //发布APP的时候用
    jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"index.ios" withExtension:@"jsbundle"];
#endif

    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                        moduleName:@"RNStyleTest"
                                                 initialProperties:nil //将native数据传送到RN中
                                                     launchOptions:nil];

    rootView.frame = CGRectInset([UIScreen mainScreen].bounds, 32, 70);
    self.view.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:rootView];
    self.view = rootView;
```

剩下的就是去修改 index.ios.js 文件及对应要加载的 js 文件了。

贴上一个 index.ios.js 里面的代码供参考：

```

import React, {Component} from 'react';
import {
    AppRegistry
} from 'react-native';

import styleTest from './styleTest';
import flexTest from './flexBoxTest';
import positionTest from './positionTest';
import layoutTest from './layoutTest';
import videoTest from './video/index';
import photoTest from './photoTest';

AppRegistry.registerComponent('RNStyleTest', () => styleTest);
AppRegistry.registerComponent('RNFlexTest', () => flexTest);
AppRegistry.registerComponent('RNPositionTest', () => positionTest);
AppRegistry.registerComponent('RNLayoutTest', () => layoutTest);
AppRegistry.registerComponent('RNVideoTest', () => videoTest);
AppRegistry.registerComponent('RNPhotoTest', () => photoTest);
```

这里我们注册了 6 个组件。

## IDE

推荐：

webstorm

atom

sublime text

visual studio code

喜欢用哪个就用哪个，我反正都安装了，最后用了 visual studio code（VSCode）也没有用明白~

## RN 技术依赖

个人总结：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RNTechDepend.png)

