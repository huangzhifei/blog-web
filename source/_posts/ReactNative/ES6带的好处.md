---

title: ES6带的好处

date: 2018-05-07 16:31:02

tags: RN

categories: React Native

---

## 解构和属性延伸

使用 ES6 的解构和属性延伸，我们给孩子传递一批属性更加方便了，看下面例子：

把 className 以外的所有属性传递给 CustomView 标签：

```
class AutoloadingPostsGrid extends React.Component {
    render() {
        var {
            className,
            ...others,  // contains all properties of this.props except for className
        } = this.props;
        return (
            <CustomView className={className}>
                <PostsGrid {...others} />
            </CustomView>
        );
    }
}
```

### 解构

解构就是下面这段代码，注意：名字一定要和 props 里面的一样
```
var {
            className,
            ...others,  // contains all properties of this.props except for className
        } = this.props;
```
上面代码就会把 props 里面的 className 解构到 className 上面，把剩下的全解构到 ...others 上面

### 属性延伸

**下面两种写法，就是属性延伸，后面的优先级高于前面的，就会出现合并或覆盖：**

```
<CustomView {...this.props} className="Test">
    …
</CustomView>
```
传递所有属性，如果属性里面有className，会被后面的覆盖，没有就不用管。



```
<CustomView className="Test" {...this.props} >
    …
</CustomView>
```
传递所有属性，如果属性里面有className，则被传递过来的覆盖，没有就不用管。


