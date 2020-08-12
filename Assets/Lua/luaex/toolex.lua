--- 工具Ex
-- Author : canyon / 龚阳辉
-- Date : 2018-05-18 10：25
-- Desc : 重新整理一遍

require("luaex/numex")
require("luaex/strex")
require("luaex/tabex")
require("luaex/timeex")

local _fmtColor = "<color=#%s>%s</color>";

local table = table
local tb_insert = table.insert
local tb_sort = table.sort
local tb_keys = table.keys
local tb_lens = table.lens
local tb_concat = table.concat

local str_format = string.format
local str_gsub = string.gsub
local str_rep = string.rep
local str_byte = string.byte

local package,type = package,type
local _pcall,_xpcall,_deTrk = pcall,xpcall,debug.traceback
local _print,_printError = print

local _unpack = unpack or table.unpack
function unpack( arg )
	if _unpack then
		return _unpack(arg)
	end
end

function setPErrorFunc( pErrorFunc )
	_printError = pErrorFunc
end

function do_pcall( isLog,method,obj,... )
	local _ok,_err
	if obj then
		_ok,_err = _pcall( method,obj,... )
	else
		_ok,_err = _pcall( method,... )
	end
	if (not _ok) and (isLog == true) and _printError then
		_printError("====[%s].[%s] , error = %s",obj,method,_err)
	end
	return _ok,_err
end

function exc_pcall( method,obj,... )
	return do_pcall( true,method,obj,... )
end

function do_xpcall( isLog,method,obj,... )
	local _ok,_err
	if obj then
		_ok,_err = _xpcall( method,_deTrk,obj,... )
	else
		_ok,_err = _xpcall( method,_deTrk,... )
	end

	if (not _ok) and (isLog == true) and _printError then
		_printError("====[%s].[%s] , error = %s",obj,method,_err)
	end
	return _ok,_err
end

function exc_xpcall( method,obj,... )
	return do_xpcall( true,method,obj,... )
end

function handler( obj, method )
    return function( ... )
        return method( obj, ... )
    end
end

function handler_pcall( obj, method )
	return function( ... )
		exc_pcall( method,obj,... )
    end
end

function handler_xpcall( obj, method )
	return function( ... )
		exc_xpcall( method,obj,... )
    end
end

function callFunc( funcName )
	return function ( ... )
		local arg = {...}
		return function ( self )
			if self[funcName] then
				self[funcName]( self, unpack( arg ) )
			else
				error( "can't find function by name %s in table=[%s]", funcName,self.name or self );
			end
		end
	end
end

local function _appendHeap( src )
	return str_format("%s\n%s",src,_deTrk());
end

local function _sort_key( a,b )
	return str_byte(a) < str_byte(b);
end

local _pfunc = nil;
function setPTabFunc( pfunc )
	_pfunc = pfunc;
end

function printTable( tb,title,rgb,notSort )
	rgb = rgb or "09f68f";
	if not tb or type(tb) ~= "table" then
		title = str_format(_fmtColor,rgb,tb)
	else
		local tabNum = 0;
		local function stab( numTab )
			return str_rep("    ", numTab);
		end
		local str = {};
		local _dic,_str_temp = {};

		local function _printTable( t )
			tb_insert( str, "{" )
			tabNum = tabNum + 1

			local keys = tb_keys(t);
			if not notSort then tb_sort(keys,_sort_key); end

			local v,kk,ktp,vtp;
			for _, k in pairs( keys ) do
				v = t[ k ]
				ktp = type(k)
				vtp = type(v)
				if ktp == "string" then
					kk = "['" .. k .. "']"
				else
					kk = "[" .. tostring(k) .. "]"
				end
				_str_temp = tostring(v)
		
				if (vtp == "table") and (not _dic[_str_temp]) then
					_dic[_str_temp] = true;
					tb_insert( str, str_format('\n%s%s = ', stab(tabNum),kk))
					_printTable( v )
				else
					if vtp == "string" then
						vv = str_format("\"%s\"", v)
					elseif vtp == "number" or vtp == "boolean" or vtp == "table" then
						vv = _str_temp
					else
						vv = "[" .. vtp .. "]"
					end

					if ktp == "string" then
						tb_insert( str, str_format("\n%s%-18s = %s,", stab(tabNum), kk, str_gsub(vv, "%%", "?") ) )
					else
						tb_insert( str, str_format("\n%s%-4s = %s,", stab(tabNum), kk, str_gsub(vv, "%%", "?") ) )
					end
				end
			end
			tabNum = tabNum - 1

			if tabNum == 0 then
				tb_insert( str, '}' )
			else
				tb_insert( str, '},' )
			end
		end

		title = str_format("%s = %s",(title or ""),tb);
		tb_insert( str, str_format("\n=== beg [%s]--[%s]\n", title, os.date("%H:%M:%S") )  )
		_str_temp = tostring(tb)
		_dic[_str_temp] = true;
		_printTable( tb )
		tb_insert( str, str_format("\n=== end [%s]--\n", title))

		title = tb_concat(str, "")
		title = str_format(_fmtColor,rgb,title)
	end

	if type(_pfunc) == "function" then
		_pfunc(title)
	else
		title = _appendHeap(title)
		_print(title)
	end
end

local function _lfNewIndex ( t,k,v )
	error(str_format("[%s] is a read-only table",t.name or t),2);
end

function readonly( tb )
	local _ret = {};
	local _mt = {
		__index = tb,
		__newindex = _lfNewIndex,
	}
	setmetatable(_ret,_mt);
	return _ret;
end

function extends( src,parent )
	setmetatable(src,{__index = parent});
	return src;
end

function weakTB( weakKey,objIndex )
	if weakKey ~= "k" and weakKey ~= "v" and weakKey ~= "kv" then
		weakKey = "v"
	end
	return setmetatable({},{ __mode = weakKey,__index = objIndex })
end

function clearLoadLua( luapath )	
	package.loaded[luapath] = nil
	package.preload[luapath] = nil
end

if not reimport then
	--重新require一个lua文件，替代系统文件。
	function reimport(name)
		clearLoadLua(name)
		return require(name)    
	end
end

------ 排序相关 -----
local function _quickSortBase(p)
	if p == nil or p.h >= p.t then return end

	local head,tail
	head = p.h
	tail = p.t
	local key = p.ka[head]
	local left,right
	
	left,right = head,tail
	
	while left < right do
		while (left <right) and p.f(p.a[p.ka[right]],p.a[key]) >= 0 do
			right = right - 1
		end
		p.ka[left] = p.ka[right]
		
	
		while (left < right) and p.f(p.a[p.ka[left]] ,p.a[key]) < 0 do
			left = left + 1
		end
		p.ka[right] = p.ka[left]
	end
	p.ka[left] = key


	p.h = head
	p.t = left - 1
	_quickSortBase(p)
	p.h = left + 1
	p.t = tail
	_quickSortBase(p)
end 

local function _quickSort( a, head, tail, f )
	if head >= tail then
		return
	end

	local key = a[head]
	local left,right
	
	left,right = head,tail
	
	while left < right do
		while (left <right) and f(a[right],key) >= 0 do
			right = right - 1
		end
		a[left] = a[right]
		
	
		while (left < right) and f(a[left] ,key) < 0 do
			left = left + 1
		end
		a[right] = a[left]
	end
	a[left] = key

	_quickSort( a, head, left - 1, f )
	_quickSort( a, left + 1,tail, f )
end

local function _quickSort2(a,f)
	local ka = {}
	for k, v in pairs( a ) do
		tb_insert( ka, k )
	end
	local p = {}
	p.a = a
	p.ka = ka
	p.h = 1
	p.t = tb_lens(ka)
	p.f = f
	_quickSortBase(p)
	return ka
end

-- fields 是 array中对象tab的key值,如果对象前面加 "-" 标识排倒叙
function sortArrayByField( array, fields )
	-- 重载，允许只有一个字符串
	if type( fields ) == "string" then
		fields = { fields }
	end

	-- 处理一次fields
	local fieldConfig = {}
	for _, v in pairs( fields ) do
		if string.sub( v, 1, 1 ) == "-" then
			tb_insert( fieldConfig, { string.sub( v, 2, string.len( v ) ), true } )
		else
			tb_insert( fieldConfig, { v, false } )
		end
	end

	-- 按照优先级进行排序
	local sorter = function( a, b )
		local ret = 0

		for _, v in pairs( fieldConfig ) do
			local field, desc = v[1], v[2]

			local v1, v2 = a[field], b[field]
			if v1 then
				if desc then
					ret = v2 - v1
				else
					ret = v1- v2
				end

				if ret ~= 0 then
					return ret
				end
			end
		end
		return ret
	end

	local sortd = {}
	local keys = _quickSort2( array, sorter )

	for _, v in pairs( keys ) do
		tb_insert( sortd, array[ v ] )
	end

	return sortd
end

-- lensPars
function lens4Variable( ... )
	return select( '#', ... )
end