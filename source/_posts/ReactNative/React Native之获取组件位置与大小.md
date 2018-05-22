---

title: React Native之获取组件位置与大小

date: 2018-05-21 17:48:10

tags: RN

categories: React Native

---

在 React Native 的页面布局中，有时候需要获取元素的大小和位置，下面从网上找了几个方法，以备不时之需。

### 设备屏宽高

```
import {Dimensions} from 'react-native';
var {height, width} = Dimensions.get('window');
```

### 组件位置与大小

#### 方法一

onLayout 事件属性

```
_onLayout(event){
    let {x,y,width,height} = e.nativeEvent.layout
}
....
<View onLayout={(e) => this._onLayout}></View>
```

当组件重新渲染时，该方法就能重新获取到元素的宽高和位置信息。

#### 方法二

元素自带的 measure 方法

首先给元素添加上 ref

```
<View ref={(view) => this.myView = view}></View>
```

然后在需要的地方使用下面代码来获取

```
this.myView.measure((x,y,width,height,left,top) => {
    //todo
})
```

但是如果想在 componentDidMount 方法里面获取的话，需要添加一个定时器，在定时器里面去测量，可能是此时组件还没有完全渲染完成。

```
componentDidMount(){
    setTimeOut(() => {
      this.myView.measure((x,y,width,height,left,top) => {
        //todo
      })
   });
}
```

实际使用过程中我发现这个方法在自定义的组件上会失效，只能应用在 React Native 自带的 View 等组件上，使用时需要注意一下。

#### 方法三

使用 UIManager measure 方法

引入 UIManager

```
import {
    UIManager,
    findNodeHandle
} from 'react-native';
```

其次一样给组件添加上 ref

```
<MyComponent  ref={(ref)=>this.myComponent=ref} />
```

最后在需要的地方去测量

```
UIManager.measure(findNodeHandle(this.myComponent),(x,y,width,height,pageX,pageY)=>{
   //todo
})
```

### 总结

之前习惯了其他语言可以直接获取控件的大小和位置，现在突然发现 React Native 在这方面操作起来还是蛮复杂的，不过知道了对应的获取方法就没问题了。



