---
title: 使用Travis CI自动部署Hexo博客到Github上
date: 2017-05-04 23:27:53
categories: 积累
tags: hexo
comments: true
---
## 写在前面
自从在`github page`上搭建博客以来，都是使用的[hexo](http://hexo.io/)，每次都是通过`hexo`命令`build`生成静态文件，再`push`到`github`上，后来找到一个[deploy](https://github.com/hexojs/hexo-deployer-git)插件，只需要填写好`github`的`repos`地址就好。但是源码的保存是个问题，更换电脑想要写博客很不方便，甚至蠢到将源码保存到u盘里面，这样每次提交后又要备份一次，很容易忘记。说到这里那为什么不将源码保存到`github`上呢。

其实也是因为懒，给博客换了几次主题后，使得博客源码很乱，甚至自己也忘了改了主题的哪些代码，加上主题也是个`repos`，直接提交博客源码是提不上的，涉及到子模块问题，麻烦。想到自己还喜欢改动别人的主题，索性将主题文件夹`.git`文件删掉，让他成为一个普通的文件夹，这样就能提交到`github`了。废话不多说，估计是很久没写博客了，没有重点，下面简单说说使用`Travis CI`自动部署`Hexo`博客到`github`上。

## 什么是Travis CI？
> `Travis CI` 是目前新兴的开源持续集成构建项目，它与`jenkins`，`GO`的很明显的特别在于采用`yaml`格式，简洁清新独树一帜。目前大多数的github项目都已经移入到`Travis CI`的构建队列中，据说`Travis CI`每天运行超过`4000`次完整构建。

## 构建
首先进入[Travis CI](https://travis-ci.org/)官网，使用`github`账号登录，如下图
![travis](http://7xjp74.com1.z0.glb.clouddn.com/travis.png)
登录成功后进入如下界面，以为我再此之前已经构建过，所以会用红色框内的内容，如果没有使用过是没有的。
![list](http://7xjp74.com1.z0.glb.clouddn.com/list.png)
然后点击`My Repositories`右边的`+`，添加需要自动构建的`repos`，进入如下页面。
![new](http://7xjp74.com1.z0.glb.clouddn.com/new.png)
可以看到这个界面会显示当前`github`账号的所以项目，如果没有显示，点击右上角的`Sync account`按钮，就可以同步过来了，点击需要构建的`repos`前面的按钮为`ON`，再点击其后的原形设置图标，进入如下界面
![config](http://7xjp74.com1.z0.glb.clouddn.com/config.png)
如图中设置，将`Build only if .travis.yml is present`及另外两个设置为`ON`，功能如字面意思不多说。
到目前为止，已经将需要构建的`repos`开启，那么，我们如何在将源码提交到`github`的时候，它就自动构建并将`build`后的静态文件`push`到我的静态文件`branch`或者`repos`呢（我是将`build`后的静态文件放到一个单独的`repos`了，也可以放在源码`repos`的另一个`branch`，例如起名叫`hexo`），接下来说如何让`Travis CI`访问`github`.

## Access Token
我们需要在`Travis`上配置`Access Token`，就可以在构建完毕后自动`push`到`github`上保存静态文件的`repos`了。
### 生成Access Token
登录[github](https://github.com/)，进入个人主页，点击`setting`，进入界面后找到下图所指位置。
![token](http://7xjp74.com1.z0.glb.clouddn.com/token.png)
点击`Personal access tokens`，进入页面后，在点击右上角`Generate new token`,会再次让输入`github`密码，然后在`Token description`下起一个名字，再勾选一些权限，我是全给勾选上了，在点击下面`Generate token`这里就不多截图了。复制生成的`token`码。
### 配置Travis CI
回到`Travis`的`setting`页面，如上面图，在`Environment Variables`这一栏，点击`Add`，起一个名字到`Name`，将复制的`token`码粘贴到`Value`框中，到这步为止，已经完成了`Travis`的设置。到博客源码根目录，创建一个`.travis.yml`的配置文件，内容如下，附注释，注意缩进
```
language: node_js  #设置语言

node_js: stable  #设置相应的版本

install:
  - npm install  #安装hexo及插件

script:
  - hexo clean  #清除
  - hexo g  #生成

after_script:
  - cd ./public
  - git init
  - git config user.name "swust-xiaoj"  #修改name
  - git config user.email "swustxiaojie@163.com"  #修改email
  - git add .
  - git commit -m "update site"
  - git push --force  "https://${travis}@${GH_REF}" master:master  #travis是在Travis中配置token的名称

branches:
  only:
    - master  #只监测master，可根据自己情况设置，若是存放同一个仓库，这儿可以选择存放源码的branch，如hexo
env:
 global:
   - GH_REF: github.com/swust-xiaoj/tb.git  #设置GH_REF，注意更改yourname
```
因为我是新起了一个`repos`来存放静态文件了，所以上面的`GH_REF`是对应那个`repos`地址，若是放同一个`repos`中，那这儿一般都是`yourname.github.io`那个仓库。到此，配置已经完成了。

### 创建文章
我们可以创建一篇文章`hexo new post use-travis-build-your-hexo-site`，添加内容后，并`push`到`github`，正常情况下，进入`Travis`网站就可以看到已经在构建了，如图
![success](http://7xjp74.com1.z0.glb.clouddn.com/success.png)
完成后，[访问链接](http://dearxiaojie.xyz/tb/2017-05-04/use-travisci-build-your-hexo-site.html)就可以看到这篇文章了。

## 写在后面
很久没有花时间写点东西了，不管有没有价值，总是一种对知识的积累和总结，输出也意味着输入，所以以后还是将学到的东西和积累总结下，自己可以将知识梳理的同时能帮助到别人是更好的了。
