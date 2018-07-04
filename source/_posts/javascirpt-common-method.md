---
title: javascirpt常用函数实现
date: 2018-07-03 20:02:30
tags:
---
随手记录点好玩的东西
### 实现一个sleep函数

```js
// promise
const sleep = time => {
  return new Promise(resolve => {
    setTimeout(resolve, time);
  });
};
const t1 = +new Date();
sleep(1000).then(() => {
  const t2 = +new Date();
  console.log(t2 - t1); // 1005
})
```
```js
//await/async
const sleep = time => {
  return new Promise(resolve => {
    setTimeout(resolve, time);
  });
};
const ts = async () => {
  const t1 = +new Date();
  await sleep(1000);
  const t2 = +new Date();
  console.log(t2 - t1);
}
ts(); // 1001
```
在社区能找到一个[https://github.com/erikdubbelboer/node-sleep](https://github.com/erikdubbelboer/node-sleep),不过需要安装才能使用

```js
const sleep = require('sleep');

const t1 = +new Date();
sleep.msleep(1000);
const t2 = +new Date();
console.log(t2 - t1); // 1000
```

### 数组去重

```js
// 双重循环
const arr = [1, 2, 3, '4', 3, 1];
const unique = arr => {
  const rst = [];
  let i, j, len, lens;
  for (i = 0, len = arr.length; i < len; i++) {
    let item = arr[i];
    for (j = 0, lens = rst.length; j < lens; j++) {
      if (item === rst[j]) {
        break;
      }
    }
    lens === j && rst.push(item)
  }
  return rst;
};
console.log(unique(arr)); //[ 1, 2, 3, '4' ]
```
```js
// filter/indexOf
const arr = [1, 2, 3, '4', 3, 1];
const unique = arr => {
  return arr.filter((item, index, arr) => {
    return arr.indexOf(item) === index;
  });
};
console.log(unique(arr)); // [ 1, 2, 3, '4' ]
```
```js
// hash
const arr = [1, 2, 3, '4', 3, 1];
const unique = arr => {
  const hash = {}, rst = [];
  for (let i = 0, len = arr.length; i < len; i++) {
    let cur = arr[i];
    if (!hash[cur]) {
      rst.push(cur);
      hash[cur] = true;
    }
  }
  return rst;
};
console.log(unique(arr)); // [ 1, 2, 3, '4' ]
```
但是如果数组元素不限于 `Number` 和 `String` 类型，为了保证 `hash key` 的唯一性，我们可以传递一个 `hasher` 函数处理 `key`。如下

```js
const arr = [1, 2, 3, '4', 3, 1];
const arrs = [1, false, false, 'false', 2, {name: 'ming'}, '4', {name: 'ming'}, 1];
const unique = (arr, hasher) => {
  // 默认使用JSON.stringify,不过对于Function不适用，可传入其他处理方式
  hasher = hasher || JSON.stringify;

  const rst = [], hash = {};
  for (let i = 0, len = arr.length; i< len; i++) {
    let cur = arr[i];
    let hashkey = hasher(cur);

    if (!hash[hashkey]) {
      rst.push(cur);
      hash[hashkey] = true;
    }
  }
  return rst
};
console.log(unique(arr)); // [ 1, 2, 3, '4' ]
console.log(unique(arrs)); // [ 1, false, 'false', 2, { name: 'ming' }, '4' ]
```
当然啦，还有最终极的版本，那就是`ES6`提供的`Set`.不过处理的数据类型也是有限的，可以按情况选择哪种方式
```js
const arr = [1, 2, 3, '4', 3, 1];
const arrs = [1, false, false, 'false', 2, {name: 'ming'}, '4', {name: 'ming'}, 1];

const unique = arr => [...new Set(arr)];

console.log(unique(arr)); // [ 1, 2, 3, '4' ]
console.log(unique(arrs)); // [ 1, false, 'false', 2, { name: 'ming' }, '4', { name: 'ming' } ] 不符合预期
```
### array-like 转成 array
所谓`array-like`就是按照数组下标排序的对象，有`length`属性，如`{0: 'aa', 1: 'bb', 2: 'cc', length: 3}`;

将函数参数`arguments`转换成数组，常见的处理方式如下
```js
const arr = Array.prototype.slice.call(arguments); // [ 'aa', 'bb', 'cc' ]
// 或者
const arr = [].slice.call(arguments); // [ 'aa', 'bb', 'cc' ]
```
至于上面两种方式的区别，可以查看[js中 [].slice 与 Array.prototype.slice 有什么区别?](https://www.zhihu.com/question/46724226)了解
使用`ES6`之后，可以有另外两种方式
```js
const arr = Array.from(arguments);
// and
const arr = [...arguments]; // 适用于arguments
```
_待续_