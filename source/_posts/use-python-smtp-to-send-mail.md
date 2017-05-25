---
title: 使用Python发送HTML邮件
date: 2017-5-26 00:13:29
categories: 积累
tags: [Python, SMTP, mail]
comments: true
---

_这段时间在慢慢学习`Python`，正巧有个与`Python`相关的活，借此机会好练练手_

为什么要学习`Python`呢，作为一个前端，为什么不学习`nodejs`，而选择学习`Python`，对呀，其实我也这么问自己，但是，有什么影响嘛，爱学啥学啥，我不觉得啥该学不该学。学了如果不用，也慢慢会忘。扯远了，其实我是比较喜欢`Python`的语法和它的严格缩进，学了一段时间后，发现还是有和`es6/es7`相似的方法。

## SMTP
`SMTP`是发送邮件的协议，`Python`内置对`SMTP`的支持，可以发送纯文本、HTML邮件。其中有两个用到的模块，`email`负责邮件构造，`smtplib`发送邮件。