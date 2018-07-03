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
_待续_
