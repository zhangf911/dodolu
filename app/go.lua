local go = {}

local _util = require "util"

function go.do_get(ctx) 
	local response = ctx.response
	local request = ctx.request
	local cookie = ctx.cookie
	response:set_content_type("text/html")
	local view_model = {test=22}
	response:render_tpl("go.html", view_model)
	response:close()
end

function go.do_post(ctx) end
function go.do_put(ctx) end
function go.do_delete(ctx) end
return go 

