title: 'highcharts线型图表处理'
date: 2017-8-29 15:05:40
categories: 前端积累
tags: js
comments: true
---

## 问题分析

某次需求中，需要使用[`highcharts`](https://www.highcharts.com/)展示数据以对比。可是这批数据量级相差较大，如果在同一张图表中展示，会导致线条相隔很远或者没有波动幅度；还需要在点击某根线条的时候改变图表Y轴为当前线条数量级的，并处理他们的样式以区分。

那么，第一个问题，要在同一张表中展示不同量级的数据，且相互具有参考性，有个办法就是将数据统一处理成一个维度的，如[数据归一化](https://baike.baidu.com/item/%E5%BD%92%E4%B8%80%E5%8C%96%E6%96%B9%E6%B3%95)，将数据映射到`0~1`之间的小数，那不同量级的数据之间就有一定的参考性了。
第二个问题的话本来想过改源码，但是感觉意义不大，使用场景不多，就找`highcharts`的`api`文档，各种拼接。差不多实现了需求.

## 数据归一化

采用`min-max标准化`，也叫离差标准化，对原始数据的线性变化，结果落到`[0, 1]`之间。将需要处理的数据组，即`series`数据先处理，找到每组的最大最小，并计算.

```
function normalizing(arr) {
    var data = [];
    for (var i = 0, len = arr.length; i < len; i++) {
        var cur = arr[i].data;
        arr[i].visible = false;
        var name = arr[i].name;
        arr[i].showInLegend = false;
        var max = Math.max.apply(null, cur);
        var min = Math.min.apply(null, cur);
        var news = cur.map(function (x) {
            return (x - min) / max;
        });
        var item = { name: name, data: news };
        arr.push(item)
    }
    return arr;
};
```

上面代码中，将原数据的每个线条设置为不显示，再将归一化后的数据`push`到数组后面。即最终图表上显示的是处理后的数据绘制的线条，这样的操作会引发后面的问题，接下来会提到。

## 展示真实数据

在上面一步中，将所有数据都处理成了[0, 1]之间的数据，那鼠标`hover`上去显示的就是计算后的数据。这显然不是我们想要的，所以才没有去除原来的数据。查看`highcharts`的`api`，发现可以改变`hover`显示的格式，那我只需要找到计算后与之相对应的原数据就能正确显示了。
现在`hover`能够正确显示数据了，图表里的线条也有了一定的对比性，但是Y轴坐标依然是按照归一化后数据量级来的。在考虑到需要在点击线条的时候显示成其原数据量级的Y轴，所以采用以下办法。
取出选中线条数据中的最大最小，按照归一化算法逆回去，那么其实现在图表中的线条已经不是`[0, 1]`之间的数据了，而是分别乘上点击线条最大值，并加上最小值后的数据。那么，`Y`轴的自然就变成了当前的数据量级。

```
function adjustSeries(activeName) {
    var data = chart.series;
    var max, min;
    for (var i = 0, len = 6; i < len; i++) {
        var curName = data[i + 6].name
        var current = data[i];
        if (curName === activeName) {
            max = Math.max.apply(null, current.yData);
            min = Math.min.apply(null, current.yData);
        }
    }
    for (var i = 6, len = originData.length; i < len; i++) {
        var cur = originData[i].data || [];
        var newc = cur.map(function (item, index) {
            var cnt = Math.round(item * max) + min;
            return cnt;
        });
        var upObj = { data: newc, lineWidth: 1, dashStyle: 'Dash', dataLabels: { enabled: false }, className: 'half-opacity' };
        if (originData[i].name === activeName) {
            upObj = { data: newc, lineWidth: 4, dashStyle: 'Solid', dataLabels: { enabled: true }, className: 'no-opacity' }
        }
        chart.series[i].update(upObj);
    }
};
```

上面代码中的`originData`其实就是归一化后存起来的一个副本，因为后面每次点击都会使用这个数据，所以在存数据的时候一定要保证`originData`不变，存放的是真实数据，而不是数据引用，`javascript`基础知识，不清楚的可查看[javascript中的深拷贝和浅拷贝](https://www.zhihu.com/question/23031215)。

## 使用到的API

- plotOptions.series.event.click 点击线条的时候处理相关逻辑
- tooltip.formatter 更改鼠标`hover`的时候显示的数据和样式
- chart.series[i].update 动态更新图表数据，定制线条样式
- 其他...

## reference

- [Highcharts API](http://api.highcharts.com/highcharts)

[_成品链接_](http://dearxiaojie.top/note/demos/highcharts.html)
