---

title: JavaScript 箭头函数

date: 2018-03-06 11:11:34

tags: JS

categories: JavaScript
 
---

箭头函数不只是语法上的简洁，他也影响了 this 的作用域，箭头函数内部的 this 是词法作用域，由上下文确定！

## 语法

常规函数语法定义如下：

```
function funcName(params) {
   return params + 2;
}
funcName(2);
```

打印：4

我们来使用 箭头函数 改写上面的写法：

```
var funcName = (params) => params + 2;
funcName(2);
```

有没有觉得很简洁，我们来深入了解箭头函数的几种语法：

### 基本写法

```
(params) => { statements }
```

### 没有参数，简化

```
() => { statements }
```

### 只有一个参数，简化

```
params => { statements }
```

### 返回值只有一个表达式，简化

```
params => statements 
```

### 建议

该有小括号的我们还是加上小括号，该有大括号的，我们也都加上大括号，严格要求，也是为了方便观看！


## this 的绑定

在箭头函数出现之前，每个新定义的函数都有它自己的 this值，和一般的函数不同，箭头函数不会绑定 this。 或则说箭头函数不会改变 this 本来的绑定，箭头函数内部的 this 是词法作用域，由上下文确定。

```
function Counter() {
  this.num = 0;
}
var a = new Counter();

```

因为使用了关键字new构造，Count()函数中的this绑定到一个新的对象，并且赋值给a。通过console.log打印a.num，会输出0。

我们在来看下一个例子：

```
function Counter() {
  this.num = 0;
  this.timer = setInterval(function add() {
    this.num++;
    console.log(this.num);
  }, 1000);
}

var b = new Counter();
```
也许我们理所当然的认为会累加输出，结果如下：
// NaN
// NaN
// NaN
// NaN
// ...
问题出在哪？一看就像是没有初始或没有此变量的样子，那肯定是 this 对象不对。

我们看函数 setInterval() ，他没有被某个声明的对象调用，也没有使用 new 关键字，更没有使用 bind、call 和 apply 等去关联 this，我们在他里面可以增加一行打印 this 的语句 

```
console.log(this)
```

你会发现，整个 window 对象被打印出来了，那就说明函数里面的 this.num 绑定到 window 对象的 num，但是 window.num 并没有定义。

如何解决？使用箭头函数！使用箭头函数就不会导致this被绑定到全局对象。

```
function Counter() {
  this.num = 0;
  this.timer = setInterval(() => {
    this.num++;
    console.log(this.num);
  }, 1000);
}
var b = new Counter();
```

