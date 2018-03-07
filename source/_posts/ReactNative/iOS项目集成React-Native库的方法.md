---

title: iOS项目集成React-Native库的方法

date: 2018-03-07 10:49:21

tags: RN

categories: React Native

---

# 方法一

私有 Pods 集成 react-native 库，将 react-native 移入私有源后，原生语言开发者就不需要在关心其环境了，可以直接在 Pod 里面 install 后使用，这样在 jenkins 上面配置的一健打包、上传、发布也无需关心出错了。

## 获取node_modules

### 安装 React 开发环境

创建私有库的开发者需要安装 React 开发环境

```
brew install node
brew install watchman
npm install -g react-native-cli
```

还需要其他更详细的安装可以看官方文档。

### 使用 npm package

我们使用 0.44.3 版本，我们需要一个 package.json 文件，里面内容如下：

```
{
	"name": "RNDemo",
	"version": "0.0.1",
	"private": true,
	"scripts": {
		"start": "node node_modules/react-native/local-cli/cli.js start",
		"test": "jest"
	},
	"dependencies": {
		"react": "16.0.0-alpha.6",
		"react-native": "0.44.3",
		"react-native-video": "^2.0.0",
		"start": "^5.1.0"
	},
	"devDependencies": {
		"babel-jest": "21.0.0",
		"babel-preset-react-native": "3.0.2",
		"jest": "21.0.1",
		"react-test-renderer": "16.0.0-alpha.6"
	}
}
```

然后执行

```
npm install
```

就会在同目录层级下生成 node_modules 文件夹，其他所有 RN 相关的东西都在里面，下面就要开始配置了！

### 获取 React.podspec.json

在 node_modules/react-native 找到 React.podspec 

```
注意：
1、`0.44.3`版本内`cocoapods_version = ">= 1.2.0"`, pod版本不够的需升级
2、`Core`依赖`Yoga`,需要做好支持
```

使用如下命令将其转 json 文件

```
pod ipc spec React.podspec >> React.podspec.json
```

在 React.podspec.json 文件中找到 source 中的 git 地址，改成自己的私有库地址

```
"source": {
	"git": "git@git.hostxx.com:group/react-native.git",
	"tag": "v0.44.3"
}
```

上传 React.podspec.json 到私有 repo 。

### Yoga

在 node_modules/react-native/ReactCommon/yoga 内找到 Yoga.podspec 也按上面方法转换。

修改 source

```
"source": {
	"git": "git@git.hostxx.com:group/react-native.git",
	"tag": "v0.44.3"
}
```

然后修改 source_file，路径添加 ReactCommon

```
"source_files": "ReactCommon/yoga/**/*.{c,h}"
```

上传 Yoga.podspec.json 到私有 repo 。

### 如何使用

原生开发者只需要在 podfiles 中如下添加

```
pod 'React', '0.44.3', :subspecs => [
    'Core',
    'DevSupport',
    'RCTText',
    'RCTNetwork',
    'RCTWebSocket',
    #...
]
```

**其他开发者执行 pod update 即可正常运行应用，无需再执行前面 React 环境安装**

### 嵌入到应用

```
#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"这个是RN页面";
    NSURL *jsURL = [NSURL URLWithString:@"http://127.0.0.1:8081/index.ios.bundle?platform=ios&dev=true"];
    RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsURL
                                                        moduleName:@"XXXXXXXX"
                                                 initialProperties:nil
                                                     launchOptions:nil];
    rootView.frame = self.view.frame;
    [self.view addSubview:rootView];
}
```

原生开发者只需配置好链接，无需再关注react开发者进度。


# 方法二

















