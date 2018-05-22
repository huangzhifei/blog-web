---

title: React Native之Modal组件 

date: 2018-05-21 09:43:12

tags: RN

categories: React Native

---

Modal 组件可以用来覆盖包含 React Native 根视图的原生视图（如UIViewController，Activity）。

在嵌入 React Native 的混合应用中可以使用 Modal，Modal 可以使你应用中 RN 编写的那部分内容覆盖在原生视图上显示。

## 属性

### 1、animationType

动画类型，PropTypes.oneOf(['none', 'slide', 'fade'])

none: 没有动画

slide: 从底部滑入

fade: 淡入视野

默认是 none

### 2、transparent

渲染时背景的透明度，true时，则透明的方式模态渲染（一般都要使用true）

### onRequestClose

被销毁时会调用此函数 
Platform.OS ==='android'？PropTypes.func.isRequired：PropTypes.func
在 'Android' 平台，必需使用此函数。

### onShow

模态显示的时候会被调用一次

### visible

决定模态是否可见

上面几个就是我们在使用 Modal 的时候经常需要使用到的属性

## 使用样例

我们自己使用 Modal 封装一个简单的 HUD

创建 HUD.js 文件

```
/*
 自定义简单的 hud
 */


import React, {Component} from 'react';
import { 
    StyleSheet, 
    View, 
    Modal, 
    ActivityIndicator,
    Text
} from 'react-native';

import PropTypes from 'prop-types';

export default class HUD extends Component {
    constructor (props) {
        super(props);
    }

    static defaultProps = {
        animationType: "none",
        loading: false,
        activityIndicatorColor: "#FFFFFF",
        size: "small",
        loadText: null,
        opacity: 0,
    };

    static propTypes = {
        animationType: PropTypes.oneOf(["none", "slide", "fade"]),
        loading: PropTypes.bool.isRequired,
        activityIndicatorColor: PropTypes.string,
        size: PropTypes.string,
        loadText: PropTypes.string,
        opacity: PropTypes.number,
    }
    
    componentWillUnmount () {
        this.timer && clearTimeout(this.timer);
    }

    componentWillReceiveProps (nextProps) {
        let newShow = nextProps.loading;
        let oldShow = this.props.loading;
    }

    render () {
        return (
            <Modal
            transparent = {true}
            animationType={this.props.animationType}
            visible={this.props.loading}
            onRequestClose={() => null}
            >
            <View
                style={[
                styles.modalBackground,
                { backgroundColor: `rgba(0,0,0,${this.props.opacity})` }
                ]}
            >
                <View style={styles.activityIndicatorWrapper}>
                    <ActivityIndicator animating={this.props.loading} 
                                       color={this.props.activityIndicatorColor} 
                                       size={this.props.size} />

                    <Text style={styles.hudTextStyle}>
                        {this.props.loadText}
                    </Text>
                </View>
            </View>
            </Modal>
        );
    }
}

const styles = StyleSheet.create({
    modalBackground: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center'
    },
    activityIndicatorWrapper: {
        backgroundColor: 'rgba(0,0,0,0.8)',
        borderRadius: 10,
        alignItems: 'center',
        justifyContent: 'center',
        padding: 10,
        paddingTop: 15,
    },
    hudTextStyle: {
        backgroundColor: 'transparent',
        alignItems: 'center',
        justifyContent: 'center',
        color: '#FFFFFF',
        padding: 10,
        paddingTop: 15,
        paddingBottom: 5
    }
});

```

预留了一些属性，大家一看就明白

使用

```
<HUD loading={this.state.isLoading} 
   activityIndicatorColor="#FFFFFF" 
   animationType = "fade" 
   loadText = "加载中..."/>
```

在合适的地方改变 this.state.isLoading 的值，HUD 就隐藏了。（比如在数据回来后）

