title: 删除 node_modules 不成功
date: 2015-11-23 19:11:31
tags: nodejs
categories: 积累
comments: true

---

## Question

> `Windows`做`Node.js`开发的你或许碰到过无法删除`node_modules`文件夹的情况,如下图：

<!-- more -->

![failed](/images/failed.png)

## Reason

`windows` 在文件目录的长度有限制，因为`node packages` 有众多`dependencies`，每一个`dependency`又有其他的`dependency`，这些`dependency`或许还有其他的`dependency`，所以导致`node_modules`有超级复杂的文件目录。比如：

```bash
D:\codetest\node_modules\edpx-mobile\node_modules\edp-webserver\node_modules\babel\node_modules\chokidar\node_modules\anymatch\node_modules
```

## Solution

### install

```bash
npm install -g rimraf
```

### delete

```bash
rimraf node_modules
```

_亲测有效_
