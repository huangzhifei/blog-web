---

title: iOS之启动图的名字

date: 2017-11-19 14:35:24

tags: iOS

categories: iOS技术

---

新出了 iPhoneX 后，我们需要适配，首先就要适配启动图，不然连正确的 size 都无法获取。

那么在哪里可以看到各个设备的启动图名字了？

## 方法一

我们可以打印出来 mainBundle 的路径，比如通过 [NSBundle mainBundle]，这个路径下面就会有所有的不同尺寸设备的启动图。

## 方法二

我们直接在工程目录 Products 下面找到我们的 .app 在 Finder 中打开，右健显示包内容，里面就会有列出所有的启动图片名字。

## 方法三

我们直接在 Info.plist 中添加 UILaunchImages 键值内容：

```
<key>UILaunchImages</key>
<array>
    <dict>
        <key>UILaunchImageMinimumOSVersion</key>
        <string>8.0</string>
        <key>UILaunchImageName</key>
        <string>Default-736h</string>
        <key>UILaunchImageOrientation</key>
        <string>Portrait</string>
        <key>UILaunchImageSize</key>
        <string>{414, 736}</string>
    </dict>
    <dict>
        <key>UILaunchImageMinimumOSVersion</key>
        <string>8.0</string>
        <key>UILaunchImageName</key>
        <string>Default-667h</string>
        <key>UILaunchImageOrientation</key>
        <string>Portrait</string>
        <key>UILaunchImageSize</key>
        <string>{375, 667}</string>
    </dict>
    <dict>
        <key>UILaunchImageMinimumOSVersion</key>
        <string>7.0</string>
        <key>UILaunchImageName</key>
        <string>Default</string>
        <key>UILaunchImageOrientation</key>
        <string>Portrait</string>
        <key>UILaunchImageSize</key>
        <string>{320, 480}</string>
    </dict>
    <dict>
        <key>UILaunchImageMinimumOSVersion</key>
        <string>7.0</string>
        <key>UILaunchImageName</key>
        <string>Default-568h</string>
        <key>UILaunchImageOrientation</key>
        <string>Portrait</string>
        <key>UILaunchImageSize</key>
        <string>{320, 568}</string>
    </dict>
    <dict>
        <key>UILaunchImageMinimumOSVersion</key>
        <string>8.0</string>
        <key>UILaunchImageName</key>
        <string>Default-812h</string>
        <key>UILaunchImageOrientation</key>
        <string>Portrait</string>
        <key>UILaunchImageSize</key>
        <string>{375, 812}</string>
    </dict>
</array>
```

这样我们以后就可以直接修改这里的名字就好了。

