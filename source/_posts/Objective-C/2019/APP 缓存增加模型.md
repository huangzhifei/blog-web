---

title: APP 缓存增加模型

date: 2019-05-17 14:41:06

tags: iOS

categories: 持久化缓存

---


# APP 持久化缓存增量更新方案

客户端和服务端的数据同步过程中，客户端有缓存，不需要每次都是全量刷新，所以可以采用增量的方式更新。

每次在客户端进行刷新的时候，服务端会将最新的增删改操作推送到客户端，客户端对其缓存进行操作，以保持数据的同步。

## 一、最原始的全理更新

略......

## 二、根据修改时间来拉取增、删、改信息 Timestamp Transfer + 透传通知更新（App 启动后的长连接，push 不靠谱）


客户端存储上次拉取的数据的 Timestamp，在请求更新数据时，携带该 Timestamp 作为本地数据版本信息。数据库内每行数据设置一个 LAST_UPDATE_TIME 字段，服务器将比该时间更新的数据返回给客户端。

**优点：**

**1、相对于全量来说减少了冗余数据的传输**

**缺点：**

**1、传输时 Timestamp 作为版本信息需要精确控制，请求错误的版本号可能带来本地数据的不准确。**

**2、已经删除的数据其实已经不存在了，取不到 LAST_UPDATE_TIME**

**3、要注意删除的记录不能物理删除，防止其他端同步不到这条数据**

**场景：**

通讯录：
1、app 上没有任何缓存记录，那么可以一次全量同步，或者分批多次同步
2、app 上有缓存，有一段时间没有使用app，不能确定缓存是否为最新，需要增量同步
3、app 使用频率相对高，正常增量同步

在上述三个场景中，最麻烦的就是场景2，因为可能出现 server 在 app 不使用的时间内对通讯录中的信息进行了 CRUD（增、读、更、删）操作。

**下面我们使用 updateTime 和 isDeleted 来分析**

为了应付场景2，通常采用增量更新的手段，即每条数据都加上 update_time 字段，来确认哪些数据是在 app 不使用时间或其他端更改生成的，每次 app 收到类似于透传通知，或人为主动拉取的时候，发送本地最新的更新时间戳（版本)，server 返回比这个要新的所有内容（增量），以 CRUD 分步说明：

1、对于C（新增create）：如果server向数据库中通讯录添加一条数据，且该数据的 update_time 为server 当前时间，这条记录 app 在同步的时候，就会获得。
2、对于R（读取read）：无任何影响
3、对于U（更新update）：server或其他端修改通讯录条目的时候，也会修改update_time为入库时间，这样子，app在同步的时候，server就知道返回哪些数据给 app 了。
4、对于D（删除delete）：服务端不能物理删除记录，只能增加标记位is_delete，不然app本地的缓存永远不知道这条数据被删除了。

些方案主要依赖 update_time 的精确度，透传通知是用来增加时效性的。

## 三、增删改日志 - SYNC

服务端记录数据的每次操作都记录进一个增量数据库，数据库内记录了每条操作的对象 ID 和操作的内容。此处思想类似于 Patch 补丁操作，客户端发送一个 Timestamp 信息，服务器将这个时间以后的所有增删改操作返回给客户端，客户端再进行打补丁操作，使得最终结果与服务端同步。

**优点：**

**1、保持了所有数据的精确可同步**

**缺点：**

**1、客户端很久不更新以后单次的更新补丁很大**

**2、如果数据改动很多，那记录操作的表将会变得很大**


**参考文章：**[https://my.oschina.net/shinedev/blog/506739]() **注意看文章最后的评论，精华都在评论**