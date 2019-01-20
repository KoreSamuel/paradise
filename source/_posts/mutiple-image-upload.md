---
title: 记一次多图上传+本地预览中遇到的问题
date: 2017-11-30 14:54:54
tags: js
category: 前端积累
comments: true
---

在 web 开发中常会遇到图片预览的场景，比如在图片上传的情况下，一个办法是将图片上传到服务器之后，服务端将存储的 URL 返回来，然后异步通过 URL 加载刚上传的图片，达到图片的预览。但是在这个过程中会有两次 web 请求，一次是发送文件，一次是下载文件。我们可以在图片上传前就进行图片的预览，这样可以避免不必要的网络请求和等待。

  <!-- more -->

## 图片添加

```html
<input
  type="file"
  id="uploadcontainer"
  name="images"
  multiple="multiple"
  accept="image/*"
/>
```

如上，`input`将`type`设置为`file`即可以上传文件，`accept`可以设置接收文件类型，这里是上传图片，所以设置成了`image/*`, `multiple` 属性可以支持多文件上传。

## 图片预览

> 以下代码默认加载了 jquery

```js
// 监听图片添加
$('#uploadcontainer').on('change', function() {
    let files = $(this).prop('files');
    that.preview(files);
});
preview: function(files) {
    let that = this;
    // 遍历预览
    $.each(files, function(index, item) {
        let fileReader = new FileReader();
        let tpl = new Template($('#tpl').html());
        fileReader.readAsDataURL(item);
        fileReader.onload = function(e) {
            that.FILES.push(item); // *** 图片onload过程中将图片存在一个全局的数组中,因为在预览过程中还会有分类等处理，会在真正上传的时候添加更多参数
            html = tpl.render({
                cover_url: e.currentTarget.result,
                title: item.name.split('.')[0],
            });
            // ... 将html放到页面
        };
    });
}
```

## 图片上传

> 假定我们的接口只支持每次只能上传一张图片

```js
upload: function(f, cb) {
    // 递归
    (function uploads() {
        let file = f.shift();
        if (file) {
            // 避免重名导致上传混乱，每次都重新创建新的对象
            let formData = new FormData();
            formData.append('image', file.image);
            formData.append('title', file.title);
            formData.append('category', file.category);
            $.ajax({
                type: 'POST',
                url: '****',
                data: formData,
                contentType: false,// *
                cache: false,
                processData: false // *
            }).always(function(rst) {
                if (rst.ret == 1) {
                    console.log(file.title + ' 上传中...')
                } else {
                    console.log(ret.msg || file.title + ' 上传失败...')
                }
                uploads();
            });
        } else {
            console.log('上传完成...');
            cb();
        }
    })();
},
```

## 后记

- 使用`FormData`对象，设置`contentType`为`false`, `processData`为`false`
- `fileReader.onload`的时候缓存图片，不然不能对应图片及增加的参数，导致图片和参数对应混乱
- 递归上传，每次创建`FormData`对象，避免重复上传和重名混乱
