## debug library

###依赖

socket.lua和socket.so引用自项目 https://github.com/diegonehab/luasocket 请自行编译与替换（so文件也同时放入`dodolu/ddl/luaclibs/`下）

###使用说明

这个debug库是从mobdebug.lua https://github.com/pkulchenko/MobDebug 修改而来，优化了显示，更改了命令的写法(更像gdb)，添加了几个命令(local,l,display等)，保留了原来库的名字

命令集：
```
> help
b <file>:<line>            -- sets a breakpoint
d [breakpoint]             -- removes a breakpoint
dall                       -- removes all breakpoints
display <exp>              -- adds a new display expression
undisplay <index>          -- removes the watch expression at index
unalldisplay               -- removes all watch expressions
r                          -- runs until next breakpoint
s                          -- runs until next line, stepping into function calls
n                          -- runs until next line, stepping over function calls
finish                     -- runs until line after returning from current function
listb                      -- lists breakpoints
listd                      -- lists display
l                          -- lists source
p <exp>                    -- evaluates expression on the current context and prints its value
exec <stmt>                -- executes statement on the current context
load <file>                -- loads a local file for debugging
reload                     -- restarts the current debugging session
stack                      -- reports stack trace
local                      -- reports local variables
output stdout <d|c|r>      -- capture and redirect io stream (default|copy|redirect)
basedir [<path>]           -- sets the base path of the remote application, or shows the current one
done                       -- stops the debugger and continues application execution
q                          -- exits debugger and the application

```

运行目录下 `sh debug.sh`，然后在要调试的lua文件的入口处加上`require("mobdebug").start()`。

> 确保这句话会被执行

然后当出现
```
Lua Remote Debugger
Run the program you wish to debug
Paused at file a.lua
Type 'help' for commands
> 

```

代表断点已经打上了，可以用n(下一行) s(单步进入) finish(结束这个函数) l(打印源代码) b(ex: b a.lua:10 打断点) r(继续执行) display(添加监视) p(打印变量) 等命令进行调试
