---

title: websocket初识

date: 2018-03-20 09:05:52

tags: socket

categories: websocket

---

## 介绍

WebSocket 是一种在单个 TCP 连接上进行的全双工通讯协议（摘自wiki），他的存在使客户端和服务器之间的数据交换变得更加简单，允许服务端主动向客户端推送数据。

在 WebSocket API 中，浏览器和服务器只需要完成一次握手，两者之间就可以创建持久性的连接，并进行双向数据传输。

## 背景

现在，很多网站为了实现推送技术，所用的技术都是轮询（polling），轮询是在特定的的时间间隔（如每1秒），由浏览器对服务器发出 HTTP 请求，然后由服务器返回最新的数据给客户端的浏览器。这种传统的模式带来很明显的缺点，即浏览器需要不断的向服务器发出请求，然而 HTTP 请求可能包含较长的头部，其中真正有效的数据可能只是很小的一部分，显然这样会浪费很多的带宽等资源。

在这种情况下，HTML5 定义了 WebSocket 协议，能更好的节省服务器资源和带宽，并且能够更实时地进行通讯。

Websocket 使用 ws 或 wss 的统一资源标志符，类似于 HTTPS，其中 wss 表示在 TLS 之上的 Websocket 如：
```
ws://example.com
wss://example.com
```

Websocket 使用和 HTTP 相同的 TCP 端口，可以绕过大多数防火墙的限制，默认情况下，Websocket 协议使用 80 端口；运行在TLS之上时，默认使用443端口。

## 优点

1、较少的控制开销，在连接创建后，服务器与客户端交换数据时，所携带的头部信息很少，不像 http 每次请求都要携带完整的头部；

2、更强的实时性，由于协议是全双工的，所以服务器可以随时主动给客户端下发数据，对于 http 需要客户端不停的发起请求，去轮询；

3、保持连接状态，和 http 不同的是：websocket 需要先创建连接，这就使得其成为一种有状态的协议，后续通信就可以省略部分状态信息，但是 http 的每一个请求可能都需要携带状态信息（例如：身份认证等）；

4、更好的二进制支持，websocket定义了二进制帧，相对 http，可以更轻松的处理二进制内容；

## 握手协议

websocket 是独立、创建在 tcp 上的协议，他是通过 HTTP/1.1 协议的101状态码进行握手的，握手成功后就和 http 没有关系了，会变成一个持久的连接了。


## 客户端的简单示例

看如下代码：

```
var ws = new WebSocket("wss://localhost:8080");     (1)

ws.onopen = function(evt) {                         (2)
  console.log("Connection open ..."); 
  ws.send("Hello WebSockets!");
};

ws.onmessage = function(evt) {                       (3)
  console.log( "Received Message: " + evt.data);
  if(typeof event.data === String) {
    console.log("Received data string");
  }

  if(event.data instanceof ArrayBuffer){
    var buffer = event.data;
    console.log("Received arraybuffer");
  }
};

ws.onclose = function(evt) {                          (4)
  console.log("Connection closed.");
};      

ws.send('your message');                              (5)
```

(1) 创建一个 websocket 实例，客户端和服务器进行连接。

(2) 连接成功后的回调

(3) 收到服务器数据后的回调函数，注意：服务器数据可能是文本，也可能是二进制数据（blob对象或Arraybuffer对象）

(4) 关闭连接后回调函数

(5) 给后台发送数据（文本、blob、Arraybuffer）



