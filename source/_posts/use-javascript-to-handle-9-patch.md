---
title: 使用JavaScript处理点九图
date: 2018-01-09 17:56:03
categories: 积累
tags: [canvas, javascript, 9-patch]
comments: true
---

## 前言

在前端开发中，常会将图片作为某个元素的背景图，但是背景图的大小和比例和元素有偏差，所以一般要使元素有全背景的话，只能将图片拉伸。这里不考虑`background-repeat`。最好的办法还是将图片修改为比例和元素相同以等比缩放。
使用微信或者 QQ 的人应该会发现聊天气泡，气泡会随着内容多少的改变而去适应它，但是并没有使气泡图片有拉伸的效果，这里就用到了[点九图](https://developer.android.com/guide/topics/graphics/2d-graphics.html#nine-patch)

  <!-- more -->

## 点九图

关于点九图这里不做过多介绍，简单来说，它是`andriod`平台的应用软件开发里的一种特殊的图片形式，扩展名为`.9.png`。它有两个重要的特点是：四周必须要有四条一像素纯黑的线或点；左上两条线控制拉伸区，右下两条线控制内容区。
这里我们需要将上传的点九图片拉伸成指定的或者自适应的比例，在没有接触点九图之前根本没有任何想法，于是上`github`上找到一个在 web 端处理点九图的[库](https://github.com/chrislondon/9-Patch-Image-for-Websites)，将代码拉取到本地即可看到`demo`。

## 分析

阅读源码发现主要使用`border-image`和用`canvas`绘制两种方式实现。首先先取出点九图左边和上边`1px`，这里以水平方向为例：

```js
let tempCtx, tempCanvas;
tempCanvas = document.createElement('canvas');
tempCtx = tempCanvas.getContext('2d');
tempCtx.drawImage(this.bgImage, 0, 0);
let data = tempCtx.getImageData(0, 0, this.bgImage.width, 1).data;
```

上面的`data`存放的为只读的`ImageData.data`属性，返回[`Uint8ClampedArray`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Uint8ClampedArray),描述一个一维数组，包含以 `RGBA` 顺序的数据，数据使用 `0` 至 `255`（包含）的整数表示。然后遍历这个一维数组，每`4`位一个`step`，找到可拉伸的区间数量和区域。

```js
NinePatch.prototype.getPieces = function(data, staticColor, repeatColor) {
  var tempDS, tempPosition, tempWidth, tempColor, tempType;
  var tempArray = new Array();

  tempColor = data[4] + ',' + data[5] + ',' + data[6] + ',' + data[7];
  tempDS =
    tempColor == staticColor ? 's' : tempColor == repeatColor ? 'r' : 'd';
  tempPosition = 1;

  for (var i = 4, n = data.length - 4; i < n; i += 4) {
    tempColor =
      data[i] + ',' + data[i + 1] + ',' + data[i + 2] + ',' + data[i + 3];
    tempType =
      tempColor == staticColor ? 's' : tempColor == repeatColor ? 'r' : 'd';
    if (tempDS != tempType) {
      // box changed colors
      tempWidth = i / 4 - tempPosition;
      tempArray.push(new Array(tempDS, tempPosition, tempWidth));

      tempDS = tempType;
      tempPosition = i / 4;
      tempWidth = 1;
    }
  }

  // push end
  tempWidth = i / 4 - tempPosition;
  tempArray.push(new Array(tempDS, tempPosition, tempWidth));

  return tempArray;
};
```

上面的`getPieces`方法存放了可用于判断拉伸区间数量和可拉伸范围的数组。在将其传入绘制函数中。

```js
for (var i = 0, n = this.horizontalPieces.length; i < n; i++) {
  if (this.horizontalPieces[i][0] == 's') {
    tempStaticWidth += this.horizontalPieces[i][2];
  } else {
    tempDynamicCount++; // 拉伸区间数量
  }
}

fillWidth = (dWidth - tempStaticWidth) / tempDynamicCount; // 可拉伸区间
```

再将取得的水平和垂直的`1px`获取到的数组进行嵌套循环，去填充拉伸图片，这里就不贴代码了，可以查阅源码理解。

## 新问题

找到的这种方式只能将图片进行放大，如果点九图比需要预览的图大，那就不适用了，还有个新问题是，点九图的宽或高跟预览图相比，有个的值大，有一个的值小，如：W 点九 > W 预览，H 点九 < H 预览。这种情景也不适用，所以考虑处理点九图。
这里只说最终的解决办法，当点九图的宽或高其中一个大于预览图的对应值时，将对应边缩小到预览图的值，再将另一边等比缩小，产生新的点九图片，这样新的点九图肯定比预览图小，可以正常拉伸了。

```js
if (
  this.div.offsetWidth < this.bgImage.width &&
  this.div.offsetHeight > this.bgImage.height
) {
  tmpCanvas.width = this.div.offsetWidth;
  tmpCanvas.height = Math.floor(
    (this.bgImage.height * this.div.offsetWidth) / this.bgImage.width
  );
  tmpCtx.drawImage(
    this.bgImage,
    0,
    0,
    this.div.offsetWidth,
    Math.floor(
      (this.bgImage.height * this.div.offsetWidth) / this.bgImage.width
    )
  );
  let tmpImage = new Image();
  tmpImage.src = tmpCanvas.toDataURL('image/png');
  this.bakImage = this.bgImage;
  this.bgImage = tmpImage;
}
```

## 遗留的问题

按照上面的缩放方式，不论是宽还是高缩小，都会影响原点九图左边或者上面的`1px`的边界，导致在 `getPieces`方法中误取可拉伸区间值，这种情况一般发生在边界线离点九图非透明色边界距离较近时发生，暂时没有想到解决方案。
想到其实这也是种模拟实现的方式，在实际的产品中不可能多用。不过这个过程收获也是挺大。
有好的解决方案欢迎轻敲~~
