# binlin博客主题

## 简介

本项目主要使用jekyll 搭建基于github page的静态个人博客网站，同时配置了个人域名，可以同步访问：[binlin.online](https://binlin.online)

## 运行

1. 预置条件：ruby 2.xx，安装jekyll 3.8.5和bundle （可以在Gemfile中自定义修改jekyll版本）
2. `git clone git@github.com:binlinrepo/binlinrepo.github.io.git`
3. `cd binlinrepo.github.io`
4. `bundle install`
4. `jekyll serve`
5. 在浏览器中打开`http://127.0.0.1:4000`

## 基于本项目搭建个人博客

1. fork本项目到自己分支， 在Setting中修改名称为`xxx.github.io`，xxx为登录用户名。
2. 替换assets/imgs中所有图片，同时替换掉根目录下的favicon.ico(32x32)，该图片是网站图标。
3. 修改配置文件_config.xml，将baidu-analysis改为自己的识别码。（登录百度统计，然后统计域名，会自动生成识别码）。
4. 删除_posts和_drafts目录下的所有文章，以及assets目录下的blog目录（文章配图）。
5. 到这儿应该已经OK了，不过还要删除掉CNAME文件。这下没问题了！