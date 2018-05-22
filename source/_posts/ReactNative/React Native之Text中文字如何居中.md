---

title: React Native之Text中文字如何居中

date: 2018-05-10 15:08:28

tags: RN

categories: React Native

---


Text 和 View 都是在垂直上包裹元素，水平上 100% 伸展（也就是铺满），可能这就是他蛋疼的地方，很多时间我们并不希望他铺满，这个时间就要配合 width、height、margin（不是padding）来配合使用，当然这个下面要说的内部没有关系，只不过在这里记录一下。

## text 的文字如何居中

Text 有一个布局属性 textAlign enum('auto', 'left', 'right', 'center', 'justify') 可以用来控制 Text 中文字 **水平** 对齐，是的你没有看错，只能控制其水平对齐。

当我们给 Text 设置 height 后，他就出问题了，没有垂直对齐，怎么让其垂直居中？

只讨论夸平台的方案，那些针对特定平台的处理不适合

### 方案一

设置 lineHeight, 如果 Text 的 height 为 100，设置 lineHeight 为 100, 文本就垂直居中了。（完美）

### 方案二

给 Text 设置 padding，这个就需要计算了，比如 Text 高度是 100， fontSize 是 20，那可以设置 paddingTop 为 40（fontSize 为 20，默认是 20 高度）

### 方案三

在 Text 外部在嵌套一个 View， 改变 View 的高度，在来调整 Text 的布局，这种方案麻烦，多出一个层级，会影响性能的。

### 总结

如果 lineHeight 在 android 上面不起作用（可能是bug）可以使用下面总结的方案：

```

import {StyleSheet,Platform} from 'react-native';

TextStyle:{
        height:36,
        width:100,
        textAlign:'center',
        alignItems:'center',
        justifyContent:'center',
        textAlignVertical:'center',
        ...Platform.select({
            ios:{
                lineHeight:36,
            },
            android:{
            }
        }),
}

```

## 补充

要想要一个控制垂直水平居中？我们只能在其交视图上设置 justifyContent 和 alignItems 都为 center，在自身设置是没有效果的。。

