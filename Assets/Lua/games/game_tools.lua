--[[
	-- 游戏的公共函数 func
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local str_upper = string.upper
local str_format = string.format
local tb_insert = table.insert
local tb_concat = table.concat
local d_traceback = debug.traceback

local DE_BUG = nil;
local _error = error;
local _isTrace = false -- 是否包含 traceback

function logMust(fmt,...)
	local str = tostring(fmt)
	if #({...}) > 0 then
		str = str_format( str , ... )
	end
	CHelper.Log(str)
end

function printLog(tag, fmt, ...)
	if DE_BUG == nil then
		if CDebug then
			DE_BUG = CDebug.useLog
		else
			DE_BUG = GM_IsEditor == true
		end
	end
	local _isErr,str = tag == "ERR";
	local _isThr = tag == "THR";
	if (not _isErr) and (not _isThr) and (not DE_BUG) then
		return
	end

    local t = {
        "[",
        str_upper(tostring(tag)),
        "] "
	}
	
	if #({...}) > 0 then
		tb_insert(t, str_format(tostring(fmt), ...))
	else
		tb_insert(t, tostring(fmt))
	end

    if _isErr or _isThr or _isTrace then
        tb_insert(t, d_traceback("", 3))  -- 打印要少前3行数据
	end
	str = tb_concat(t)
	if _isErr then
		CHelper.LogError(str)
	elseif _isThr then
		if _error then
			_error(str,1)
		else
			CHelper.ThrowError(str);
		end
	else
		CHelper.Log(str)
	end
end

function printError(fmt, ...)
    printLog("ERR", fmt, ...)
end

function printInfo(fmt, ...)
	printLog("INFO", fmt, ...)
end
  
function printWarn(fmt, ...)
	printLog("WARN", fmt, ...)
end

function error(fmt,...)	
	printLog("THR", fmt, ...)
end