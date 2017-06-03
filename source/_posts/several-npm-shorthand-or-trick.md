---
title: 8个npm常用技巧和简写
date: 2017-6-3 17:17:15
categories: 积累
tags: npm
comments: true
---
在篇文章里,将介绍一些非常有用的npm技巧。在这有许多我们不能完全覆盖,所以主要介绍和我们开发工作最相关和最有用的技巧。

## 最基本的一些简写
为了大家在同一起跑线，特别是针对于我们的新手，下面先快速的复习一些基本的简写来保证没人忘记任何简单的东西。
#### 安装package
常规：`npm install pkg` 简写：`npm i pkg`
#### 全局安装
常规： `npm install --global pkg` 简写：`npm i -g pkg`
#### 作为项目依赖
常规：`npm install --save pkg` 简写： `npm i -S pkg`
#### 作为开发依赖
常规： `npm install --save-dev pkg` 简写： `npm i -D pkg`

_更多的简写请查看npm的[简写表](https://docs.npmjs.com/misc/config#shorthands-and-other-cli-niceties)_
接下来开始有趣的东西。
### 初始化一个package
我们都知道使用`npm init`，这是我们创建一个`package`需要做的第一步。但是，在默认情况下，我们会不停的敲`enter`键，所以我们怎么避免呢。
`npm init -y` 或 `npm init -f`就可以一次搞定。
### 测试命令
另一个我们都会的命令是`npm test`，基本上每天都会使用很多次。倘若我告诉你减少约`40%`的字符后可以做同样的事呢？非常幸运，这里有个命令`npm t`，确实能够做到。
### 列举可用的脚本
我们得到了一个新项目,不知道如何开始。通常想知道：如何运行它?哪些脚本可用?
有一种方式是打开`package.json`文件，查看`scripts`部分。但是我们可以做的更好，所以我们可以简单的运行`npm run`，之后就可以获得可用脚本的列表。
另一个方式是安装`ntl`(`npm i -g ntl`)，然后在项目根目录运行`ntl`，就会列举出可用脚本，并可以直接选择运行，非常方便。
### 列举已安装的packages
类似于可用的脚本,有时候我们需要知道在我们的项目的依赖关系。再次的，我们可以打开`package.json`文件查看。但是我们已经知道我们可以做的更好，那就是
`npm ls --depth 0`
如果需要列出全局安装的`packages`，我们运行同样的命令加上`-g`标志。
`npm ls -g --depth 0`
### 运行安装的可执行文件
我们安装了一个包在我们的项目中,它带有一个可执行的文件,但只有通过`npm`脚本运行它。你想知道为什么,或者如何克服它吗?
首先，我们理解为什么--当我们在我们终端执行命令的时候，其根本其实是在我们`PATH`环境变量中列举的路径中寻找同名的可执行文件。这就是他们可从任何地方访问的神奇之处。本地安装包在本地注册他们的可执行文件,所以他们没有列在我们的`PATH`中，也就不会被发现。
当我们通过一个npm脚本运行可执行文件，它是如何工作的？好问题！因为这种方式运行时,是`npm`的一个小技巧,增加了一个额外的文件夹路径`<project-directory>/node_modules/.bin`到`PATH`，
`npm`添加了一些更有趣的东西，你可以通过运行`npm run env | grep "$PATH"`看见它。你也可以只是运行`npm run env`来查看所有可用的环境变量。
如果你想知道，`node_modules/.bin`巧好是本地安装包存放他们可执行文件的地方。
例如，如果在你的项目中安装了`mocha`，直接在项目中运行`./node_modules/.bin/mocha`看有什么动作
so easy,对吧？无论何时你想运行一个本地安装包的可执行文件，只需要运行`./node_modules/.bin/<command>`
### 在网上找你的package
在`package.json`文件中，你可能会看到`repository`的入口('entry')，想知道它有什么好处呢？
要回答这个问题，只需要运行`npm repo`就可以在你的浏览器中看到。
顺便说一下,`npm home`命令和`npm homepage`同样适用,
如果你想在[npmjs](https://www.npmjs.com/)打开你的`package`，这里也有个不错的简写`npm docs`
### 在其他脚本前后运行脚本
也许你熟悉某些脚本例如`pretest`,这个允许你定义在`test`脚本运行前运行的代码。
你可能会惊讶地发现,你可以为每一个脚本增加预先和滞后执行的脚本,包括您自己的自定义脚本!
对于使用`npm`作为构建工具和有很多脚本需要编排的项目来说，是非常有用的。
### 更换package的版本
你有一个`package`，也许使用[semver](http://semver.org/)做版本控制，在一个新版本发布前需要更换版本。
一种方式是打开`package.json`文件手动的改变版本，但在这里我们不这样。
一个简单的方式是运行`npm version`加上`major`、`minor`或者`patch`。
That's all

## 最后
另外值得一提的是一些组合命令，如`npm it`将会运行安装和测试命令，等同于`npm install && npm test`,非常方便。
如果你知道更多的有用的技巧,请在评论中分享一下吧!

## reference
[8-npm-tricks-you-can-use-to-impress-your-colleagues](https://medium.freecodecamp.com/8-npm-tricks-you-can-use-to-impress-your-colleagues-dbdae1ef5f9e)
[shorthands-and-other-cli-niceties](https://docs.npmjs.com/misc/config#shorthands-and-other-cli-niceties)