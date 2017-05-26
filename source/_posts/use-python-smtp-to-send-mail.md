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

```
'''using python send gmail'''
# !/usr/bin/env python3
# -*- coding: utf-8 -*-

import smtplib
from email.header import Header
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.utils import parseaddr, formataddr
class SendGmail(object):
    '''send mail via gmail'''
    def __init__(self):
        self._from_addr = input('From:')
        self._password = input('Password:')
        self._to_addr = input('To:')
        self._smtp_server = smtplib.SMTP('smtp.gmail.com', 587)
        self._msg = MIMEMultipart('alternative')
        self._msg['From'] = self._format_addrs('<%s>' % self._from_addr) # 发件人
        self._msg['To'] = self._format_addrs('<%s>' % self._to_addr) # 收件人
        subject = 'hello python'
        self._msg['Subject'] = Header(subject, 'utf-8').encode() # 主题

    def get_content(self, mail_tmp_path='mail.html'):
        '''get mail content'''
        page = mail_tmp_path
        file = open(page, 'r', encoding='utf8')
        content = file.read()
        content = content.replace('<#send_name#>', self._from_addr)
        content = content.replace('<#name#>', self._to_addr)
        self._msg.attach(MIMEText(content, 'html', 'utf-8'))

    def send_mail(self):
        '''send mail'''
        server = self._smtp_server
        server.ehlo()
        server.starttls()
        server.login(self._from_addr, self._password)
        server.sendmail(self._from_addr, [self._to_addr], self._msg.as_string())
        print('success send to %s!' % self._to_addr)
        server.quit()
    @classmethod
    def _replace_tmp(cls, string):
        pass
    @classmethod
    def _format_addrs(cls, string):
        '''format addr'''
        name, addr = parseaddr(string)
        return formataddr((Header(name, 'utf-8').encode(), addr))

if __name__ == '__main__':
    MESSAGE = SendGmail()
    MESSAGE.get_content()
    MESSAGE.send_mail()
```