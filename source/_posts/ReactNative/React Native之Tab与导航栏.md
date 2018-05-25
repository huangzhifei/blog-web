---

title: React Native之Tab与导航栏

date: 2018-05-24 17:52:54

tags: RN

categories: React Native

---

我们使用 react-navigation 这个目前很流行的三方库，下面我们介绍他提供的 TabNavigator + StackNavigator 来实现界面跳转、Tab的切换。

## 安装

通过命令安装：

```
npm install --save react-navigation
```

## 使用

### 创建 MainTab.js 用来自定义 TabNavigator（类似于iOS中的Tab）

```
import React from 'react';
import {
    StyleSheet,
    Image,
    Platform
} from 'react-native';

import {TabNavigator} from "react-navigation";
import Tab1Page from './Tab1';
import Tab2Page from './Tab2';
import Tab3Page from './Tab3';
import HomePage from './HomePage';

export const MainNavigator = TabNavigator({
    Home: {
        screen: HomePage,
        navigationOptions: {
            title: '首页',
            tabBarLabel: 'Home',
            tabBarIcon: ({tintColor}) => (
                <Image
                    source={require('../Res/images/ic_forbag_normal@2x.png')}
                    style={[{tintColor: tintColor}, styles.icon]}
                />),
        }
    },
    Tab1: {
        screen: Tab1Page,
        navigationOptions: {//配置TabNavigator的一些属性
            title: 'Tab1',//标题，会同时设置导航条和标签栏的title 
            tabBarLabel: 'Tab1',//标签栏的title，这里设置的与标题一样，如不一样时可进行设置
            //设置标签栏的图标
            tabBarIcon: ({tintColor}) => (
                <Image
                    source={require('../Res/images/ic_account_normal@2x.png')}
                    style={[{tintColor: tintColor}, styles.icon]}
                />),
        }
    },
    Tab2: {
        screen: Tab2Page,
        navigationOptions: {
            title: 'Tab2',
            tabBarLabel: 'Tab2',
            tabBarIcon: ({tintColor}) => (
                <Image
                    source={require('../Res/images/ic_discover_normal@2x.png')}
                    style={[{tintColor: tintColor}, styles.icon]}
                />),
            //header: null,//设置无导航栏（也就是无顶部标题栏）
        },
    },
    Tab3: {
        screen: Tab3Page,
        navigationOptions: {
            title: 'Tab3',
            tabBarLabel: 'Tab3',
            tabBarIcon: ({tintColor}) => (
                <Image
                    source={require('../Res/images/ic_forbag_normal@2x.png')}
                    style={[{tintColor: tintColor}, styles.icon]}
                />),
        }
    },
}, {
    animationEnabled: false, // 切换页面时不显示动画
    tabBarPosition: 'bottom', // 显示在底端，android 默认是显示在页面顶端的
    swipeEnabled: false, // 禁止左右滑动
    backBehavior: 'none', // 按 back 键是否跳转到第一个 Tab， none 为不跳转
    tabBarOptions: {//配置标签栏的一些属性
        activeTintColor: '#e91e63',// 文字和图片选中颜色
        inactiveTintColor: '#999', // 文字和图片默认颜色
        showIcon: true, // android 默认不显示 icon, 需要设置为 true 才会显示
        indicatorStyle: {height: 0}, // android 中TabBar下面会显示一条线，高度设为 0 后就不显示线了 暂时解决这个问题  
        style: {
            backgroundColor: '#F5FCFF', // TabBar 背景色
            paddingBottom:0,
        },
        labelStyle: {
            fontSize: 12, // 文字大小
        },

    },
});

const styles = StyleSheet.create({
    icon: {
        height: 22,
        width: 22,
        resizeMode: 'contain'
    }
});
```

### 创建 AppIndex.js 来自定义 StackNavigator（类似于iOS中的Navigator）

```
import React from 'react';
import {StackNavigator} from "react-navigation";
import {MainNavigator} from './MainTabPage';
import TestPage from './TestPage';
import Discover from './Discover';
import StyleDelivery from './StyleDelivery';
import VideoPlay from './VideoPlay';
import ImagePlaceHolder from './ImagePlaceHolder';
import TextInputPage from './TextInputPage';

export const AppIndex = StackNavigator(
    {
        Home: {
            screen: MainNavigator,
            navigationOptions: {
                headerStyle: {
                    backgroundColor: '#e91e63',
                },
                headerTitleStyle: {
                    color: 'white',
                    alignSelf: 'center',
                },
                headerTintColor: 'white', // 修改返回按钮箭头的颜色
            },
        },
        Test: {
            screen: TestPage,
            navigationOptions: {
                title: 'TestPage',
                headerStyle: {
                    //导航条的样式。背景色，宽高等  
                    backgroundColor: '#e91e63',//背景色
                },
                headerTitleStyle: {
                    //导航栏文字样式
                    color: 'white',
                    alignSelf: 'center',
                },
                // headerBackTitleStyle: {
                //     color: 'white',
                // },
                headerTintColor: 'white',
            },
        },
        VideoPlay: {
            screen: VideoPlay,
            navigationOptions: ({navigation}) => ({
                title: '视频播放',
                headerStyle: {
                    backgroundColor: '#e91e63',
                },
                headerTitleStyle: {
                    color: 'white',
                    alignSelf: 'center',
                },
                headerStyle: {
                    backgroundColor: '#e91e63',
                },
                headerTitleStyle: {
                    color: 'white',
                    alignSelf: 'center',
                },
                headerTintColor: 'white',
            }),
        },
        ImagePlaceHolder: {
            screen: ImagePlaceHolder,
            navigationOptions: ({navigation}) => ({
                title: '占位图片',
                headerStyle: {
                    backgroundColor: '#e91e63',
                },
                headerTitleStyle: {
                    color: 'white',
                    alignSelf: 'center',
                },
                headerTintColor: 'white',
            }),
        },
        TextInputPage: {
            screen: TextInputPage,
            navigationOptions: ({navigation}) => ({
                title: '输入框',
                headerStyle: {//导航条的样式。背景色，宽高等  
                    backgroundColor: '#e91e63',//背景色
                },
                headerTitleStyle: {//导航栏文字样式
                    color: 'white',
                    alignSelf: 'center',
                },
                headerTintColor: 'white', // 修改返回按钮箭头的颜色
            }),
        }
    }, 
    {
        headerMode: 'float',// headerMode返回上级页面时动画效果
                            // float：iOS默认的效果
                            // screen：滑动过程中，整个页面都会返回
                            // none：无动画
    }
);
```

### 配置入口

做完上面操作后，我们需要在 index.ios.js 和 index.android.js 里面配置启动初始化界面

```

import {
    AppRegistry,
} from 'react-native'

import {AppIndex} from './JS/AppIndexPage';

AppRegistry.registerComponent('RNBaseModule', () => AppIndex);

```

### 分析

对于 iOS 中 Tab + Nav 这样的组合，初始化顺序是：先初始化几个 Nav（里面嵌了各个主页面），然后把这初始化的几个 Nav 在添加分配到 Tab 上面，这样每个 Tab 控制一个根 Nav，每个根 Nav 下面就可以控制跳转了。

但是我们看上面的初始化和配置入口：

1、在 AppIndex 里面 Home 的 screen 给的是 MainNavigator（MainNavigator就包含了4个Tab）

2、配置入口里面配置是 AppIndex，那配置的是 Nav

这和上面我说的 iOS 的标准流程是反的，我不知道按 iOS 的配置行不行，没有试过。

## API 分析

### TabNavigator 

他有一个创建方法 TabNavigator(NavigationRouteConfigMap,TabNavigatorConfig)，我们可以通过此函数创建和导出我们需要的。

### 下面来看看 **TabNavigatorConfig** 的属性

#### 1、screen

对应界面名称，需要填入 import 之后的页面。

#### 2、tabBarPosition

设置 tabbar 的位置，iOS 默认在底部，安卓默认在顶部（"top", "bottom"）

#### 3、swipeEnabled

是否允许在标签之间进行滑动

#### 4、animationEnabled

是否在更改标签时显示动画

#### 5、lazy

是否根据需要懒呈面标签，即 app 打开的时候将底部标签全部加载完，默认是 false，推荐 true

#### **6、tabBarOptions**

配置标签栏的一些属性

1、activeTintColor: 设置文字和图片选中颜色（前景色）

2、activeBackgroundColor: 设置文字和图片选中的背景色

3、inactiveTintColor: 设置文字和图片默认颜色（前景色）

4、inactiveBackgroundColor: 设置文字和图片默认的背景色

5、showLabel: 是否显示label，默认开启

6、style: tabbar 的样式

7、labelStyle: label 的样式

8、tabStyle: tab 的样式

9、showIcon: android 默认不显示 icon，需要设置为 true 才会显示

10、upperCaseLabel: 是否使标签大写，默认为 true

11、pressColor: material涟漪效果的颜色（android需要大于5.0）

12、pressOpacity: 按压标签的透明度变化（android需要大于5.0）

13、scrollEnabled: 是否启用可滚动选项卡

14、indicatorStyle: 标签指示器的样式对象（选项卡底部行），android底部会多出一条线，可以将height设置为0来临时解决这个问题

15、iconStyle: 图标样式

### 下面来看看 **NavigationRouteConfigMap** 的属性

#### navigationOptions

1、title: 标题，会同时设置导航栏和标签栏的title

2、tabBarVisible: 是否隐藏标签栏，默认不隐藏（true）

3、tabBarIcon: 设置标签栏的图片，需要每个都设置

4、tabBarLabel: 设置标签栏的title

### StackNavigator

他和 TabNav 一样有相同的函数创建

### StackNavigatorConfig

#### 1、screen: 

对应界面名称，需要填入import之后的页面

#### 2、initialRouteName

设置默认的页面组件，必须是上面已经import过的

#### 3、initialRouteParams

初始路由参数

#### 4、navigationOptions

配置一些基本属性

#### 5、paths

据说是类似于 deep link 的功能，目前尝试没有成功过

#### 6、mode

定义跳转风格:

card: 使用 iOS 和 android 默认的风格

modal: iOS 独有的屏幕底部动画，类似于 present 效果

#### 7、headerMode

返回上级页面时动画效果

float: iOS 默认的效果

screen: 滑动返回，整个页面都会返回

none：无动画，导航栏都隐藏了


#### 8、cardStyle

自定义设置跳转效果

#### 9、transitionConfig

自定义设置滑动返回的配置

#### 10、onTransitionStart

当转换动画即将开始时被调用的功能

#### 11、onTransitionEnd

当转换动画完成，将被调用的功能

### navigationOptions

#### 1、title

标题，如果设置了这个导航栏和标签栏的title就会变成一样的，不推荐使用

#### 2、header

可以设置一些导航的属性，如果隐藏顶部导航栏只要将这个属性设置为 null

#### 3、headerTitle

设置导航栏标题

#### 4、headerBackTitle

设置跳转页面左侧返回箭头后面的文字，默认是上一个页面的标题。可以自定义，也可以设置为 null

#### 5、headerTruncatedBackTitle

设置当上个页面标题不符合返回箭头后的文字时，默认改成"返回" 

#### 6、headerRight

设置导航条右侧。可以是按钮或者其他视图控件

#### 7、headerLeft

设置导航条左侧。可以是按钮或者其他视图控件

#### 8、headerStyle

设置导航条的样式。背景色，宽高等

#### 9、headerTitleStyle

设置导航栏文字样式

#### 10、headerBackTitleStyle

设置导航栏‘返回’文字样式

#### 11、headerTintColor

设置导航栏颜色

#### 12、gesturesEnabled

是否支持滑动返回手势，iOS默认支持，安卓默认关闭

## 界面跳转（传值和取值）

在界面组件注入  StackNavigator 中时，界面组件就被赋予了 navigation 这个属性，即在界面组件中可以通过 this.props.navigation 获取并进行一些操作。

### 1、通过 navigate 实现页面跳转

```
this.props.navigation.navigate('Test')
```

其中 'Test' 是我们注入的界面组件的名称（不是screen）

### 2、返回上一页

```
this.props.navigation.goBack()
```

### 3、传值

```
this.props.navigation.navigate('Test', {user: 'xxx', name: 'yyy'})
```

### 4、取值

```
this.props.navigation.state.params.user
this.props.navigation.state.params.name
```

## 总结

我们发现导航栏要跳转的页面，都需要提前注册好，万一我们想动态跳转怎么办?

我也不知道，还在研究中~~~~~~~~


***待更新......***

