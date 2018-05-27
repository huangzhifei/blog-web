---

title: React Native之Modal定义分享界面

date: 2018-05-27 10:11:12

tags: RN

categories: React Native

---

## 介绍

上次介绍了 Modal 后顺手写了一个 HUD ，这次我们使用 Modal 来写一个简单的分享界面， Modal 组件还是相当好用的。

首页我们上个最终的图片，然后简单分析一下布局

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/shareDialog.png)

1、上面一个 Text 装载文字

2、下面一个 View 装载三个 item

3、每次 item 里面装载 image 和 text

4、后面一个全屏的 View ，通过改变背景色及透明度、增加 touch 功能来让其 close

5、最外面使用 Modal 组件包裹，这样一个简单的modal分享组件就完成了

## 实现

创建 ShareDialog.js 文件

```
/*
 * @Author: eric.huang 
 * @Date: 2018-05-26 17:21:41 
 * @Last Modified by: eric.huang
 * @Last Modified time: 2018-05-27 09:58:14
 */

// 分享弹窗

import React, {Component} from 'react';
import {
    View, 
    TouchableOpacity, 
    Alert,
    StyleSheet, 
    Dimensions, 
    Modal, 
    Text, 
    Image
} from 'react-native';

import Separator from "./DivideLine";

const {width, height} = Dimensions.get('window');
const dialogH = 200;
const itemH = 100;

export default class ShareDialog extends Component {

    constructor(props) {
        super(props);
        this.state = {
            isVisible: this.props.show,
        };
    }

    componentWillReceiveProps(nextProps) {
        this.setState({isVisible: nextProps.show});
    }

    closeModal() {
        this.setState({
            isVisible: false
        });
        this.props.closeModal && this.props.closeModal(false);
    }

    renderDialog() {
        return (
            <View style={styles.modalStyle}>
                <Text style={styles.textStyle}>选择分享方式</Text>
                <Separator/>
                <View style={styles.shareModalStyle}>
                    <TouchableOpacity activeOpacity = {1.0} style={styles.itemStyle} onPress={() => Alert.alert('分享到微信朋友圈')}>
                        <Image resizeMode='contain' style={styles.imageStyle}
                            source={require('../../Res/images/share_ic_friends.png')}/>
                        <Text>微信朋友圈</Text>
                    </TouchableOpacity>
                    <TouchableOpacity activeOpacity = {1.0} style={styles.itemStyle} onPress={() => Alert.alert('分享到微信')}>
                        <Image resizeMode='contain' style={styles.imageStyle}
                            source={require('../../Res/images/share_ic_weixin.png')}/>
                        <Text>微信好友</Text>
                    </TouchableOpacity>
                    <TouchableOpacity activeOpacity = {1.0} style={styles.itemStyle} onPress={() => Alert.alert('分享到微博')}>
                        <Image resizeMode='contain' style={styles.imageStyle}
                            source={require('../../Res/images/share_ic_weibo.png')}/>
                        <Text>新浪微博</Text>
                    </TouchableOpacity>
                </View>
            </View>
        )
    }

    render() {
        return (
            <View style={{flex: 1}}>
                <Modal
                    transparent={true}
                    visible={this.state.isVisible}
                    animationType={'fade'}
                    onRequestClose={() => this.closeModal()}>
                    <TouchableOpacity style={styles.container} activeOpacity={1}
                                      onPress={() => this.closeModal()}>
                        {this.renderDialog()}
                    </TouchableOpacity>
                </Modal>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        flexDirection: 'column'
    },
    modalStyle: {
        position: "absolute", // 绝对位置
        top: height - dialogH,
        left: 0,
        width: width,
        height: dialogH,
        backgroundColor: '#ffffff',
    },
    shareModalStyle: {
        flex: 1, 
        flexDirection: 'row', 
        marginTop: 15,
    },
    textStyle: {
        // flex: 1, // 不要随便使用 flex = 1，会产生出莫名其妙的问题
        fontSize: 18,
        margin: 15,
        justifyContent: 'center',
        alignItems: 'center',
        alignSelf: 'center',
    },
    itemStyle: {
        width: width / 3,
        height: itemH,
        alignItems: 'center',
        backgroundColor: '#ffffff',
    },
    imageStyle: {
        width: 60,
        height: 60,
        marginBottom: 8
    },
});

```

## 使用

对于 React Native 的刷新方式，我们是需要提前把此组件添加上，然后是隐藏，通过设置一个 state 来刷新，让其显示

```
<ShareDialog show = {this.state.isShowShareDialog}
	           closeModal = {(show) => {
	               this.setState({
	                    isShowShareDialog: show,
	                })
	            }
	        }>
</ShareDialog>
```

closeModal 这个方法是通过在 ShareDialog.js 里面回调回来刷新 state 让其隐藏。

这样就完成了一个简单的分享组件了。

