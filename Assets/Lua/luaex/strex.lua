--- 字符串
-- Author : canyon / 龚阳辉
-- Date : 2016-05-25 09:25
-- Desc : 重新整理一遍

local tb_insert = table.insert
local tb_remove = table.remove

local str_format = string.format
local str_upper = string.upper
local str_len = string.len
local str_rep = string.rep
local str_find = string.find
local str_gsub = string.gsub
local str_sub = string.sub
local str_byte = string.byte
local str_char = string.char
local str_gmatch = string.gmatch

local _htmlSpecialChars = {
    {"&","&amp;"},
    {" ","&nbsp;"},
    {"\t","    "},
    {"\"","&quot;"},
    {"'","&#039;"},
    {"<","&lt;"},
    {">","&gt;"},
    {"\n","<br />"},
}

function string.toHtml(str,isRestroe)
    for _, v in ipairs(_htmlSpecialChars) do
        if isRestroe == true then
            str = str_gsub(str, v[2], v[1]);
        else
            str = str_gsub(str, v[1], v[2]);
        end
    end
    return str;
end

function string.split(inStr,sep,isFind)
    local _lt = {};
    inStr = tostring(inStr);
    if inStr == nil or inStr == "" then
        return _lt;
    end

    sep = tostring(sep);
    if sep == nil or sep == "" then
        sep = "%s";
    end

    if isFind == true then
        local pos = 1;
        for nBen,nEnd in function() return str_find(inStr, sep, pos, true) end do
            tb_insert(_lt, str_sub(inStr, pos, nBen - 1))
            pos = nEnd + 1
        end
        tb_insert(_lt, str_sub(inStr, pos))
    else
        for str in str_gmatch(inStr, "([^"..sep.."]+)") do
            tb_insert(_lt,str);
        end
    end

    return _lt;
end

function string.contains(src,val)
    local begIndex,endIndex = str_find(src,val);
    local isRet = not (not begIndex);
    return isRet,begIndex,endIndex;
end

function string.replace(inStr,pat,val)
    return str_gsub(inStr,pat,val);
end

function string.ltrim(inStr)
    return str_gsub(inStr, "^[ \t\n\r]+", "")
end

function string.rtrim(inStr)
    return str_gsub(inStr, "[ \t\n\r]+$", "")
end

function string.trim(inStr)
    inStr = string.ltrim(inStr)
    return string.rtrim(inStr)
end

function string.upfirst(inStr)
    return str_upper(str_sub(inStr, 1, 1)) .. str_sub(inStr, 2)
end

function string.lastIndexOf(inStr,sep)
	if not sep or "" == sep or not inStr or "" == inStr then
		return -1;
	end
	local _posLast = str_find(inStr,str_format("%s[^%s]*$",sep,sep));
	return _posLast or -1;
end

function string.lastStr(inStr,sep)
	local _posLast = string.lastIndexOf(inStr,sep)
	if not _posLast or _posLast == -1 then
		return inStr;
	end
	return str_gsub(inStr,str_sub(inStr, 1, _posLast),"");
end

-- 中文也是一个字符
function string.utf8len(src)
    local len  = str_len(src)
    local left,cnt = len,0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local tmp,i;
    while left ~= 0 do
        tmp = str_byte(src, -left)
        i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.toStrByNum(num,lens)
    lens = tonum10(lens,3);
    local fmt = "%0".. lens .. "d";
    return str_format(fmt,num);
end

function string.toStr16( num,isBig)
    local fmt = isBig == true and "%X" or "%x";
    return str_format(fmt,num);
end

function string.toNum16( str )
    return tonum16(str)
end

function string.toColRGB( str )
    str = str_gsub(str,"#","");
    local _lens = #str;
    if _lens ~= 6 and _lens ~= 8 then
        return 0,0,0;
    end

    local _lb = {}
    for i=1,_lens,2 do
        tb_insert(_lb,string.toNum16(str_sub(str,i,i+1)));
    end
    return unpack(_lb);
end

function string.isHasSpace(inStr)
    local _isHas = string.contains(inStr,"[ \t\n\r　]");
	return _isHas;
end