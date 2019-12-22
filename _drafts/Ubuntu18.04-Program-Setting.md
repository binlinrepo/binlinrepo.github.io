---
title: Ubuntu18.04编程环境配置
category: Ubuntu18.04
tags: Ubuntu18.04 编程环境
---

在搭建编程环境之前有一个非常重要的内容需要介绍，那就是**Ubuntu环境变量的三种设置方式**。

第一种是设置临时环境变量，在命令行使用`export`导出临时变量，但是退出当前bash就会失效。例如`export $HOME/bin:$PATH`。

<!--more-->
第二种是设置当前用户的全局变量，能够一直有效。
```
vim $HOME/.bashrc
export $HOME/bin:$PATH
:wq
source $HOME/.bashrc
```

第三种设置所有用户的全局变量，能保证对所有用户有效。
```
vim /etc/profile
export $HOME/bin:$PATH
:wq
source /etc/profile
```

## Java环境配置

* 下载JDK：[OracleJDK](https://www.oracle.com/technetwork/java/javase/downloads/index.html)
* 创建安装目录：`sudo mkdir /opt/JDK`
* 解压到安装目录：`sudo tar -zxvf jdk-8u231-linux-x64.tar.gz -C /opt/Java/`
* 配置当前用户全局变量`$HOME/.bashrc`，在文件末尾追加：

```
# Setting Java
export JAVA_HOME="/opt/Java/jdk1.8.0_231"
export PATH="$JAVA_HOME/bin:$PATH"
```
* 使生效`source $HOME/.bashrc`
* 验证：

```txt
xxx$ java -version
java version "1.8.0_231"
Java(TM) SE Runtime Environment (build 1.8.0_231-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.231-b11, mixed mode)

xxx$ javac -version
javac 1.8.0_231
```

