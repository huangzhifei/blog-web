---

title: React Native之打离线包

date: 2018-03-07 11:20:11

tags: RN

categories: React Native

---

## 打包命令

离线包就是把 ReactNative 和你写的 js 文件、图片等资源都打包放入 App ，不需要走网络下载。

使用 react-native bundle --help 来查看打包的具体参数，下面就不列出来了，只挑一些重要的讲解一下：
我们以 iOS 为例子

```

--entry-file , ios 或者 android 入口的 js 名称，比如 index.ios.js

--platform , 平台名称( ios 或者 android )

--dev , 设置为 false 的时候将会对 JavaScript 代码进行优化处理

--bundle-output , 生成的 jsbundle 文件的名称，比如 ./ios/bundle/index.ios.jsbundle

--assets-dest , 图片以及其他资源存放的目录,比如 ./ios/bundle


```

打包命令如下：

```

react-native bundle --entry-file index.ios.js --platform ios --dev false --bundle-output ./ios/bundle/index.ios.jsbundle --assets-dest ./ios/bundle

```

为了方便使用，也可以把打包命令写到 npm script 中:

package.json 文件里面

```
"scripts": {
		"start": "node node_modules/react-native/local-cli/cli.js start",
		"test": "jest",
		"bundle-ios": "node node_modules/react-native/local-cli/cli.js bundle --entry-file index.ios.js  --platform ios --dev false --bundle-output ./ios/bundle/index.ios.jsbundle --assets-dest ./ios/bundle"
	},
```

这样以后只要运行如下命令就可以了

```
npm run bundle-ios
```

打包成功后会在相应的目录下看到离线包!

## 添加资源

离线包生成完成之后，可以在相应的目录下看到一个 **bundle** 目录，这个目录就是生成的整个离线资源，我们需要在 Xcode 中添加此资源，直接拖进来，但是记住要选择 Create folder references 的方式添加文件夹。

如何检验是否添加的方式正确，看他是不是蓝色的文件夹。

在 iOS 中就可以设置加载 JS 的代码了，记住这个时候 jsCodeLocation 就不用以 localhost 那种方式加载了，使用下面的方式

```
jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"bundle/index.ios" withExtension:@"jsbundle"];
```

离线包里的 .jsbundle 文件是经过优化处理的，因此运行效率也会比 Debug 的时候更高一些.

模拟器或真机运行，一切正常就ok了，因为不需要我们在提前开启一个服务。


## 遇到问题

1、离线包如果开启了chrome调试，会访问调试服务器，而且会一直loading出不来。

2、如果bundle的名字是main.jsbundle,app会一直读取旧的,改名就好了。。。非常奇葩的问题，我重新删了app，clean工程都没用，就是不能用main.jsbundle这个名字。（总结：不能用 main.jsbundle 来命名打包后的文件，否则会出现问题）

3、如果要真机测试或打包上传应用，记得把 Run 里面 Debug 改成 Release 来关闭 Debug 模式，因为 RN 自带 Chrome 的 Debug 模式。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/RN-Re.png)

4、打包命令中的路径(文件夹一定要存在)。

5、必须用 Create folder references 的方式引入图片的 bundle ，否则引用不到里面的图片。