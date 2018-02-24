---

title: Flexbox 布局整理

date: 2018-02-24 10:58:03

tags: RN

categories: React Native

---

在 React Native 中使用 flexbox 规则来布局某个子元素，他能在不同的屏幕尺寸上提供一致的布局结构。他主要有 flexDirection、alignItems、justifyContent 三个样式属性。

## Flex Direction

在组件的 style 中指定 flexDirection 可以决定布局的主轴，子元素都是沿着水平轴（row）或竖起轴（column）布局的，默认是竖起轴（column）方向。

```
import React, { Component } from 'react';
import { AppRegistry, View } from 'react-native';

class FlexDirectionBasics extends Component {
  render () {
    return (
      // 尝试把`flexDirection`改为`column`看看
      <View style={{flex: 1, flexDirection: 'row'}}>
        <View style={{width: 50, height: 50, backgroundColor: 'powderblue'}} />
        <View style={{width: 50, height: 50, backgroundColor: 'skyblue'}} />
      </View>
    );
  }
};

```

## Justify Content

在组件的 style 中指定 justifyContent 可以决定其子元素沿着主轴是什么样子的排列方式，主要的选项有：

flex-start、center、flex-end、space-around、space-between

分别对应：主轴的起始位置、中心、末位置









