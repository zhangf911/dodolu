dodolu
======

a lightweight web framework based on openresty lua

usage: 

$ cd tools

$ lua proprocess.lua 

will auto-generate nginx.conf, route file and logger file 

-----------------
## dodolu web 框架
dodolu 基于openresty的nginx lua modlue的轻量级web框架，将原生的lua api做了简单封装，并提供了根据配置文件，自动生成route模块，nginx.conf配置，logger模块的功能，减轻了开发工作量，避免重复手写大量易错的配置或字符串变量，有助于多人开发统一风格，并提供了简单封装的request, response, global variable，适合构建稍微复杂web应用。

### 目录结构
```
.
|-- app                                            -- your app lua files
|   |-- sample.lua
|-- auto                                           -- auto generated directory
|   |-- logger
|   |   |-- xxx_auto_logger.lua
|   |-- nginx_runtime
|   |   `-- nginx.conf
|   `-- route
|       |-- route_auto_xxx_entry.lua
|-- ddl                                            -- web framework files
|   |-- console.lua
|   |-- console_config.lua
|   |-- context.lua
|   |-- logger_provider.lua
|   |-- lualibs
|   |   |-- BinDecHex.lua
|   |   |-- UUID.lua
|   |   `-- resty
|   |       |-- cookie.lua
|   |       |-- template
|   |       |   |-- crc32.lua
|   |       |   |-- crc32jit.lua
|   |       |   |-- html.lua
|   |       |   `-- microbenchmark.lua
|   |       `-- template.lua
|   |-- request.lua
|   |-- response.lua
|   `-- util.lua
|-- meta                                           -- meta discription file
|   |-- meta.lua
|   `-- nginx.conf.template
|-- template                                       -- resty.template module dir
|   `-- index.html
|-- tools                                          -- code generator
|   |-- README.md
|   |-- code.lua
|   `-- proprocess.lua
```

###框架特点
 - 轻量，简单的封装，对于速度几乎没有影响
 - 代码自动生成，同一个配置生成三处代码，避免了配置与代码不一样带来的隐蔽问题
 - 适当的封装使得lua代码更有可读性
 - 推荐主处理流程传递context作为参数， 并提供ctx.var.xxx用来缓存结果

###Demo
你的项目lua文件  app/app.lua ：
```
-- 这个文件下面存放你的业务逻辑
local app = {}

function app.do_get(ctx) 
    local response = ctx.response
    local request = ctx.request
    local cookie = ctx.cookie
    response:set_content_type("text/html")
    local url = request.uri
    -- do some process

    ------------- write log ---------------
    local logger = ctx.get_logger('go_log')
    local log_data = { a = "xxx"}
    logger.write(log_data, other_params...)

    ------------- return empty gif -------
    response:empty_gif()
    response:close()
end

function app.do_post(ctx) end
function app.do_put(ctx) end
function app.do_delete(ctx) end

return app
```

配置文件  meta/meta.lua :
```
-- 这个文件下面存放的是你的配置文件，tools/proprocess.lua会根据这个文件与nginx.conf.template来生成 nginx.conf，route文件，logger文件

local meta = {}

-- logs section
local go_log = {}
go_log.logfile = 'go_log.log'                                   -- 日志文件名字
go_log.name = 'go'                                              -- 日志节点的名字，会在app中通过ctx.get_logger('go').write(data)使用

go_log.sections = {
    { type = 'field',         value = 'log_version' },          -- 日志记录字段名
    { type = 'separator',     value = string.char(001) },       -- 日志分隔符
    { type = 'field',         value = 'server_timestamp' },
    { type = 'separator',     value = string.char(002) },
    { type = 'field',         value = 'server_ip' },
    { type = 'separator',     value = string.char(002) },
    { type = 'field',         value = 'some_value' },
}

-- route section
local go_route = {}
go_route.name = "go"
go_route.appname = "app"         -- 该route对应的处理文件，回到app/目录下去寻找app.lua
go_route.path = [[ /go ]]        -- 对应的path         
go_route.properties = [[ client_body_buffer_size 1000k; ]]

-- add to meta object 
meta.logs = { go_log,  }         -- 日志的列表
meta.routes = { go_route,  }     -- route的列表
meta.base_dir = "/home/youdir"   -- 你的项目的路径
meta.nginx_log_dir = "/home/yournginx/logs"    -- nginx的日志路径

return meta

```

nginx配置模板  nginx.conf.template:
其中被{{}}括号起来的是会被替换掉的内容
```
lua_package_path '{{base_dir}}/app/?.lua;{{base_dir}}/auto/route/?.lua;{{base_dir}}/auto/logger/?.lua;{{base_dir}}/ddl/?.lua;{{base_dir}}/ddl/lualibs/?.lua';

server {
        listen       80;
        charset      utf-8 ;
        server_name  yourhost;

        lua_code_cache off ;
    
        access_log off;

        root /home/yourroot/tengine_root ;
        set $template_root {{base_dir}}/template ;
         
        location / {
                # nonstandard code 444 closes the connection without sending any headers.
                return 444 ;
        }
        
        location ~* \.(js|gif|jpg|png)$ {
                access_log        off ;
                expires 0 ;
        }
    {{dodolu_route_section}}

    {{dodolu_log_section}}

}

```

###运行原理
dodolu框架会帮你针对记录日志，路由等配置生成代码。日志模块使用了nginx的ngx.location.capture与自带的access_log实现，效率较高，但是会手写大量重复的代码，分别在lua文件与nginx配置中，而且极易出错。dodolu框架会帮助你根据meta文件，自动生成logger模块，并提供一个context，包含request，response，cookie，template的简单封装。

用户可以在app.lua的do_get(ctx)方法中对GET方法做处理，ctx是通过自动生成的route传进来的context。（推荐在主处理流程中传递context的代码风格）

生成的代码存放在auto/文件夹下。
