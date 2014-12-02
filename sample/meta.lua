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
--

-- this file descript modules that need to be auto-generated

local meta = {}

-- logs section
local go_log = {}
go_log.logfile = 'go_log.log'
go_log.name = 'go'

go_log.sections = {
	{ type = 'field',         value = 'log_version' },
	{ type = 'separator',     value = string.char(001) },
	{ type = 'field',         value = 'server_timestamp' },
	{ type = 'separator',     value = string.char(002) },
	{ type = 'field',         value = 'server_ip' },
	{ type = 'separator',     value = string.char(002) },
	{ type = 'field',         value = 'some_value' },
}


-- route section
local go_route = {}
go_route.name = "go"
go_route.appname = "deeplink_go"
go_route.path = [[ /go ]]
go_route.properties = [[ client_body_buffer_size 1000k; ]]


-- add to meta object 
meta.logs = { go_log,  } 
meta.routes = { go_route,  }
meta.base_dir = "/home/youdir"
meta.nginx_log_dir = "/home/yournginx/logs"

return meta
