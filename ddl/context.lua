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

local context = {}

local ok, _request = pcall(require, "request")
if not ok then
	error("module request is not in correct package path" 
	      .. debug.traceback())
end

local ok, _response = pcall(require, "response")
if not ok then
	error("module response is not in correct package path" 
	      .. debug.traceback())
end

local ok, _cookie = pcall(require, "resty.cookie")
if not ok then
	error("module resty.cookie is not in correct package path" 
	      .. debug.traceback())
end

local util = require "util"
local logger_provider = require "logger_provider"

-- to prevent use of casual module global variables
local mt = { 
	__index = context,
	__newindex = function (table, key, val)
		error('attempt to write to undeclared variable "' .. key .. '": '
				.. debug.traceback())
	end
}

-- usage: 
-- TODO
function context.new(self) 
	local ret = {
		request    = _request:new(),
		response   = _response:new(),
		cookie     = _cookie:new(),
		var        = util.new_tab(8, 0),
	}

	setmetatable(ret, mt)	
	return ret
end

function context.get_logger(name) 
	return logger_provider.get_logger(name)
end


return context
