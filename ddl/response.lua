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

local response = {}

-- to prevent use of casual module global variables
local mt = { 
	__index = response,
	__newindex = function (table, key, val)
		error('attempt to write to undeclared variable "' .. key .. '": '
				.. debug.traceback())
	end
}


local ok, template = pcall(require, 'resty.template')
if not ok then
	error('resty.template is not in correct package path' .. debug.traceback())
end

local util = require "util"

-- %note cookie management is not included
function response.new(self) 
	local ret = {
		headers      = ngx.header,
		content      = util.new_tab(8, 0),
		status       = ngx.HTTP_OK,
		eof          = false,
	}
	setmetatable(ret, mt)
	return ret
end

-- append data to content 
function response.write(self, data) 
	if self.eof == true then
		error("attemp to write closed response " .. debug.traceback())
	end
	table.insert(self.content, data)
end

-- append data to content with '\r\n' end 
function response.writeln(self, data) 
	if self.eof == true then
		error("attemp to write closed response " .. debug.traceback())
	end
	table.insert(self.content, data)
	table.insert(self.content, '\r\n')
end

-- flush
function response.flush(self) 
	local data = table.concat(self.content)
	ngx.print(data)
	self.content = {}
end

function response.set_status(self, code) 
	self.status = code
end

-- TODO should exit?
function response.close(self) 
	self.eof = true
	--ngx.exit(self.status)
end

function response.exit(self, status)
	if status ~= nil then
		ngx.exit(status)
	elseif self.status ~= nil then
		ngx.exit(self.status)
	else 
		ngx.exit(ngx.HTTP_OK)
	end
end

-- %note type must be string
-- such as 'image/gif'
function response.set_content_type(self, type) 
	ngx.header.content_type = type
end

-- return a 1x1 empty gif 
function response.empty_gif(self) 
	local gif = util.base64_decode('R0lGODlhAQABAJAAAP8AAAAAACH5BAUQAAAALAAAAAABAAEAAAICBAEAOw==')		
	ngx.print(gif)	
end

-- use resty.template, tpl is name of template filename
-- usage: response:render_tpl("go.html", table)
function response.render_tpl(self, tpl, model) 
	template.caching(true)
	template.render(tpl,model)
end


return response 
