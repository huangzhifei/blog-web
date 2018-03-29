---

title: Flexbox 布局整理

date: 2018-02-24 10:58:03

tags: RN

categories: React Native

---

参照文章：[React Native布局详细指南](https://github.com/crazycodeboy/RNStudyNotes/blob/master/React%20Native布局/React%20Native布局详细指南/React%20Native布局详细指南.md)

在 React Native 中使用 flexbox 规则来布局某个子元素，他能在不同的屏幕尺寸上提供一致的布局结构。他主要有 flex、flexWrap、flexDirection、justifyContent、alignItems 这几个样式属性。

## Flex

在组件的 style 中 flex 用来表示动态的扩张和收缩，他只接受一个数字参数，如我们使用 flex：1 来表示某个组件扩张撑满所有剩余的空间，如果有多个并列的子组件使用 flex：1，那他们就是按比例占有父容器中剩余的空间。

注意：如果父容器既没有固定的 width 和 height，也没有设定 flex，则父容器的尺寸就为零，其子组件就算使用了 flex，也是无法显示的。


## Flex Direction

在组件的 style 中指定 flexDirection 可以决定布局的主轴，子元素都是沿着水平轴（row）或竖起轴（column）布局的，默认是竖起轴（column）方向。

flexDirection enum('row', 'column','row-reverse','column-reverse')

见下图：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/flex-direction.jpg)


## Flex Wrap

在组件的 style 中指定 flexWrap 可以决定是否自动换行，默认为 nowrap 不换行

flexWrap enum('wrap', 'nowrap')

见下图：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/flex-wrap.jpg)


## Justify Content

在组件的 style 中指定 justifyContent 可以决定其子元素沿着主轴是什么样子的排列方式，主要的选项有：

flex-start（默认值）、center、flex-end、space-around、space-between

分别对应：主轴的起始位置、中心、末位置、等间距排列（包括两头，但是两头离边距的距离只有间距的一半）、等间距排列（不包括两头）

justifyContent enum('flex-start', 'flex-end', 'center', 'space-between', 'space-around')

见下图：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/justify-content.jpg)


## Align Items

在组件的 style 中指定 alignIems 可以决定其子元素沿着次轴（与主轴垂直的轴，比如主轴方向为 row，那么次轴就为 column）的排列方式。主要的选项有:

flex-start、center、flex-end、stretch（默认值）

注意：要使 stretch 选项生效的话，子元素在次轴方向上不能有固定的尺寸，如将子元素样式中的 width: 50 去掉之后，alignItems: 'stretch'才能生效。

alignItems enum('flex-start', 'flex-end', 'center', 'stretch')

见下图：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/alignItem.jpg)


### 子视图属性 alignSelf

alignSelf 属性定义了 flex 容器内被选中项目的对齐方式，注意：alignSelf 属性可重写灵活容器的 alignItems 属性

alignSelf enum('auto', 'flex-start', 'flex-end', 'center', 'stretch')

* auto(default) 元素继承了它的父容器的 align-items 属性。如果没有父容器则为 "stretch"。
 
* stretch	元素被拉伸以适应容器。
 
* center	元素位于容器的中心。
 
* flex-start	元素位于容器的开头。
 
* flex-end	元素位于容器的结尾。

