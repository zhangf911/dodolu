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

local logger_provider = {}

local util = require "util"

-- get specific logger from auto generated files
-- if this return error or not work, please check
-- generated file or execute bin/generate.sh again
-- usage:
-- local logger = logger_provider.get_logger("go_log")
-- logger.write(table)
function logger_provider.get_logger(name) 
	-- TODO	
	-- suffix logger name
	local new_name = name .. '_auto_logger'
	local ok, logger = pcall(require, new_name)
	if not ok then 
		error("logger " .. name .. " is not be generated in collect path ")
	end
	return logger
end


return logger_provider

