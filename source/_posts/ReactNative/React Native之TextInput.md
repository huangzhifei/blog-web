---

title: React Native之TextInput

date: 2018-05-22 14:39:34

tags: RN

categories: React Native

---

## 概述

TextInput组件和Text组件类似，内部都没有使用FlexBox布局，不同的是TextInput组件支持文字的输入，因为支持文字输入，TextInput组件要比Text组件多了一些属性和方法。TextInput组件支持Text组件所有的Style属性，而TextInput组件本身是没有特有的Style属性的。

## 属性

TextInput组件支持所有的View组件的属性，除此之外，它还有许多其他属性。

### onChangeText

当输入框的内容发生变化时，就会调用onChangeText，此回调会传回来一个参数，当前输入框内的内容

### onChange

此回调功能同上，只不过回调参数是一个event，里面包含其他内容

### keyboardType

用于设置弹出软键盘的类型，他的值是一个枚举，值很多，其中要注意哪几个是跨平台的，去API文档一看就知道。

### blurOnSubmit

如果 blurOnSubmit 为 true，文本框会在按下提交健时失去焦点，对于单行输入框，些值默认为 true，多行为false。

### onSubmitEditing

当提交键被按下时会调用 onSubmitEditing，如果 multiline 等于 true，则此回调不可用。

### 其他跨平台属性

##### 1、autoCapitalize

enum('none', 'sentences', 'words', 'characters')，设置英文字母自动大写规则，取值分别表示：不自动大写、每句话首字母自动大写、每个单词首字母大写、全部字母自动大写。

##### 2、autoCorrect

是否会自动检测用户输入的英语单词正确性，默认值为true。

##### 3、autoFocus

如果为true，在componentDidMount后会获得焦点。默认值为false。

##### 4、defaultValue

字符初始值，当用户开始输入时，该值将改变。

##### 5、placeholder

文本输入之前将呈现的字符串，多用于提示用户应该输入什么。

##### 6、placeholderTextColor

文本输入之前将呈现的字符串的颜色。

##### 7、editable

是否允许修改字符，默认值为true。

##### 8、maxLength

最多允许用户输入多少字符。

##### 9、caretHidden

如果为true，则隐藏光标。

##### 10、multiline

如果为true，则文本输入可以是多行的，默认值为false。

##### 11、secureTextEntry

文本框是否用于输入密码，默认值为false。

##### 12、selectTextOnFocus

如果为true，则文本框获取焦点时，组件中的内容会被自动选中。

##### 13、onFocus

当文本框获得焦点的时候调用此回调函数。

##### 14、onEndEditing

当文本输入结束后调用此回调函数。

##### 15、onLayout

当组件挂载或者布局变化的时候调用，参数为{x, y, width, height}。

##### 16、onScroll

在内容滚动时持续调用，传回参数的格式形如{ nativeEvent: { contentOffset: { x, y } } }。

##### 17、onSelectionChange

长按选择文本时，选择范围变化时调用此函数，传回参数的格式形如 { nativeEvent: { selection: { start, end } } }。

##### 18、value

文本框中的文字内容。

### Android平台独有属性

##### 1、inlineImageLeft

指定一个图片放置在左侧。

##### 2、inlineImagePadding

左侧图片的Padding(如果有的话)，以及文本框本身的Padding。

##### 3、numberOfLines

TextInput的行数。

##### 4、underlineColorAndroid

TextInput的下划线颜色。

##### 5、returnKeyLabel

设置软键盘回车键的内容，优先级高于returnKeyType。

##### 6、disableFullscreenUI

值为false时(默认值)，如果TextInput的输入空间小，系统可能会进入全屏文本输入模式。

###  iOS平台独有属性

##### 1、clearButtonMode

enum('never', 'while-editing', 'unless-editing', 'always')，何时在文本框右侧显示清除按钮

##### 2、clearTextOnFocus

如果为true，每次开始输入的时候都会清除文本框的内容

##### 3、keyboardAppearance

enum('default', 'light', 'dark')，键盘的颜色

##### 4、onKeyPress

回调函数，一个键被按下的时候调用此回调，传递给回调函数的参数为{ nativeEvent: { key: keyValue } }

##### 5、spellCheck

如果为false，则禁用拼写检查的样式（比如红色下划线）

##### 6、enablesReturnKeyAutomatically

如果为true，键盘会在文本框内没有文字的时候禁用确认按钮 ，默认值为false

## 方法

### clear()

用于清空输入框的内容，我们通过给 TextInput 设置 ref 名，来在其他地方获取到组件对于操作。

在 TextInput 标签中定义引用的名称：ref="textInputRefer"，然后在通过 this.refs.textInputRefer 得到其引用。

### isFocused(): boolean

返回值表明当前输入框是否获得了焦点。