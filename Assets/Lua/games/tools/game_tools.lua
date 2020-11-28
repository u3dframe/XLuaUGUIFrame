--[[
	-- 游戏的公共函数 func
	-- Author : canyon / 龚阳辉
	-- Date : 2020-06-27 13:25
	-- Desc : 
]]
local str_upper = string.upper
local str_format = string.format
local str_len = string.len
local tb_insert = table.insert
local tb_concat = table.concat
local _deTrk = debug.traceback
local _sel = select

local DE_BUG,_isTrace = nil,true;  -- 是否包含 traceback
local _error,_print = error,print;
local _n_mix_lens = 3200

function lensPars( ... )
	return _sel( '#', ... )
end

function logMust(fmt,...)
	local str = tostring(fmt)
	if lensPars( ... ) > 0 then
		str = str_format( str , ... )
	end
	CHelper.Log(str)
end

function printLog(tag, fmt, ...)
	local _isEditor = (GM_IsEditor == true)
	if DE_BUG == nil then
		if CDebug then
			DE_BUG = CDebug.useLog
		else
			DE_BUG = _isEditor
		end
		_isTrace = _isEditor
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
	
	if lensPars( ... ) > 0 then
		tb_insert(t, str_format(tostring(fmt), ...))
	else
		tb_insert(t, tostring(fmt))
	end

    if _isErr or _isThr or _isTrace then
        tb_insert(t, _deTrk("", 3))  -- 打印要少前3行数据
	end
	str = tb_concat(t)

	if _isEditor then
		local _lens = str_len(str)
		if _n_mix_lens < _lens and string.contains(str,"=== beg ") then
			local _fp = str_format("../%s_%s.txt",TimeEx.getYyyyMMdd(),NumEx.nextStr(5))
			CGameFile.WriteText(_fp,str)
			-- _fp = _fp .. _deTrk("", 3)
			CHelper.Log("In _resRoot To See : " .. _fp)
			return
		end
	end

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

function print(fmt,...)
	-- _print
	printInfo("请用 printInfo 打印")
end