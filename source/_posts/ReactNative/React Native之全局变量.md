---

title: React Native之全局变量

date: 2018-05-18 14:39:24

tags: RN

categories: React Native

---

React Native 有两种方式使用全局变量

## 通过导入导出文件的方式

新建立单独的一个 js 文件

```
export const object = {
	website: 'http://www.baidu.com',
	name: '百度'
}
```

然后在需要用到的时候导入文件

```
import constants from './xxxx.js';
<Text>
	{constants.name}
</Text>
```

## 通过声明全局变量的方式

一定是先声明，后调用的顺序

创建一个单独的 js 文件

```
var storage = {
	size: 1000,
	defaultExpires: 1000 * 3600
}

global.storage = storage;
```

使用方法：在入口文件处一次调用（如：index.ios.js），但是这样要写两遍（还有 index.android.js），所以最好在这两个文件都要调用的地方调用一次，比如都要调用 setup 来加载主页。

调用的时候只需要引入就可以了，这样就能全局使用了，并且不需要from才能保证这个文件不是一个孤立的没运行的文件，还得保证import的顺序，即必须在其他使用storage的组件之前import

```
import './xxx.js'；

#其他文件使用

<Text>{global.storage.size}</Text>

```

最常用的场景的是封装一个全局的持久化数据的类，比较出名的就是 react-native-storage 封装了 AsyncStorage ，大家可以去他的实现与使用。

