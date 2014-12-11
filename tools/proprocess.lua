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


-- proprocess for nginx config and route file generation

local ok,code = pcall(require, "code")
if not ok then
	error("code.lua is not in correct path")
end

local dodolu_dir = "../"
local meta_file = "meta.lua" 
local nginx_tmp_file = "nginx.conf.template"
local check_log = false
local meta = {}
-- data filled by generate_routes function and used in generate_nginx_conf function
local route_app_file_list = {}

local intent_1 = "    "
local intent_2 = intent_1 .. intent_1 
local intent_3 = intent_2 .. intent_1

local status = {
	loglist = {},
	routelist = {},
}

function print_help()
	print([[
		dodolu 0.1 web framework auto code generater
		Copyright (c) 2014-2014 pwq1989 <pwq1989@gmail.com>
		This program will generate code into route, logger, nginx_runtime folder in auto parent folder

		Usage: sh run.sh [OPTIONS] [--] other
		Example: sh run.sh -check_log on	

		Options:
		-p                 meta file directory store meta.lua and nginx.conf.template
		-check_log         whether generate log extra check code
		
		Please report bug to <pwq1989@gmail.com>
	]])
	
end


function checkarg(optname, optvalue) 
	if optname == "-check_log" then 
		if not string.match("on|off", optvalue) then
			error()
		end
	end
end

function escape(input) 
	-- + - * ^ [ ] is sepacial character in lua regex
    input = string.gsub(input,'%%','%%%%')
    input = string.gsub(input,'%+','%%+')
    input = string.gsub(input,'%-','%%-')
    input = string.gsub(input,'%*','%%*')
    input = string.gsub(input,'%^','%%^')
    input = string.gsub(input,'%[','%%[')
    input = string.gsub(input,'%]','%%]')
    return input
end

-- generate route file
function generate_routes(meta) 
	-- mkdir 
	local route_dir = meta.base_dir .. '/auto/route'
	os.execute('mkdir -p ' .. route_dir)
	-- check file exits
	local i = 1
	for _,route in ipairs(meta.routes) do 
		print(intent_1 .. "route " .. "path: " .. route.path .. " appname: " .. route.appname)
		local route_filename = "route_auto_" .. i .. "_entry.lua"
		-- add to route app file list
		route_app_file_list[#route_app_file_list + 1] = route_filename 
		local f = io.open(route_dir .. '/' ..  route_filename, "w")
		local content = string.gsub(code.route_all_code, "{{route_app_name}}", escape(route.appname))			
		f:write(content)
		f:close()
		status.routelist[#status.routelist + 1] = { 
			filename = route_filename, 
			appname = route.appname 
		}
		i = i + 1
	end
end

-- get a list of log files
--function get_log_fields(root) 
--	local fields = {}
--	function reserve_obj(obj) 
--		for k,v in pairs(obj) do
--			if string.match(k,"section") then 
--				reserve_obj(obj.k)
--			elseif k == "fields" then
--				for _,f in ipairs(k) do 
--					fields[#fields + 1] = f
--				end
--			end
--		end
--	end
--	return fields
--end
--
-- generate logs file
function generate_logs(meta) 
	-- mkdir 
	local log_dir = meta.base_dir .. '/auto/logger'
	os.execute('mkdir -p ' .. log_dir)
	for _,log in ipairs(meta.logs) do 
		print(intent_1 .. "log " .. "name: " .. log.name .. " file: " .. log.logfile)
		local content = code.log_all_code
		if check_log then
			-- generate log
			-- replace 	{{check_log_params_function_call}}
			local check_call_code =  [[ 
				check_{{log_name}}_log_params_type(data, ...) 	
				check_{{log_name}}_log_params(params)
			]]	
			--check_call_code = string.gsub(check_call_code, "{{log_name}}", escape(log.name))
			content = string.gsub(content, "{{check_log_params_function_call}}", escape(check_call_code))
			-- {{log_check_code}}
			local check_code_blocks = ''
			for _,tuple in ipairs(log.sections) do
				if tuple.type == "field" then
				check_code_blocks = check_code_blocks .. 
					string.gsub(code.log_check_code, '{{key}}',escape(tuple.value)) .. 
					'\n'
				end
			end
			-- replcace check code placeholder
			content = string.gsub(content, "{{log_check_code}}", escape(check_code_blocks))
		else 
			-- no check
			content = string.gsub(content, "{{log_check_code}}", "")	
			content = string.gsub(content, "{{check_log_params_function_call}}", "")
		end
		-- generate log_url 
		local go_log_url = [[ string.format('/{{log_name}}_log_path?{{log_url_arg_list}}'{{log_url_param_list}}) ]]
		local log_url_param_list = ''
		local log_url_arg_list = ''
		for i,tuple in ipairs(log.sections) do
			if tuple.type == "field" then
				log_url_arg_list = log_url_arg_list .. tuple.value .. '=%s&'
				log_url_param_list = log_url_param_list .. ',\n util.print2log(params[\'' .. tuple.value .. '\'])'
			end
		end
		go_log_url = string.gsub(go_log_url, "{{log_url_arg_list}}", escape(log_url_arg_list))
		go_log_url = string.gsub(go_log_url, "{{log_url_param_list}}", escape(log_url_param_list))
		content = string.gsub(content, "{{log_url_section}}", escape(go_log_url))
		-- replace log name and file name 
		content = string.gsub(content, "{{log_name}}", escape(log.name))
		content = string.gsub(content, "{{log_filename}}", escape(log.logfile))
		-- write to file
		local f = io.open(log_dir .. "/" .. log.name .. "_auto_logger.lua", "w")
		f:write(content)
		f:close()
	end
end

-- generate ngxin conf 
function generate_nginx_conf(meta) 
	local conf_dir = meta.base_dir .. '/auto/nginx_runtime'
	os.execute('mkdir -p ' .. conf_dir)
	local route_sections = ""
	for i,route in ipairs(meta.routes) do
		local route_file = 	meta.base_dir .. '/auto/route/' .. status.routelist[i].filename   
		local route_content = code.nginx_location_section1
		route_content = string.gsub(route_content, "{{route_path}}", escape(route.path))
		route_content = string.gsub(route_content, "{{route_properties}}", escape(route.properties))
		route_content = string.gsub(route_content, "{{route_app_file}}", escape(route_file))
		route_sections = route_sections .. route_content .. '\n'
	end

	local log_sections = ''
	for i,log in ipairs(meta.logs) do 
		local log_format_string = ""	
		local nginx_log_param_list_all = ''
		local nginx_log_param_list = code.nginx_log_param_list
		local log_content = code.nginx_log_location_section1
		for _,tuple in ipairs(log.sections) do
			if tuple.type == "field" then
				log_format_string = log_format_string .. '$r_' .. tuple.value 	
				nginx_log_param_list_all = nginx_log_param_list_all .. 
							string.gsub(nginx_log_param_list, "{{log_param_name}}", escape(tuple.value))
			else 
				log_format_string = log_format_string .. tuple.value 
			end
		end
		log_content = string.gsub(log_content, "{{log_format_string}}", escape(log_format_string))
		log_content = string.gsub(log_content, "{{log_param_list}}", escape(nginx_log_param_list_all))
		log_content = string.gsub(log_content, "{{log_name}}", escape(log.name))
		log_content = string.gsub(log_content, "{{log_file}}", escape(log.logfile))
		log_content = string.gsub(log_content, "{{nginx_log_dir}}", escape(meta.nginx_log_dir))	
		log_sections = log_sections .. log_content
	end
	local template_file = io.open(dodolu_dir .. "/meta/" .. nginx_tmp_file, "r")
	local conf_content = template_file:read("*all")			
	template_file:close()
	conf_content = string.gsub(conf_content, "{{base_dir}}", escape(meta.base_dir))
	conf_content = string.gsub(conf_content, "{{dodolu_route_section}}", escape(route_sections))	
	conf_content = string.gsub(conf_content, "{{dodolu_log_section}}", escape(log_sections))	
	-- mkdir 
	local ngx_dir = meta.base_dir .. '/auto/nginx_runtime'
	os.execute('mkdir -p ' .. ngx_dir)
	local f = io.open(ngx_dir .. "/nginx.conf", "w")
	f:write(conf_content)
	f:close()
end

function begin_codegen() 
	local ok 
	ok, meta = pcall(dofile, dodolu_dir .. "/meta/" .. meta_file)
	if not ok then 
		error("open meta.lua file failure, meta_dir is " .. dodolu_dir .. "/meta/" .. ", meta_file is " .. meta_file)
	end
	--meta = meta_thunk()
	local auto_dir = dodolu_dir .. "/auto"
	os.execute("rm -r " .. auto_dir)
	print("output dir is " .. meta.base_dir .. '/auto')
	if #meta.logs ~= 0 then
		print("begin generating logs files ... ")
		generate_logs(meta)			
	end
	if #meta.routes ~= 0 then
		print("begin generating route files ... ")
		generate_routes(meta)
	end
	print("begin generating nginx.conf ... ")
	generate_nginx_conf(meta)
end

local argv = arg
if arg[1] == '-h' then
	print_help()
	os.exit(1)
end

--local argv = { select(2, ...) }

local i = 0
while i < #arg do
	i = i + 1
	local arg = argv[i]
	if arg == '-p' then
		local optname = arg
		i = i + 1
		local optvalue = argv[i]
		checkarg(optname, optvalue)
		dodolu_dir = optvalue
	elseif arg == '-check_log' then
		local optname = arg
		i = i + 1 
		local optvalue = argv[i]	
		checkarg(optname, optvalue)
		if argv[i] == "on" then
			check_log = true
		end
	elseif arg == "-nginx_filename" then
		local optname = arg
		i = i + 1
		local optvalue = argv[i]
		checkarg(optname, optvalue)
		nginx_tmp_file = optvalue
	elseif arg == "-meta_file" then
		local optname = arg
		i = i + 1
		local optvalue = argv[i]
		checkarg(optname, optvalue)
		meta_file = optvalue	
	end
end

begin_codegen()
os.exit(0)





