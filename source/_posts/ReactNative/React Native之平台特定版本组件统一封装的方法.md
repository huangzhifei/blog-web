---

title: React Native之平台特定版本组件统一封装的方法

date: 2017-05-08 15:43:05

tags: RN

categories: React Native

---

在写这篇文章的时候，相对新一点的 react native 版本内部已经替我们处理好特定平台选择，如 SwitchIOS 和 SwitchAndroid，正常的思路可能会在代码逻辑里面加如下判断：

```
if (Android) {
	use SwitchAndroid
} else {
	use SwitchIOS
}
```

这样做比较麻烦，平台已经替我们处理好了，直接使用 Switch 组件就可以了，内容他会自己会切换的（妈蛋：我使用SwitchIOS，死活都报莫名其妙的错，还找不到原因）

如果想自己封一些特定平台的组件，也想很方便的使用，该怎么办了？

就拿 SwitchIOS 和 SwitchAndroid 来当例子，我们要利用 .ios.js 和 android.js 这样的后缀：

1、创建 Swithc.ios.js 和 Switch.android.js 

2、里面的类导出甚至都可以一样

3、外部使用的时间直接 import CustomSwitch from './Switch',平台会自动去找相对应的后缀来加载的

4、最好提供一样的属性，只是内部实现逻辑不同，这样就统一了

看下面简单的例子伪代码

Swithc.ios.js

```
import React, {Component} from 'react';

export default class SwitchXX extends Component {
	// do something...
    render () {
        return (
            <SwitchXX />
        );
    }
}
```

Swithc.android.js

```
import React, {Component} from 'react';

export default class SwitchXX extends Component {
	// do something...
    render () {
        return (
            <SwitchXX />
        );
    }
}
```

外部统一使用 SwitchXX 就行了。

**高一点的版本 RN 已经替我们处理好这些细节了，如果发现使用带平台后缀的组件时莫名其妙出错，请尝试使用不带特定平台后续的组件试试。
**