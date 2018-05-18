---

title: React Native UI组件继承

date: 2018-05-17 15:57:36

tags: RN

categories: React Native

---

主要是介绍在 ES6 下面的继承，通过一个业务场景来描述。

场景：

假设我们 App 中有一部分基础按钮，他们除了样式与用法不同外，其他基本固定，这样我就可以实现一个父按钮，提供公共属性和方法，子类去继承此父按钮后，只需要定制一下样式就行了。

1、创建一个 ButtonBase.js 

```
import React, {Component} from 'react';

import PropTypes from 'prop-types';

export const ThemeColor = {
    btnThemeColor: '#bc9956',
    btnDisableColor: '#cccccc'
}

export default class BaseButton extends Component {
    constructor(props) {
        super(props);
    }

    static propTypes = {
        // 外边框样式
        style: PropTypes.any,
        // 按钮的文字自定义样式
        textStyle: PropTypes.any,
        // 按钮是否可点
        enable: PropTypes.bool,
        // 按钮文案
        text: PropTypes.string,
        // 这里只是举例，可以根据需求继续添加属性...
        // 按钮点击
        onPress: PropTypes.func,
    };

    static defaultProps = {
        enable: true,
    };

    onBtnPress() {
        if (!this.props.enable) return;

        this.props.onPress && this.props.onPress();
    }
    
    
    // render () {
    //     return (
    //         <View>
              
    //         </View>
    //     );
    // }
}
```

这个基类里面定义一些通用方法和属性，如：点击、文本颜色等，然后我们定义一个 NormalButton 来继承于他，看到下面 render 方法被注释掉，写不写这个方法无所谓的，因为如果子类继承后，就会使用自己的render，不会调用父类的。

2、创建 NormalButton.js

```

import React, {Component} from 'react';
import {
    View, 
    Text, 
    TouchableOpacity,
    StyleSheet
} from 'react-native';

import BaseButton, {ThemeColor} from './ButtonBase';
/**
 * 普通按钮,没有边框,可通过style改变按钮大小
 */
export default class NormalButton extends BaseButton {
    render() {
        const {style, enable, text, textStyle} = this.props;

        return(
            <TouchableOpacity
                style={[styles.normalBtn, style, !enable && styles.disableBtn]}
                activeOpacity={1}
                onPress={()=>this.onBtnPress()}
            >
                <Text style={[styles.btnTextWhite, textStyle]}>{text}</Text>
            </TouchableOpacity>
        );
    }
}

const styles = StyleSheet.create({
    normalBtn: {
        height: 44,
        width: 100,
        borderRadius: 6,
        backgroundColor: ThemeColor.btnThemeColor,
        alignItems: 'center',
        justifyContent: 'center',
    },
    btnTextWhite: {
        fontSize: 16,
        color: 'white',
    },
    disableBtnText: {
        fontSize: 16,
        color: ThemeColor.btnDisableColor,
    }
});

```

这样我们就利用了父类的属性了，父类的点击逻辑等等。

注意：TouchableOpacity 中的 activeOpacity 这个属性，默认是 0.2，也就是点击时的透明效果，为原背景的 0.2，现在我们设置此值为 1， 那就是点击时背景和没点击时一样的，也就看不到闪动效果了（和TouchableWithoutFeedback 效果一样了）。

