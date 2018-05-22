---

title: React Native之非Flexbox布局整理

date: 2018-02-23 13:43:09

tags: RN

categories: React Native

---

参照文章：[React Native布局详细指南](https://github.com/crazycodeboy/RNStudyNotes/blob/master/React%20Native布局/React%20Native布局详细指南/React%20Native布局详细指南.md)

React Native 支持除 flex 之外其他很多布局属性

## 视图边框

* borderBottomWidth: number 底部边框宽度

* borderLeftWidth: number 左边框宽度

* borderRightWidth: number 右边框宽度

* borderTopWidth: number 顶部边框宽度

* borderWidth: number 边框宽度

* border<Bottom|Left|Right|Top>Color: 'RGBA' 个方向边框的颜色

* borderColor: 'RGBA' 边框颜色


## 尺寸

* width: number 宽

* height: number 高


## 外边距

* margin: number 外边距

* marginBottom: number 下外边距

* marginHorizontal: number 左右外边距
 
* marginLeft: number 左外边距

* marginRight: number 右外边距

* marginTop: number 上外边距
 
* marginVertical: number 上下外边距

## 内边距

* padding: number 内边距

* paddingBottom: number 下内边距
 
* paddingHorizontal: number 左右内边距
 
* paddingLeft: number 做内边距

* paddingRight: number 右内边距

* paddingTop: number 上内边距

* paddingVertical: number 上下内边距


## 边缘

* left: number 属性规定元素的左边缘。该属性定义了定位元素左外边距边界与其包含块左边界之间的偏移。
 
* right: number 属性规定元素的右边缘。该属性定义了定位元素右外边距边界与其包含块右边界之间的偏移
 
* top: number 属性规定元素的顶部边缘。该属性定义了一个定位元素的上外边距边界与其包含块上边界之间的偏移。
 
* bottom: number 属性规定元素的底部边缘。该属性定义了一个定位元素的下外边距边界与其包含块下边界之间的偏移。


## 定位(position)

position enum('absolute', 'relative')属性设置元素的定位方式，为将要定位的元素定义定位规则。

* absolute：生成绝对定位的元素，元素的位置通过 "left", "top", "right" 以及 "bottom" 属性进行规定。

* relative：生成相对定位的元素，相对于其正常位置进行定位。因此，"left:20" 会向元素的 LEFT 位置添加 20 像素。

