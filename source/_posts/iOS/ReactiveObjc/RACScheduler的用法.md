---

title: RACScheduler的用法

date: 2019-03-17 23:28:48

tags: RAC

categories: RAC

---


`RACScheduler` 是一个线性执行队列，`ReactiveCocoa` 中的信号可以在 `RACScheduler` 上执行任务、发送结果；它的实现并不复杂，由多个简单的方法和类组成整个 `RACScheduler` 模块，是整个 `ReactiveCocoa` 中非常易于理解的部分。

## RACScheduler 简介

