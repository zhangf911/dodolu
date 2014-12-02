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
--
-- this module support some util function useful in web development

local util = {}

local next = next or _G.next

-- generate UUID in string format
function util.UUID() 
	if pcall(require,'UUID') then 
		return UUID.UUID()
	else 
		error('library UUID is is not in package path')	
	end
end


-- t = nil will return true
-- t = ''  will return false
-- t = {}  will return true
-- t = {1} will return false
function util.is_nil(t) 
	if (type(t) ~= 'table') then
		return t == nil
	end

	if (t == nil) then
		return true
	else 
		return next(t) == nil
	end
end

function util.is_notnil(t)
	return util.is_nil(t) == false
end

-- php favorite print_r for lua
function util.print_r(obj) 
local getIndent, quoteStr, wrapKey, wrapVal, isArray, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        str = string.gsub(str, "[%c\\\"]", {
             ["\t"] = "\\t",
             ["\r"] = "\\r",
             ["\n"] = "\\n",
             ["\""] = "\\\"",
             ["\\"] = "\\\\",
        })
        return '"' .. str .. '"'
	end
  	wrapKey = function(val)
    	if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
    	else
      		return "[" .. tostring(val) .. "]"
    	end
  	end
	wrapVal = function(val, level)
		if type(val) == "table" then
		  return dumpObj(val, level)
		elseif type(val) == "number" then
		  return val
		elseif type(val) == "string" then
		  return quoteStr(val)
		else
		  return tostring(val)
		end
	end
	local isArray = function(arr)
		local count = 0
		for k, v in pairs(arr) do
		  count = count + 1
		end
		for i = 1, count do
		  if arr[i] == nil then
			return false
		  end
		end
		return true, count
	end
	dumpObj = function(obj, level)
		if type(obj) ~= "table" then
		  return wrapVal(obj)
		end
		level = level + 1
		local tokens = {}
		tokens[#tokens + 1] = "{"
		local ret, count = isArray(obj)
		if ret then
		  for i = 1, count do
			tokens[#tokens + 1] = getIndent(level) .. wrapVal(obj[i], level) .. ","
		  end
		else
		  for k, v in pairs(obj) do
			tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
		  end
		end
		tokens[#tokens + 1] = getIndent(level - 1) .. "}"
		return table.concat(tokens, "\n")
	end
	return dumpObj(obj, 0)	
end

-- this function is used in log
-- if obj is nil, then output ''
function util.print2log(obj) 
	if obj == nil then
    	return ''
  	elseif type(obj) == 'string' then
  		return obj
  	else
    	return util.print_r(obj)
  	end	
end

-- split string into a array table
function util.split(szFullString, szSeparator)
	if szFullString == nil then
		return nil
	end
	if szSeparator == nil then
		return szFullString
	end
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
	   if not nFindLastIndex then
	       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
		   break
	   end
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)
	   nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end

-- merge table 
function util.merge_table(table1, ...) 
	local args = { ... }
	if #args == 0 then
		return table1 
	end 
	table1 = table1 or {}
	for _,t in ipairs(args) do
		for k,v in pairs(t) do
			table1[k] = v
		end
	end
	return table1
end

-- sha1 encode, return string result 
function util.sha1(str)
	local hexstr = ''
	if not str or str == nil then
		return nil
	end
	local s = ngx.sha1_bin(str)
	local s_len = string.len(s)
	for i=1, s_len do
		local charcode = tonumber(string.byte(s, i,i))
		hexstr = hexstr .. string.format("%02x", charcode)
	end
	return hexstr
end

-- sha1 encode, return binary
function util.sha1_bin(str) 
	if not str or str == nil then
		return nil
	end
	return ngx.sha1_bin(str)
end

-- base64 encode
function util.base64_encode(str)
	if not str or str == nil then
		return nil
	end
	return ngx.encode_base64(str)
end

-- base64 decode
function util.base64_decode(str)
	if not str or str == nil then
		return nil
	end
	return ngx.decode_base64(str)
end

-- encode args
function util.encode_args(table) 
	return ngx.encode_args(table)
end

-- decode args
function util.decode_args(args, max_args) 
	return ngx.decode_args(args, max_args)
end

-- md5 
function util.md5(str) 
	return ngx.md5(str)
end

-- escape_uri
function util.escape_uri(url) 
	return ngx.escape_uri(url)
end

-- unescape_uri
function util.unescape_uri(url) 
	return ngx.unescape_uri(url)
end

-- time
function util.time()
	return ngx.time()
end

-- now
function util.now() 
	return ngx.now()
end

-- get mothed
-- return "GET" "POST" "PUT" "DELETE"
function util.get_method() 
	return ngx.req.get_method()
end

-- set mothed 
-- param is ngx.status.GET etc.
function util.set_method(method_id)
	return ngx.req.set_method(method_id)
end

-- copy from other project 
-- fix me
function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

util.new_tab = new_tab 

return util

