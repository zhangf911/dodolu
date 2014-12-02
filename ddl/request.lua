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

-- this module wrap some useful function for ngx.xxx about request

local request = {}

-- to prevent use of casual module global variables
local mt = { 
	__index = request,
	__newindex = function (table, key, val)
		error('attempt to write to undeclared variable "' .. key .. '": '
				.. debug.traceback())
	end

}

function request.new(self)
	local ngx_var = ngx.var
	local ngx_req = ngx.req
	local ret = {
		method         = ngx_var.request_method,
		shema          = ngx_var.schema,
		host           = ngx_var.host,
		hostname       = ngx_var.hostname,
		uri            = ngx_var.request_uri,
		path           = ngx_var.uri,
		is_subrequest  = ngx.is_subrequest,
		filename       = ngx_var.request_filename,
		query_string   = ngx_var.query_string,
		headers        = ngx_req.get_headers(),
		user_agent     = ngx_var.http_user_agent,
		server_addr    = ngx_var.server_addr,
		remote_addr    = ngx_var.remote_addr,
		remote_port    = ngx_var.remote_port,
		remote_user    = ngx_var.remote_user,
		remote_passwd  = ngx_var.remote_passwd,
		content_type   = ngx_var.content_type,
		content_length = ngx_var.content_length,
		uri_args       = ngx_req.get_uri_args(),
		post_args      = nil,  -- not initialized
		socket         = ngx_req.socket,
	}

	setmetatable(ret, mt)
	return ret
end

-- get uri argument by name
-- if not found, return nil
function request.get_uri_arg(self, name) 
	if name == nil or self.uri_args == nil then 
		return nil
	end
	local arg = self.uri_args[name]
	if arg ~= nil then 
		if type(arg) == 'table' then 
			for _, v in ipairs(arg) do 
				if v and string.len(v) > 0 then
					return v
				end
			end
		else 
			return arg
		end
	end
	-- not found
	return nil
end

-- get post argument by name
-- if not found, return nil
-- %note you must use request:read_body to parse arg from post content
function request.get_post_arg(self, name)
	if name == nil or self.post_args == nil then
		return nil
	end
	local arg = self.post_args[name]			
	if arg ~= nil then 
		if type(arg) == 'table' then 
			for _, v in ipairs(arg) do 
				if v and string.len(v) > 0 then
					return v
				end
			end
		else 
			return arg
		end
	end
	-- not found
	return nil
end

-- read request content and set post args
function request.read_body(self)
	ngx.req.read_body()
	self.post_args = ngx.req.get_post_arg()
end

-- rewrite
function request.rewrite(self, uri, jump) 
	return ngx.req.set_uri(uri, jump)
end

-- set uri args
function request.set_uri_args(self,args)
	return ngx.req.set_uri_args(args)
end


return request
