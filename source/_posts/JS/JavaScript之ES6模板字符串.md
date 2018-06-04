---

title: JavaScript之ES6模板字符串

date: 2018-05-02 09:46:14

tags: JS

categories: JavaScript

---


### 模板字符串

ES6 中引入了一种新型的字符串语法，可以在字符串文本中内嵌表示式的字符串，看下面一段例子：

```
var name = '姓名';
var desc = '姓名是一种描述';
var html = (name, desc) {
    var tpl = '公司名：' + name + '\n'+ '简介：'+ desc;
    return tpl;
}
```
上面写法是以前的常规模式，下面可以使用新的语法和更简洁的书写：

```
var name = '姓名';
var desc = '姓名是一种描述';
var html = `公司名：${name}
    简介：${desc}`;
```
引用  MDN 对于模板字符串的定义：
	
	模板字符串使用反引号``来代替普通字符串中的用双引号和单引号，模板字符串可以包含特定语法${expression}的占位符，占位符中的表达式和周围的文本会一起传给一个默认函数，该函数系统会负责将所有的部分连接起来。


对于占位符 ${}, 可以是任意的 js 表达式（函数或运算），甚至是另一个模板字符串。注意如果模板中需要使用 ${ 这样的字符串，就需要转义。

例子:

```
vax x = 1;
var y = 2;
`${x} + ${y} = ${x + y}` // "1+2=3"
```


### 标签模板

标签模板则是在反引号前面添加一个标签 (tag), 该标签是一个函数，用于处理模板字符串返回值，例子：

```
function SaferHTML(templateData) {
  var s = templateData[0];
  for (var i = 1; i < arguments.length; i++) {
    var arg = String(arguments[i]);
    // Escape special characters in the substitution.
    s += arg.replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;");
    // Don't escape special characters in the template.
    s += templateData[i];
  }
  return s;
}
// 调用
var html = SaferHTML`<p>这是关于字符串模板的介绍</p>`;

```

SaferHTML 是标签函数名

后面根着模板字符串

标签函数是可以接受多个参数的，参数是以 ${} 占位符来区分的，比如 

```
SaferHTML`我是参数1${x}我是参数2`
```
如果传入的是这样的参数，则标签函数会收到两个参数列表，"我是参数1${x}" "我是参数2" 

有了标签模板后，就可以控制模板字符串的返回处理，更加方便了。

