---

title: hexo-github之阿里域名

date: 2018-01-29 10:49:05

tags: hexo+github

categories: hexo配置

---

## 绑定阿里云域名

去阿里云买个域名，可以直接使用，不需要等域名备案完成。

### 1、添加 CNAME 文件

在根目录下的Source目录新建 CNAME 文件，注意不要有任何后缀。(一定要在此目录下面创建，这样部署后会到远端生效)

然后在里面添加你的域名信息，如下图：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/yunming.png)


保存之后，重新部署到 github pages 上面。

### 2、给域名添加解析记录

#### 1、ping 你自己的 yourname.github.io 获取 ip 地址：

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/pingpage.png)

#### 2、在阿里的域名解析列表，添加两条解析记录

添加的解析配置基本是即时生效，如果是修改已经启动的解析，可能需要0 ~ 48小时，因为在缓存。

![](https://github.com/huangzhifei/blog-web/raw/master/source/_posts/images/aliyunDNS.png)

### 3、配置完成

现在可以去用你的域名访问原来的 github pages 了。

