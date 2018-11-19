---

title: Xcode10 build和install慢的两个解决方法

date: 2018-11-19 09:46:26

tags: iOS

categories: iOS技术

---

随着 Xcode 的更新和工程项目代码的增加，Xcode 在 build 的时候会显得越来越慢，尤其是在升级到 Xcode 10 之后，通过搜集一些资料与尝试，总结如下两点。

### 将 Debug Information Format 改为 DWARF

	在工程 Project 以及对应 Target 的 Build Settings 中，找到 Debug Information Format 这一项，将 Debug 时的 DWARF with dSYM file 改为DWARF。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Debug-Information-Format.png)

	原因 :
	这一项设置的是是否将调试信息加入到可执行文件中，改为DWARF后，如果程序崩溃，将无法输出崩溃位置对应的函数堆栈，但由于Debug模式下可以在XCode中查看调试信息，所以改为DWARF影响并不大。这一项更改完之后，可以大幅提升编译速度。 亲测这一项改动卓有成效
	

### 将 Build Active Architecture Only 改为 Yes

	在工程对应 Target 的 Build Settings 中，找到 Build Active Architecture Only 这一项，将Debug时的No改为Yes。
	
![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/Build-Active-Architecture-Only.png)

	原因 :
	这一项设置的是是否仅编译当前架构的版本，如果为No，会编译所有架构的版本。需要注意的是，此选项在Release模式下必须为Yes，否则发布的ipa在部分设备上将不能运行。这一项更改完之后，可以显著提高编译速度。
	


