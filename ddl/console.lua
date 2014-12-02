-- Author : pwq1989
-- Email  : pwq1989@gmail.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local console = {}
local util = require "util"
local config = require "console_config"

local _log_levels = {
        all   = 0,
        trace = 1,
        debug = 2,
        info  = 3,
        warn  = 4,
        error = 5,
        fatal = 6,
        off   = 999,
      }

local print = print
if ngx and ngx.say then
    print = ngx.say
end

--[[
OFF
The OFF has the highest possible rank and is intended to turn off logging.
FATAL
The FATAL level designates very severe error events that will presumably lead the application to abort.
ERROR
The ERROR level designates error events that might still allow the application to continue running.
WARN
The WARN level designates potentially harmful situations.
INFO
The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.
DEBUG
The DEBUG Level designates fine-grained informational events that are most useful to debug an application.
TRACE
The TRACE Level designates finer-grained informational events than the DEBUG

ALL
The ALL has the lowest possible rank and is intended to turn on all logging.
--]]
function console.log(log_level,...)
  local print_log_level = _log_levels[log_level]
  local config_log_level = _log_levels[config.log_level]
--  print(_config.log_level)
  if(util.is_nil(config_log_level)) then
    return false,"log_level is error!!!"
  end
  
  --ngx.say(string.format('config log_level is %s, print log_level is %s',config_log_level,print_log_level))
  local args = {...}
  if(print_log_level>=config_log_level) then
    local log_str = string.format('%s %s',os.date("[%Y/%m/%d %H:%M:%S]"),print_log(args))
    if ngx and print == ngx.say then 
        print(log_str,'<br/>')
    else 
        print(log_str,'\n')
    end
  end
  
  return true,_
end

function print_log(args,separator) 
    local print_str = ""
    local separ_str =  separator or "\t"
   
    if(util.is_nil(args)) then
        return ""
	end 
    for k,v in pairs(args) do 
       print_str = print_str..table.val_to_str(v)..separ_str
    end
    return print_str 
end



return console

