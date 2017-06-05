---
title: 在浏览器中懒加载ES2015模块
date: 2017-6-5 19:51:28
categories: 翻译
tags: [ES2015]
comments: true
---

ES2015模块在浏览器懒加载

在过去的几年里，开发者们已经无情的将服务端网站移动到了客户端，前提是那样能使页面的性能得到提高。

然而，这可能是不够的。你是否考虑过你的网站也许加载更多于它实际用到的东西？遇到懒加载，一个延迟初始化（加载/分配）某个资源(代码/数据/静态资源)直到它需要的时候再加载。

与此同时，`ES2015`已经能在生产环境中使用了，通过一些`transpilers`如`Babel`。现在你不用参与到使用`AMD`还是`CommonJS`的战争中，参照这篇文章的描述（[The mind-boggling universe of JavaScript Module strategies](https://www.airpair.com/javascript/posts/the-mind-boggling-universe-of-javascript-modules)）,因为你可以写`ES2015`模块和让他们transpiled并交付给浏览器同时支持现有`CommonJS`或`AMD`模块。

在这篇文章中，我将讨论如何使用[System.js](https://github.com/systemjs/systemjs)同步(在页面加载的时候)和异步(懒加载)加载`ES2015`模块。

## 页面加载 vs 懒加载
在浏览器上开发`JavaScript`代码执行时,你必须决定什么时候你让它执行。
有一些代码必须在页面加载的同时就执行，比如SPA应用使用了一些框架如`Angular`，`Ember`，`Backbone`，或者`React`，这些代码可能通过一个或多个`<script>`标签，必须在一个页面请求返回到浏览器后被引用到`HTML`文档的主体结构中。

在另一方面，你可能有更多的代码块在一些特定的触发条件发生的时候在执行。经典的例子如：

 * 内容折叠。比如一个评论面板，在用户滚动到页底的时候才显示
 * 事件触发内容显示。比如一个放大的覆盖层，在用户点击图片的时候在显示
 * 少数内容。比如一个‘免运费’的控件，只只用于一些小的页面上
 * 有时间间隔的内容显示。比如一个客服聊天框
 
这样的话，对于给出一个类似上面的功能，如果他的触发条件未发生，他的代码块就永远不会被执行。因此，那个代码块在页面加载的时候明显是不需要的，是可以延迟加载的。

为了延迟加载，你只需要将在页面加载期间执行的代码从代码块中提取出来。这样在他的触发条件第一次发生的时候就被执行。

这种异步加载引用代码的方式，或者叫懒加载，在提升页面性能上扮演了一个重要的角色，从减少页面首屏时间和速度指数上来看的话。

为了学习更多关于对比页面加载和懒加载对页面性和速度指数的影响的知识，可以阅读这篇文章[ Leveling up: Simple steps to optimize the Critical Rendering Path](https://www.airpair.com/javascript/posts/the-tipping-point-of-clientside-performance)

## AMD陷阱

AMD标准是为在浏览器上异步加载加载创造的，是第一个作为全局`JavaScript`文件散落在页面的成功替代品。根据[Require.js文档](http://requirejs.org/docs/whyamd.html#amd):
> The AMD format comes from wanting a module format that was better than today’s “write a bunch of script tags with implicit dependencies that you have to manually order” and something that was easy to use directly in the browser.

它是基于模块设计模式[Module Design Pattern](http://addyosmani.com/resources/essentialjsdesignpatterns/book/#modulepatternjavascript)的授权，有一个模块加载器，依赖注入和异步能力。它的一个主要的作用就是执行模块的懒加载。

尽管是一个可怕的想法，它带来了一些固有的复杂性：也就是说，之前理解运行时模块的timelines是不那么重要的。这就意味着开发者们需要知道每个异步模块是什么时候做它预期的工作的。

如果不明白这点，开发者们发现这样的情况：它有时候能正常工作，有时候不能。由于竞态，调试是非常困难的。因为这样的事情，`AMD`失去了大量的势头和牵引。

学习更多关于`AMD`的陷阱，查看[Moving Past RequireJS](http://benmccormick.org/2015/05/28/moving-past-requirejs/)

## ES2015模块101

在继续下去之前，我们回顾一下`ES2015`模块。如果你已经非常熟悉了，那这是一个快速的复习。
在`ES2015`中，模块已经成为官方`JavaScript`语言的一部分，它们非常强大而且很容易去掌握，站在`CommonJS`模块这个巨人的肩膀上的话。

### 作用域

通常，一个`ES2015`模块所有的全局变量仅作用于自己这个文件，模块可以导出数据，也可以导入其他的模块。

### 导出和导入

在一个你想导出的项目(如一个变量，函数、类)的前面加上一个关键词`export`就可以导出，在下面这个例子中，我们导出`Dog`和`Wolf`:
```
// zoo.js
var getBarkStyle = function(isHowler) {  
  return isHowler? 'woooooow!': 'woof, woof!';
};
export class Dog {  
  constructor(name, breed) {
    this.name = name;
    this.breed = breed;
  }
  bark() {
    return `${this.name}: ${getBarkStyle(this.breed === 'husky')}`;
  };
}
export class Wolf {  
  constructor(name) {
    this.name = name;
  }
  bark() {
    return `${this.name}: ${getBarkStyle(true)}`;
  };
}
```
让我们想想如果在一个单元测试（如`Mocha/Chai`）用引入这个模块。使用语法`import <object> from <path>`，至于`<object>`我们可以选择我们想导入的元素--命名导入（[named imports](http://www.2ality.com/2014/09/es6-modules-final.html)）。接下来我们可以从`chai`中导入`expect`，同样，从`Zoo`中导入`Dog`和`Wolf`。这种命名导入的语法很像ES2015的另一个方便的特性--[解构赋值](http://www.2ality.com/2015/01/es6-destructuring.html)
```
// zoo_spec.js
import { expect } from 'chai';  
import { Dog, Wolf } from '../src/zoo';
describe('the zoo module', () => {  
  it('should instantiate a regular dog', () => {
    var dog = new Dog('Sherlock', 'beagle');
    expect(dog.bark()).to.equal('Sherlock: woof, woof!');
  });
  it('should instantiate a husky dog', () => {
    var dog = new Dog('Whisky', 'husky');
    expect(dog.bark()).to.equal('Whisky: woooooow!');
  });
  it('should instantiate a wolf', () => {
    var wolf = new Wolf('Direwolf');
    expect(wolf.bark()).to.equal('Direwolf: woooooow!');
  });
});
```

### 默认

如果你只有一个项目要导出，你可以使用`export default`来将你需要导出的项目作为一个对象
```
// cat.js
export default class Cat {  
  constructor(name) {
    this.name = name;
  }
  meow() {
    return `${this.name}: You gotta be kidding that I'll obey you, right?`;
  }
}
```

导入默认的模块更简单，至于结构赋值就不再用到了，你可以直接从模块中导入


```
// cat_spec.js
import { expect } from 'chai';  
import Cat from '../src/cat';
describe('the cat module', () => {  
  it('should instantiate a cat', () => {
    var cat = new Cat('Bugsy');
    expect(cat.meow()).to.equal('Bugsy: You gotta be kidding that I\'ll obey you, right?');
  });
});
```

学习更多关于`ES2015`模块的知识，查看文章[Exploring ES6 — Modules.](http://exploringjs.com/es6/ch_modules.html)

## ES2015模块加载器和System.js
惊奇的发现，`ES2015`实际上没有一个模块加载规范。这儿是一个非常受欢迎的对动态模块加载的提议--[es6-module-loader](https://github.com/ModuleLoader/es6-module-loader)--受[System.js](https://github.com/systemjs/systemjs)的启发。这个提议已经被撤回了，但是有个[WhatWG](https://whatwg.github.io/loader/)在讨论阶段的新的加载规范和[Domenic Denicola](https://github.com/tc39/proposal-dynamic-import)提出的动态导入规范。

然而，`System.js`目前是最常使用的支持`ES2015`的模块加载器实现之一，它支持`ES2015`，`AMD`，`CommonJS`和浏览器中的全局脚本，还有`NodeJS`。它提供了一个异步模块加载器（对比`Require.js`）和`ES2015`转换，通过[Babel](https://babeljs.io/),[Traceur](https://github.com/google/traceur-compiler)或者[Typescript](http://www.typescriptlang.org/)。

`System.js`使用`Promises-based API`实现了异步模块加载。自从`promises`可以被链式调用和组合，这是非常长强大和方便的方法。举个例子，如果你想平行的加载多个模块，你可以使用`Promises.all`，当所有`promises`都被解决后，`listener`就可以被解除了。

最后，动态导入规范正在得到更多的牵引，而且已经被编入`webpack 2`。你可以看看它在webpack2指南上是如何工作的[Code splitting with ES2015](https://webpack.js.org/guides/migrating/#code-splitting-with-es2015)，这也是受`system.js`的启发，所以过度起来也很简单。

## 同步和异步导入模块
为了以同步和异步两种方式说明模块的加载，这里有一个简单的项目，将会在页面加载的时候同步加载我们的`Cat`模块，在用户点击按钮的时候懒加载`Zoo`模块。代码的`github`地址[lazy-load-es2015-systemjs](https://github.com/tiagorg/lazy-load-es2015-systemjs)。

让我们看一看主要的代码块中在页面加载时加载的代码，我们的`main.js`。

首先，注意通过`import`同步加载`Cat`时的表现，然后，创建了一个`Cat`的实例，调用它的方法`meow()`，然后添加结果到`DOM`中：
```
// main.js
// Importing Cat module synchronously
import Cat from 'cat';
// DOM content node
let contentNode = document.getElementById('content');
// Rendering cat
let myCat = new Cat('Bugsy');  
contentNode.innerHTML += myCat.meow();
```
最后，注意通过`System.import('zoo')`异步导入`Zoo`，最后，`Dog`和`Wolf`分别调用他们的方法`back()`，再次将结果添加到`DOM`中：
```
// Button to lazy load Zoo
contentNode.innerHTML += `<p><button id='loadZoo'>Lazy load <b>Zoo</b></button></p>`;
// Listener to lazy load Zoo
document.getElementById('loadZoo').addEventListener('click', e => {
  // Importing Zoo module asynchronously
  System.import('zoo').then(Zoo => {
    // Rendering dog
    let myDog = new Zoo.Dog('Sherlock', 'beagle');
    contentNode.innerHTML += `${myDog.bark()}`;
    // Rendering wolf
    let myWolf = new Zoo.Wolf('Direwolf');
    contentNode.innerHTML += `<br/>${myWolf.bark()}`;
  });
});
```

## 结论
掌握遵守页面加载最少必须加载和懒加载可延迟加载的模块可以明显的提升你的页面性能，`AMD`和`CommonJS`为`ES2015`模块铺路。你可以开始使用`System.js`加载`ES2015`模块，或者通过`webpack 2`使用动态导入规范。但是官方的解决方案至今还未发布。
## reference
[lazy-loading-es2015-modules-in-the-browser](https://dzone.com/articles/lazy-loading-es2015-modules-in-the-browser)