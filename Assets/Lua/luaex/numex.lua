--- 数与随机数
-- Author : canyon / 龚阳辉
-- Date : 2016-05-25 09:25
-- Desc : base : 随机数值最大值 , isSeek 是否重置随机种子需要先引起(属于底层基础)
-- math.random([n [, m]]) 无参调用,产生(0,1)之间的浮点随机数,只有参数n,产生1-n之间的整数.
-- math.fmod(x,y) = 取x/y的余数?;math.modf(v) = 取整数,小数
local os,tonumber,tostring,type = os,tonumber,tostring,type
local str_format = string.format
local tb_insert = table.insert
local tb_concat = table.concat

local math = math
local m_random = math.random
local m_randomseed = math.randomseed
local m_floor = math.floor
math.round = math.round or function(val)
	local nVal = m_floor(val)
	local fVal = val;
	if nVal ~= 0 then
		fVal = val - nVal;
	end
	if fVal >= 0.5 then
		nVal = nVal + 1;
	end
	return nVal;
end
local m_round = math.round
local m_modf = math.modf

function math.clamp(v, minValue, maxValue)  
    if v < minValue then
        return minValue
    end
    if( v > maxValue) then
        return maxValue
    end
    return v 
end

if bit then
	bit_band = bit.band; -- 一个或多个无符号整数 '与 &' 运算 得到值
	bit_bor = bit.bor; -- 一个或多个无符号整数 '或 |' 运算 得到值
	bit_shl = bit.shl; -- 两个无符号整数,第一个参数是被移位的数，第二个参数是向左移动的位数
	bit_shr = bit.shr; -- 两个无符号整数,第一个参数是被移位的数，第二个参数是向右移动的位数
	bit_bnot = bit.bnot; -- 取反
end

function isNum(val)
    return type(val) == "number";
end

function tonum(val,base,def)
	def = def or 0;
    return tonumber(tostring(val), base) or def;
end

function tonum16(val,def)
	return tonum(val,16,def);
end

function tonum10(val,def)
	if isNum(val) then return val end
	return tonum(val,10,def);
end

function toint(val,def)
	if not isNum(val) then val = tonum(val,nil,def) end
    return m_round(val)
end

function todecimal(val,acc,def,isRound)
	local _pow = 1
	if isNum(acc) then
		for i = 1,acc do
			_pow = _pow * 10
		end
	end

	local _v = tonum(val,nil,def) * _pow
	_v = (isRound == true) and m_round(_v) or _v
	if _pow > 1 then
		_v = m_floor(_v)
	end
    return _v / _pow
end

function todecimal0(val,def,isRound)
	return todecimal(val,nil,def,isRound)
end

function todecimal2(val,def,isRound)
	return todecimal(val,2,def,isRound)
end

local M = {};
local this = M;

function M.onSeek()
	local _time = os.time();
	local _seed = tostring(_time):reverse():sub(1, 6);
	m_randomseed(_seed);
end

-- 保留小数
function M.retainDecimal(v,fnum)
	fnum = tonum10(fnum,2);
	if fnum > 0 then
		local fmt = "%.".. fnum .. "f"
		v = str_format(fmt, v);
		v = tonum10(v);
	end
	return v;
end

-- 产生 : 小于base的小数
function M.nextFloat(base,isSeek)
	if isSeek == true then
		this.onSeek();
	end
	base = tonum10(base,10000);
	return m_random() * base;
end

-- 产生 : 小于base并保留npos位的小数
function M.nextFloatPos(base,npos,isSeek)
	local _f = this.nextFloat(base,isSeek);
	return this.retainDecimal(_f,npos);
end

-- 产生 : 小于base的两位小数
function M.nextFloatPos2(base,isSeek)
	return this.nextFloatPos(base,2,isSeek);
end

-- 产生 : 整数 [1~base]
function M.nextInt(base,isSeek)
	if isSeek == true then
		this.onSeek();
	end
	base = tonum10(base,10000);
	if base <= 1 then
		return this.nextInt(2);
	end

	return m_random(base);
end

-- 产生 : 整数 [0~base)
function M.nextIntZero(base,isSeek)
	local _r = this.nextInt(base,isSeek);
	return _r - 1;
end

-- 产生 : 整数 [min~max]
function M.nextNum( min,max,isSeek )
	if isSeek == true then
		this.onSeek();
	end
	return m_random(min,max);
end

-- 随机 - bool值
function M.nextBool()
	local _r = this.nextIntZero(2);
	return _r == 1;
end

-- 随机 - 权重的index
function M.nextWeightList( list,wKey )
	local _sum,_nv = 0
	for k,v in ipairs(list) do
		if (not wKey) or (v[wKey]) then
			_nv = tonumber(v) or v[wKey]
			_sum = _sum + _nv
		end
	end
	if _sum > 0 then
		local _r = this.nextInt(_sum)
		local _sum2 = 0
		for k, v in ipairs(list) do
			if (not wKey) or (v[wKey]) then
				_nv = tonumber(v) or v[wKey]
				_sum2 = _sum2 + _nv
				if _sum2 >= _r then
					return k,_r,_sum
				end
			end
		end
	end
	return 0
end

function M.nextWeight( ... )
	local _args = { ... }
	return this.nextWeightList( _args )
end

-- [0-9]随机数连接的字符串长度nlen
function M.nextStr(nlen,isSeek )
	if isSeek == true then
		this.onSeek();
	end
	local val = {};
	for i=1,nlen do
		tb_insert(val,this.nextIntZero(10));
	end
	return tb_concat(val,"");
end

function M.bitOr(n1,n2)
	if bit_bor then
		return bit_bor(n1,n2);
	else
		return (n1 | n2);
	end
end

function M.bitAnd(n1,n2)
	if bit_band then
		return bit_band(n1,n2);
	else
		return (n1 & n2);
	end
end

function M.isBitAnd(n1,n2)
	local _min = n1 > n2 and n2 or n1;
	return this.bitAnd(n1,n2) == _min;
end

-- 左移
function M.bitLeft(org,pos)
	if bit_shl then
		return bit_shl(org,pos);
	else
		return org << pos;
	end
end

-- 右移
function M.bitRight(org,pos)
	if bit_shr then
		return bit_shr(org,pos);
	else
		return org >> pos;
	end
end

-- 取反
function M.bitNot(org)
	if bit_bnot then
		return bit_bnot(org);
	else
		return (~ org);
	end
end

-- 取整数或小数
function M.modDecimal(num,isInt)
	if (num == nil or num == 0) then
		return 0;
	end
	local _i,_d = m_modf(num)
	return (isInt == true) and _i or _d
end

-- 求余数
function M.modf(src,divisor)
	if (src == nil or src == 0) or (divisor == nil or divisor == 0) then
		return 0;
	end
	if src < divisor then
		return src;
	end
	
	local _fl = m_floor(src / divisor);
	return src - (_fl * divisor);
end

-- 是否奇数
function M.isOdd(src)
	local _mf = this.modf(src,2);
	return _mf == 1;
end

-- 是否偶数
function M.isEven(src)
	local _mf = this.modf(src,2);
	return _mf == 0;
end

NumEx = this;

return M;