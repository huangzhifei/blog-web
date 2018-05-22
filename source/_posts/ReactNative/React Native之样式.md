---

title: React Native之样式

date: 2018-05-08 18:01:41

tags: RN

categories: React Native

---

### 内联样式

从语法上来看，内联样式是 React Native 中编写组件样式最简单的一种方法，但是他不是最佳的，我们应该尽量避免使用，内联样式对象会在每一个渲染周期都被重新创建。

样例：

```
<Text style = {{fontSize: 12}} />
```

### 对象样式

我们是可以给 style 属性传入一个对象的，这样就没有必要在每次调用 render 方法时都重新创建样式对象。

两种方式创建对象样式：

#### 1、直接定义样式对象

直接定义全局或内部变量样式，优点是可变性，缺点是代码块看起来会很乱，不建议这样。

```
var bold = {
	fontWeight: 'bold'
}

...

render () {
	return (
		<Text style = {bold}>
			xxxx
		</Text>
	);
}
```

#### 2、通过 StyleSheet.create 来创建

StyleSheet 创建的样式是不可变的，他保证了值是不可变的，并且会将他们转换成指向内部表的纯数字，起到了代码混淆保护的作用，将他们放在文件的末尾可保证他们在应用中只会被创建一次，而不是每一次渲染周期都被重新创建，性能上会好很多，也统一了样式处理，方便管理。

```
const styles = StyleSheet.create({
    containerStyle: {
        flexDirection: 'row',
        backgroundColor: 'white'
    },
    bgImageStyle: {
        marginTop: 12,
        marginBottom: 18,
        borderRadius: 30
    }
}
```

直接通过 styles.containerStyle 来使用。

### 样式作为属性传递

为了能够在调用组件的地方对其子组件样式进行自定义，你还可以将样式作为参数进行传递，可以使用 View.propsTypes.style 和 Text.propsTypes.style 来确保传递的参数确实是 style 类型的。

```
export default class StyleDelivery extends Component {
    static defaultProps = {
        textStyle: null
    };

    static propTypes = {
        textStyle: Text.propTypes.style,
    };
    
    render () {
        return (
            <View style = {{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
                <Text style = {this.props.textStyle}>
                    使用传递过来的样式
                </Text>
            </View>
        );
    }
}

// ... 在别的文件中引用 StyleDelivery 组件 ...
<StyleDelivery textStyle={styles.list} />
```

由于 StyleSheet.create() 创建的样式对象会被优化成数字，所以我们使用 Text.propTypes.style 来强制让其为样式属性，还可以使用 View.propTypes.style 来限制。

