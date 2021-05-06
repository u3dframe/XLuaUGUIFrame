--- 字符串
-- Author : canyon / 龚阳辉
-- Date : 2016-05-25 09:25
-- Desc : 重新整理一遍

local tonumber,tostring,type = tonumber,tostring,type
local error = error

local tb_insert = table.insert
local tb_remove = table.remove
local tb_join = table.concat

local string = string
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

local math = math

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

local function checkstring(str)
    if type(str) ~= "string" then
        str = tostring(str)
    end
    return str
end

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

function string.split(inStr,sep,sepType,useType)
    local _lt = {};
    inStr = tostring(inStr);
    if inStr == nil or inStr == "" then
        return _lt;
    end

    if sep == nil or sep == "" then
        sep = "%s";
    else
        sep = tostring(sep);
    end
    
    if (not sepType) then
        sep = "([^"..sep.."]+)";
    elseif sepType == 1 then
        sep = "[^"..sep.."]+";
    end

    if useType == 1 then
        local pos = 1;
        for nBen,nEnd in function() return str_find(inStr, sep, pos, true) end do
            tb_insert(_lt, str_sub(inStr, pos, nBen - 1))
            pos = nEnd + 1
        end
        tb_insert(_lt, str_sub(inStr, pos))
    elseif useType == 2 then
        str_gsub(inStr,sep,function ( w )
            tb_insert(_lt,w)
        end)
    else
        for str in str_gmatch(inStr, sep) do
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

function string.starts(src,sbeg)
    return str_sub(src,1,str_len(sbeg)) == sbeg
 end
 
function string.ends(src,send)
    return send == '' or str_sub(src,-str_len(send)) == send
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
    if not inStr then
        return ""
    end
    inStr = tostring(inStr)
    inStr = str_gsub(inStr,"^%s*(.-)%s*$","%1")
    return inStr
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

function string.csFmt2Luafmt(inStr)
    if not inStr then return "" end
    local _sbeg = string.starts
    local _send = string.ends
    local _ss = string.split(inStr,"{%d}") -- {%d([^:[D]?[%d]*])?}
    _ss = tb_join(_ss,"%s")
    if _sbeg(inStr,"{0}") then
        _ss = "%s" .. _ss
    end
    local _end = str_sub(inStr,-3)
    if _sbeg(_end,"{") and _send(_end,"}") then
        _ss = _ss .. "%s"
    end
	return _ss;
end

function string.insert(s1, pos, s2)
    s1 = checkstring(s1)
    if not s2 then
        return s1
    end
    s2 = checkstring(s2)
    pos = pos or 1
    local len = str_len(s1)
    if pos <= 1 then
        return s2 .. s1
    elseif pos >= len + 1 then
        return s1 .. s2
    end
    local pre, suf = str_sub(s1, 1, pos - 1), str_sub(s1, pos, len)
    return pre .. s2 .. suf
end

function string.utf8insert(s1, pos, s2)
    s1 = checkstring(s1)
    if not s2 then
        return s1
    end
    s2 = checkstring(s2)
    pos = pos or 1
    local utf8 = utf8
    local utf8len = utf8.len(s1)
    local len = str_len(s1)
    if pos <= 1 then
        return s2 .. s1
    elseif pos >= utf8len + 1 then
        return s1 .. s2
    end
    local m = utf8.offset(s1, pos)
    local pre, suf = str_sub(s1, 1, m - 1), str_sub(s1, m, len)
    return pre .. s2 .. suf
end

function string.remove(s1, pos, num)
    if not s1 then
        error("the argument#1 is nil!")
    end
    local len = str_len(s1)
    pos = pos or 1
    num = num or len
    if pos <= 1 then
        pos = 1
    elseif pos >= len + 1 then
        return s1
    end
    if num <= 0 then
        return s1
    end
    if pos == 1 and num >= len then
        return ""
    end
    local m = math.min(pos + num, len)
    local pre, suf = str_sub(s1, 1, pos - 1), str_sub(s1, m, len)
    return pre .. suf
end

function string.utf8remove(s1, pos, num)
    if not s1 then
        error("the argument#1 is nil!")
    end
    local utf8 = utf8
    local utf8len = utf8.len(s1)
    local len = str_len(s1)
    pos = pos or 1
    num = num or utf8len
    if pos <= 1 then
        pos = 1
    elseif pos >= utf8len + 1 then
        return s1
    end
    if num <= 0 then
        return s1
    end
    if pos == 1 and num >= utf8len then
        return ""
    end
    local m1 = utf8.offset(s1, pos)
    local m2 = utf8.offset(s1, math.min(pos + num, utf8len + 1))
    local pre, suf = str_sub(s1, 1, m1 - 1), str_sub(s1, m2, len)
    return pre .. suf
end

function string.utf8reverse(str)
    if not str then
        error("the argument#1 is nil!")
    end
    if str == "" then
        return str
    end
    local utf8 = utf8
    local array = { utf8.codepoint(str, utf8.offset(str, 1), utf8.offset(str, -1)) }
    local rArray = {}
    local len = #array
    for i = len, 1, -1 do
        rArray[len - i + 1] = array[i]
    end
    return utf8.char(unpack(rArray))
end