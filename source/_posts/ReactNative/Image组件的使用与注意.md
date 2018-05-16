---

title: Image组件的使用与注意

date: 2018-05-15 09:55:33

tags: RN

categories: React Native

---

Image 是一个用来显示网络或本地图片资源的组件。

## 方法

有几个常用方法

### onLayout 

当元素挂载或布局改变的时候，会触发此回调函数。

### onError

当加载出错后会触发此回调函数。

### onLoad

当加载成功后会触发此回调函数。

### onLoadEnd

不管是加载成功或失败都会触发此回调函数。

### onLoadStart

当开始加载的时候会触发此回调函数。

## 属性

### resizeMode

此属性是当前图片尺寸与组件不成比例时候的调整策略，他有如下几个枚举值：

```
"cover" | "contain" | "stretch" | "repeat" | "center";
```

**1、cover:** 在保持图片宽高比的前提下宿放图片，直到宽度和高度都大于等于容器视图的尺寸（如果容器有padding的话，则会相应的减去），这样图片会完全覆盖甚至超出容器，容器中不会留下任何空白。

**2、contain:** 在保持图片宽高比的前提下宿放图片，直到宽度和高度都小于等于容器视图的尺寸（如果容器有padding的话，则会相应的减去），这样图片会完全被包裹在容器中，容器中可能会留有空白。

**3、stretch:** 拉伸图片且不维持宽高比，直到宽高都刚好填满容器。

**4、repeat:** 重复平铺图片直到填满容器，图片会维持原始尺寸，但仅仅 iOS 能用。

**5、center:** 居中不拉伸。

### source

**1、本地图片:** 使用 require('相对路径')来加载引用图片，不需要指定 width 和 height

**2、网络图片:** 使用 uri 来加载一个 http 地址的图片，看下面的例子：

```
source = {{uri:item.imgUrl, width: 222, height: 95, cache:'force-cache'}
```

必须要指定图片的 width 和 height，不然会不显示网络图片（因为图片 width 和 height 都为 0）

**cache:** 这个是用来控制缓存策略的:

| 枚举				| 			说明			|
| :------------:	| :-------------------	|
| **default**		| 使用原生平台默认策略		|
| **reload**		| URL的数据将从原始地址加载。不使用现有的缓存数据|
| **force-cache**| 现有的缓存数据将用于满足请求，忽略其期限或到期日。如果缓存中没有对应请求的数据，则从原始地址加载					|
| **only-if-cached**| 现有的缓存数据将用于满足请求，忽略其期限或到期日。如果缓存中没有对应请求的数据，则不尝试从原始地址加载，并且认为请求是失败的|

### style

样式属性里面有几个说明一下：

**1、backgroundColor:** 很多时间需要图片当背景，上面有文字之类的，我们需要设置此值为 'transparent' 来消除 Text 的自带背景（在Text的样式里面设置）

**2、overflow:** 枚举值有 'visible' 和 'hidden'，设置为 'hidden' 就会把超过父控件的部分截取掉。

**3、width:** 我们可以通过设置一个百分比 '100%'、'90%'......来控制其对父控件的宽度，（比较方便）。


## 图片铺满

对于图片我们需要设置宽度才能显示，如果这个宽度比较大，对于不同的机型如何适配（比如：小屏），可以通过如下方式调整，但是图片可能会变型

```
<Image source = {require('../../Res/images/xxx.png')} style = {styles.bgImageStyle} resizeMode = "stretch">
    <Text style = {styles.titleStyle}>
        {this.props.title}
    </Text>         
</Image>

const styles = StyleSheet.create({
    bgImageStyle: {
        marginTop: 12,
        marginBottom: 18,
        marginLeft: 0,
        marginRight: 0,
        width: '100%',
    },
});
```

通过设置 width 为 100%，在设置 resizeMode = 'stretch' 就可以做到不同尺寸屏幕的适配。

## 网络图占位

我们先来了解一下 Image 组件渲染绘制图像时的原理，如果当前 Image 上已经有一张绘制好的图像，在重新加载另一张新图像时，如果新图像还没有完全加载绘制好，还是会先显示之前的图像。

我们首先展示占位图，然后设置一个 state 值，当网络数据返回后更新些值或者网络图片加载完成，就会去刷新，这个时候在根据这个值来判断是否去加载url的图片（有人担心我们在 onLoadEnd 或 onError 里面改变state，会不会出现死循环？不会的，RN做了优化了）
看如下代码：

```
export default class ImageLoad extends Component {

    constructor (props) {
        super (props);
        this.state = {
            showDefault: true,
        }
    }

    static defaultProps = {
        placeHolder: null,
        source: null,
        resizeMode: "cover"
    };

    static PropTypes = {
        placeHolder: PropTypes.object,
        source: PropTypes.string.isRequired,
        resizeMode: PropTypes.string
    };

    render() {
        var image = this.props.placeHolder;
        if (!this.props.placeHolder) {
            image = this.props.source;
        } else {
            image = this.state.showDefault ? this.props.placeHolder : this.props.source;
        }
        return (
            <Image style = { this.props.style } 
                    source = { image }
                    onLoadEnd = { () => {
                        if (this.props.placeHolder) {
                            // setTimeout(() => {
                            //     this.setState({
                            //         showDefault: false
                            //     })
                            // }, 10);
                            this.setState({
                                showDefault: false
                            })
                        } 
                    }
                }
                resizeMode = { this.props.resizeMode }>
            </Image>
        );
    }
}
```

目前此组件还比较简单，可以添加一个加载提示，在加个动画让占位图和网络图切换的流畅点。
