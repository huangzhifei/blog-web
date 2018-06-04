---

title: React Native之热更新(react-native-pushy)

date: 2018-05-30 17:42:44

tags: RN

categories: React Native

---

## 概述

当下选择使用 React Native 的项目大都是基于原有项目的基础上进行的接入，即所谓的混合开发，而目前外界主要热更新方案为微软的 CodePush，React Native 中文网的 pushy，今天的主角就是 pushy（微软的服务器在国外，会慢一点）

github地址：[react-native-pushy](https://github.com/reactnativecn/react-native-pushy)

## 安装

在我们的项目根目录下运行如下命令即可：

```
npm install -g react-native-update-cli

npm install --save react-native-update@具体版本请看下面的表格
```

因为 React Native 不同版本代码结构不同，因而请按下面表格对号入座：

|React Native版本	|react-native-update版本|
| ------------- | --------------------|
|0.26及以下	| 1.0.x |
|0.27 - 0.28	| 2.x |
|0.29 - 0.33	| 3.x |
|0.34 - 0.45	|4.x  |
|0.46及以上	| 5.x |

我使用的是当前 React Native 最新的版本 0.55.4，所以我们对应安装的是 5.x 

当我们安装完上面的两条命令后，我们就需要去设置 react-native-update 到我们原生项目中。

下面以 iOS 及 CocoaPods 为例子

### 手动和自动 link

#### 1、如果项目为纯RN项目，那执行下面命令就行

```
react-native link react-native-update
```

#### 2、如果是RN植入到 iOS 原生项目中，经测试用 link 无用，用 CocoaPods 自动链接

1、在 node_modules 目录下找到 react-native-update

手动创建 podspec 文件

```
touch react-native-update.podspec

```

2、在react-native-update.podspec 这个文件中添加内容

```
require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
s.name = "react-native-update"
s.version = package["version"]
s.summary = "hot update for react-native"
s.author = "author (https://github.com/reactnativecn)"

s.homepage = "https://github.com/reactnativecn/react-native-pushy"

s.license = "MIT"
s.platform = :ios, "7.0"

s.source = { :git => "https://github.com/reactnativecn/react-native-pushy.git", :tag => "#{s.version}" }

s.source_files = "ios/**/*.{h,m,c}"

s.libraries = "bz2"

s.dependency "React"
end

```

这样就创建好了 podspec 文件了，之后只需要按如下方式引入 pod 中使用

```
pod 'react-native-update' , :path => '../node_modules/react-native-update'
```

注意一下 node_modules 与 podfile 的路径位置

### 配置 Bundle URL (iOS)

1、工程 target -> Build Phases -> Link Binary with Libraries 中添加 libz.tbd、libbz2.1.0.tbd

2、AppDelegate.m 中添加如下代码：

```
#import <RCTHotUpdate.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if DEBUG
  // 原来的jsCodeLocation保留在这里
  jsCodeLocation = ..........
#else
  // 非DEBUG情况下启用热更新
  jsCodeLocation=[RCTHotUpdate bundleURL];
#endif
  // ... 其它代码
}

```

### iOS 设置 ATS 

从 iOS9 开始，苹果要求以白名单的形式在 Info.plist 中列出外部的非 https 接口，以督促开发者部署 https 协议。在我们的服务部署 https 协议之前，请在 Info.plist 中添加如下例外（右键点击 Info.plist，选择 open as - source code）

```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>reactnative.cn</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
   </dict>
</dict>
```

到现在为止，基本上就可以尝试编译一下，是否有错误

## 登录与创建应用

首先请在 http://update.reactnative.cn 注册帐号，然后在你的项目根目录下运行以下命令：

```
$ pushy login
email: <输入你的注册邮箱>
password: <输入你的密码>
```

执行完上面的过程，会在项目根目录下生成一个 .update 文件，直接在 .gitignore 末尾增加一行 .update 来忽略这个文件。

登录之后可以创建应用（在网站上创建也行），注意 iOS 和 Android需要单独创建（名字可以一样）

```
$ pushy createApp --platform ios
App Name: <输入应用名字>
$ pushy createApp --platform android
App Name: <输入应用名字>
```

如果你已经在网页端创建过应用，也可以直接选择应用：

```
$ pushy selectApp --platform ios

```

选择或者创建过应用后，你将可以在文件夹下看到update.json文件，其内容类似如下形式：

```
{
    "ios": {
        "appId": 1,
        "appKey": "<一串随机字符串>"
    },
    "android": {
        "appId": 2,
        "appKey": "<一串随机字符串>"
    }
}
```
你可以安全的把update.json上传到Git等CVS系统上，与你的团队共享这个文件，它不包含任何敏感信息。当然，他们在使用任何功能之前，都必须首先输入pushy login进行登录。

## 添加热更新代码

这是官方详细的讲解热更新代码的功能[添加热更新功能](https://github.com/reactnativecn/react-native-pushy/blob/master/docs/guide2.md)

下面我只是给出一个封装到单独到处 js 文件中，方便统一使用

```

import React, {Component} from 'react';

import {
    Linking,
    Platform,
    Alert,
} from 'react-native';

import {
    isFirstTime,
    isRolledBack,
    packageVersion,
    currentVersion,
    checkUpdate,
    downloadUpdate,
    switchVersion,
    switchVersionLater,
    markSuccess
} from 'react-native-update';

import _updateConfig from './update.json';
const {appKey} = _updateConfig[Platform.OS];

export default class HotUpdate extends Component {
    constructor (props) {
        super (props);
        if (isFirstTime) {
            console.log('上次更新成功');
            //Alert.alert('上次更新成功');
            markSuccess(); // 需要标记，不然下次启动就会回滚
        } else if (isRolledBack) {
            console.log('刚刚更新失败了,版本被回滚');
            //Alert.alert('提示', '刚刚更新失败了,版本被回滚.');
        }
    }

    doUpdate(info) {
        downloadUpdate(info).then((hash) => {
            console.log('downloadUpdate: ' + hash);
            //Alert.alert('下载完毕');
            // switchVersion(hash); // 立即切换版本(此时应用会立即重新加载)
            switchVersionLater(hash); // 下一次启动的时候再加载新的版本
        }).catch((err) => {
            console.log('更新失败!');
            //Alert.alert('提示', '更新失败!');
        })
    }

    doCheck () {
        checkUpdate(appKey).then((info) => {
            if (info.expired) {
                console.log('您的应用版本已更新,请前往应用商店下载新的版本');
                //Alert.alert('您的应用版本已更新,请前往应用商店下载新的版本');
            } else if (info.upToDate) {
                console.log('您的应用版本已是最新');
                //Alert.alert('您的应用版本已是最新');
            } else if (info.update) {
                // Alert.alert('提示', '检查到新的版本 ' + info.name+', 是否下载?\n'+ info.description, [
                //     {text: '是', onPress: () => {this.doUpdate(info)}},
                //     {text: '否'},
                // ]);

                // 直接调用，后台静默下载
                this.doUpdate(info);
            } else {
                console.log(info);
            }
        }).catch((err) => {
            console.log('检查更新失败!');
            //Alert.alert('提示', '检查更新失败.');
        });
    }
}
```

外部只要在入口调用一次就可以了

```
constructor (props) {
     super (props);
     this.hotUpdate = new HotUpdate();
}

componentWillMount () {
     // check hot update
     this.hotUpdate.doCheck();
}
```

## 打离线包及IPA包

当前面几步完成后（基本不会报错，后面就会有点坑~）,我们就需要打 bundle 离线包及 IPA 包来测试验证一下热更新功能好不好用。

1、bundle 离线包看之前文章或网上就行

2、打包导出ipa文件

3、注意: update.json 文件需要跟js文件在一个目录下，否则容易出现找不到文件报错

## 发布到热更新服务器

### 我们需要把之前打出来的 ipa 上传到服务器

```
$ pushy uploadIpa <your-package.ipa>

```

当我使用目前最新的 node 版本（10.x.x）时会报错

```
TypeError [ERR_INVALID_CALLBACK]: Callback must be a function
    at maybeCallback (fs.js:124:9)
    at Object.fs.write (fs.js:642:14)
    at /Users/www/admin/build/webpack.dev.config.js:12:8
    at FSReqWrap.oncomplete (fs.js:136:20)
```
类似于这样的错误，这是因为 node 版本太高了，我们需要降级，亲测降到 v8.11.1 可行，不过我发现此 bug 在前两天已经被 react-native-update 的维护者修复了，如果依然碰到这个问题，可以试试此方法。

### 发布新的 bundle 代码

我们更关心的是更改了 react native 的代码后，怎么使用热更新，我们使用下面的命令（在使用下面命令前我们并不需要自己打出离线包）

```
$ pushy bundle --platform <ios|android>
Bundling with React Native version:  0.55.4
<各种进度输出>
Bundled saved to: build/output/ios.1459850548545.ipa
Would you like to publish it?(Y/N)
```

如果想要立即发布，此时输入Y。当然，你也可以在将来使用pushy publish --platform <ios|android> <ppkFile>来发布版本。

然后按钮提示一步一步操作就可以了

这里又碰到一个坑爹的问题:

```
Bundling with React Native version: 0.55.4
Error: Cannot find module 'metro-bundler/src/babelRegisterOnly'
at Function.Module._resolveFilename (module.js:543:15)
at Function.Module._load (module.js:470:25)
at Module.require (module.js:593:17)
at require (internal/module.js:11:18)
at Object. (/Users/hulinhu/Desktop/react-naive/MyApp/node_modules/react-native-update/local-cli/lib/bundle.js:439:9)
at Generator.next ()
at step (/Users/hulinhu/Desktop/react-naive/MyApp/node_modules/react-native-update/local-cli/lib/bundle.js:310:191)
at /Users/hulinhu/Desktop/react-naive/MyApp/node_modules/react-native-update/local-cli/lib/bundle.js:310:361
at
```

原因是：在最新版本0.55.4中已经不存在metro-bundle这个module了，改成 metro 了，所以一定要注意，自己去node_modules下面找找这个模块。

所以我们按照下面的方式更改就行了

```
把\node_modules\react-native-update\local-cli\lib\bundle.js中439行的'metro-bundler/src/babelRegisterOnly'改为'require('metro/src/babelRegisterOnly');'
```

这个 bug 也被作者修复了。（当我写这篇文章时去看，发现已经修复了，为佬不早修复了）

当我们发布成功我们修复的 bundle 文件后，至此我们的热更新服务已经接入完毕，大家就可以自己去测试一下热更新了。


## 总结

上面碰到的问题，我通过查看 issues 基本上都找到解决原因，所以我们还是要多看看 github 上面的 issures 内容。

