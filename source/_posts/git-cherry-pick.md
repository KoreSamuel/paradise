---
title: 使用git-cherry-pick
date: 2018-07-05 14:44:02
tags: git
---

## 前言

在一个项目中可能有多个功能并行开发着，开发完的代码通常就合到 develop 分支进行测试，即测试环境中会有多个功能在测试，而先后进入测试并不一定先后上线，很有可能因为某些原因，先开发的功能需要延期上线，后开发的功能测试完后得先上线。这时候需要将后开发的功能代码抽出来，`git cherry-pick`就派上用场

  <!-- more -->

## 什么是 cherry-pick

`cherry-pick`是 git 中的一个命令，像`pull，push，commit`一样。
它可以用于将在其他分支上的 `commit` 修改，移植到当前的分支。
如之前所说场景，就可以使用 `cherry-pick` 命令，将这个功能相关的 `commit` 提取出来，合入稳定版本的分支上。

## 如何使用 cherry-pick

```bash
git cherry-pick [--edit] [-n] [-m parent-number] [-s] [-x] [--ff]
      [-S[<keyid>]] <commit>…​
git cherry-pick --continue
git cherry-pick --quit
git cherry-pick --abort
```

常用的使用方式是

```bash
git cherry-pick commit-id
```

执行 `git log --graph --oneline --all`可以看到类似下面的 log

```bash
* f07407f (origin/develop, develop) feat: 这是第三个功能
* 948fa63 feat: 这是第二个功能
* ba09a70 feat: 这是第一个功能
* e6d4aef (HEAD -> master, origin/master, origin/HEAD) Initial commit
```

如果我们需要将`第二个功能`摘取出来，即`commit-id`为`948fa63`

```bash
git cherry-pick 948fa630
```

执行完之后会产生一个新的 commitid,如果遇到有冲突，`git diff`或者用`diff`工具修改就行，顺利的话就可以正常提交了。
此时执行 `git log --graph --oneline --all`

```bash
* 762491f (HEAD -> develop, origin/develop) feat: 这是第二个功能
* f07407f feat: 这是第三个功能
* 948fa63 feat: 这是第二个功能
* ba09a70 feat: 这是第一个功能
* e6d4aef (origin/master, origin/HEAD, master) Initial commit
```

而当前的代码也是`第二个功能`时的代码。
这时候 `第三个功能`也要上线了,那就将它也摘出来吧

```bash
git cherry-pick -x f07407f
```

上面命令多了 `-x` 参数，这是更高级一点的用法，表示保留原提交的作者信息进行提交。
当然，如果需要摘出多个`commit-id`,首先可以重复执行`git cherry-pick`，另外可以使用下面的方式

```bash
git cherry-pick <start-commit-id><end-commit-id>
```

它的范围就是 `start-commit-id` 到 `end-commit-id` 之间所有的 `commit-id`，但是它这是一个 (前开 ，后闭] 的区间，也就是说，它将不会包含 `start-commit-id` 的 `commit-id`。
而如果想要包含 `start-commit-id` 的话，就需要使用 `^` 标记一下，就会变成一个 [前闭，后闭] 的区间

## 参考

- [https://git-scm.com/docs/git-cherry-pick](https://git-scm.com/docs/git-cherry-pick)
- [Understanding Git Cherry-pick: How to Use](https://www.codementor.io/olatundegaruba/how-to-git-cherry-pick-dyrp9pnmc)
