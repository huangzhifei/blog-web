---

title: ES6下组件的默认属性与默认状态

date: 2018-05-07 14:49:29

tags: RN

categories: React Native

---

网上大部分还是 ES5 的一些三方库，写法也是 ES5 的，下现我们列出 ES5 与 ES6 的对比写法。

### 属性(props)

**在ES5里，属性类型和默认属性分别通过propTypes成员和getDefaultProps方法来实现**

```
var Video = React.createClass({
    getDefaultProps: function() {
        return {
            autoPlay: false,
            maxLoops: 10,
        };
    },
    propTypes: {
        autoPlay: React.PropTypes.bool.isRequired,
        maxLoops: React.PropTypes.number.isRequired,
        posterFrameSrc: React.PropTypes.string.isRequired,
        videoSrc: React.PropTypes.string.isRequired,
    },
    render: function() {
        return (
            <View />
        );
    },
});
```

**在 ES6 里，可以统一使用 static 成员来实现**

```
//ES6

import PropTypes from 'prop-types';

class Video extends React.Component {
    static defaultProps = {
        autoPlay: false,
        maxLoops: 10,
    };  // 注意这里有分号
    
    static propTypes = {
        autoPlay: PropTypes.bool.isRequired,
        maxLoops: PropTypes.number.isRequired,
        posterFrameSrc: PropTypes.string.isRequired,
        videoSrc: PropTypes.string.isRequired,
    };  // 注意这里有分号
    
    render() {
        return (
            <View />
        );
    } // 注意这里既没有分号也没有逗号
}
```

注意：React.PropTypes 在高版本里面已经被移动到 prop-types 这个 lib 里面了，以后我们使用的时候需要单独导入一下。

常用的有以下：

```
# 为任何类型
PropTypes.any

# 为 React 元素
PropTypes.element

# 数组类型
PropTypes.array

# 布尔类型
PropTypes.bool

# 函数类型
PropTypes.func

# 数值类型
PropTypes.number

# 对象类型
PropTypes.object

# 字符串类型
PropTypes.string

# 为可渲染的节点
PropTypes.node

# 为几个特定的值
PropTypes.oneOf(['value1', 'value2'])

# 为某个指定类的实例
PropTypes.instanceOf(NameOfClass)

# 为指定类型的数组
PropTypes.arrayOf(PropTypes.string)

# 为几个指定的类型中的一个
PropTypes.oneOfType([
	PropTypes.object,
	PropTypes.string
])

```

### 状态(state)

ES5下写法：

```
var Video = React.createClass({
    getInitialState: function() {
        return {
            loopsRemaining: this.props.maxLoops,
        };
    },
})
```

ES6下写法：

```
//ES6
class Video extends React.Component {
    state = {
        loopsRemaining: this.props.maxLoops,
    }
}
```

在ES6下，我们推荐更易理解的方式，我们在构造函数初始化：

```
//ES6
class Video extends React.Component {
    constructor(props){
        super(props);
        this.state = {
            loopsRemaining: this.props.maxLoops,
        };
    }
}
```