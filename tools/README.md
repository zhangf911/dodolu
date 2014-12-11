## Introduction
This pro-process auto generate nginx.conf file, route lua files and logger lua files. This avoid duplicating redundancy code in different place which not friendly for debugging.

## Table of Content

* Synopsis
* Router module
* Logger module
* Config module

## Synopsis


------------------------------------------

##使用说明

* 运行原理
* route模块
* logger模块
* nginx配置模块

### 运行原理

配置文件采用lua语法，通过返回dofile(...)来获取配置。
meta.logs存放日志的配置对象，范例 `meta.logs = { a_log, b_log, }`。 meta.routes保存路由节点的配置，范例`meta.routes = { a_route, b_route, }`。meta.base_dir表示项目的根路径，meta.nginx_log_dir表示nginx日志的根路径。

### route模块

route模块一一对应了nginx.conf中的location节点。route对象的属性如下：

* name: route对象的名字
* appname: 这个route对象对应的lua文件，如果二级目录，则用 a.b来表示
* path: route的path需要前面加 / 如：`/go.html`
* properties: 代表这个location的其他属性

最终一个route会被翻译成一个location, proprocess.lua会自动生成一个xxx_entry.lua文件作为web入口，自动帮你处理HTTP请求类型与上下文构造。

### logger模块

logger模块会自动生成相关的lua文件与nginx配置，实用ngx.location.capture和 log_format的方式记录日志。

使用方式：
```
local logger = ctx.get_logger('your_logger_name')
logger.write(data1, data2, ...)
```
其中ctx是自动构造好的上下文。

属性如下：
* name: logger节点的名字，可通过context.get_logger('xxx')获取。
* logfile: 日志的文件名，目录是由meta.nginx_log_dir属性决定。
* sections: 每行日志的构成，从上到下构成一条日志。每个节点的type表示是字段还是分隔符。

> section例子：
```
log.sections = {
	{ type = 'field',         value = 'field1' },
	{ type = 'separator',     value = string.char(001) },
	{ type = 'field',         value = 'field2' },
	{ type = 'separator',     value = string.char(002) },
	{ type = 'field',         value = 'field3' },
}
```

### nginx conf模块

proprocess.lua会根据meta.lua中声明的route节点、logger节点、base_dir，nginx_log_dir等属性，对`meta/`目录下的nginx.conf.template文件的`{{xx}}`进行替换，所以用户可以除了在meta.lua中声明route节点，也可以直接写在template文件中。

