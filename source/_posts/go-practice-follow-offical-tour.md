---
title: go-practice-follow-offical-tour
date: 2018-06-15 17:37:50
tags:
---
最近在学习go相关的东西，以下为[Go官方指南](https://tour.go-zh.org/welcome/1)中的练习记录

1. 循环与函数
> 实现一个平方根函数：用[牛顿法](https://zh.wikipedia.org/wiki/%E7%89%9B%E9%A1%BF%E6%B3%95)实现平方根函数

```go
package main

import (
    "fmt"
)

func Sqrt(x float64) float64 {
    z := x / 2
    cnt := 10
    for cnt > 0 {
        z -= (z * z - x) / (2 * z)
        cnt = cnt - 1
    }
    return z
}

func main() {
    fmt.Println(Sqrt(3)) // 1.7320508075688772
}
```
2. 切片
> 实现 Pic。它应当返回一个长度为 dy 的切片，其中每个元素是一个长度为 dx，元素类型为 uint8 的切片。
当你运行此程序时，它会将每个整数解释为灰度值（好吧，其实是蓝度值）并显示它所对应的图像

```go
package main

import "golang.org/x/tour/pic"

func Pic(dx, dy int) [][]uint8 {
    pic := make([][]uint8, dy*dx)
    for i := 0; i < dy; i++ {
        in := make([]uint8, dx)
        for j := 0; j < dx; j++ {
            in[j] = uint8(1 << uint8(j%8))
        }
        pic[i] = in
    }
    return pic
}

func main() {
    pic.Show(Pic)
}
```
3. 映射
> 实现 WordCount。它应当返回一个映射，其中包含字符串 s 中每个“单词”的个数。函数 wc.Test 会对此函数执行一系列测试用例，并输出成功还是失败

```go
package main

import (
    "strings"

    "golang.org/x/tour/wc"
)

func WordCount(s string) map[string]int {
    m := make(map[string]int)
    field := strings.Fields(s)
    for i := 0; i < len(field); i++ {
        if m[field[i]] > 0 {
            m[field[i]] = m[field[i]] + 1
        } else {
            m[field[i]] = 1
        }
    }
    return m
}

/* output
func main() {
    wc.Test(WordCount)
}
PASS
 f("I am learning Go!") =
  map[string]int{"I":1, "am":1, "learning":1, "Go!":1}
PASS
 f("The quick brown fox jumped over the lazy dog.") =
  map[string]int{"dog.":1, "The":1, "fox":1, "over":1, "the":1, "quick":1, "brown":1, "jumped":1, "lazy":1}
PASS
 f("I ate a donut. Then I ate another donut.") =
  map[string]int{"another":1, "I":2, "ate":2, "a":1, "donut.":2, "Then":1}
PASS
 f("A man a plan a canal panama.") =
  map[string]int{"plan":1, "canal":1, "panama.":1, "A":1, "man":1, "a":2}
*/

```
4. 斐波纳契闭包
> 实现一个 fibonacci 函数，它返回一个函数（闭包），该闭包返回一个[斐波纳契数列](https://zh.wikipedia.org/wiki/%E6%96%90%E6%B3%A2%E9%82%A3%E5%A5%91%E6%95%B0%E5%88%97) `(0, 1, 1, 2, 3, 5, ...)`。

```go
package main

import "fmt"

func fibonacci() func() int {
    a, b, c := -1, 0, 0
    return func() int {
        if a == -1 {
            a = 0
            return a
        } else if a == 0 {
            a = 1
            return a
        } else {
            c = a + b
            b = a
            a = c
            return c
        }
    }
}

func main() {
    f := fibonacci()
    for i := 0; i < 10; i++ {
        fmt.Println(f())
    }
}
// 0, 1, 1, 2, 3, 5, 8, 13, 21, 34
```
5. note(方法与指针)
> 带指针参数的函数必须接受一个指针,而以指针为接收者的方法被调用时，接收者既能为值又能为指针。
由于指针参数的函数方法有一个指针接收者，为方便起见，Go 会将语句 v.Scale(5) 解释为 (&v).Scale(5)；
> 接受一个值作为参数的函数必须接受一个指定类型的值，而以值为接收者的方法被调用时，接收者既能为值又能为指针，方法调用 p.Abs() 会被解释为 (*p).Abs()
> 使用指针接收者的原因有二：
首先，方法能够修改其接收者指向的值。
其次，这样可以避免在每次调用方法时复制该值。若值的类型为大型结构体时，这样做会更加高效。

<!-- next start https://tour.go-zh.org/methods/9 -->
