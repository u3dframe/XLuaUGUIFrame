--- 时间Ex
-- Author : canyon / 龚阳辉
-- Date : 2016-05-25 09:25
-- DeSc : 

local os = os
local os_time = os.time
local os_date = os.date
local os_difftime = os.difftime

local math = math
local math_round = math.round
local math_floor = math.floor

local _lbDTime = { year = 0, month = 0, day = 0, hour = 0, min = 0, sec = 0};
local M = {};
local this = M;

local function _ReDTime(year,month,day,hour,minute,second)
  _lbDTime.year = year or 2019;
  _lbDTime.month = month or 1;
  _lbDTime.day = day or 1;
  _lbDTime.hour = hour or 0;
  _lbDTime.min = minute or 0;
  _lbDTime.sec = second or 0;
  return _lbDTime;
end

function M.getTime( year,month,day,hour,minute,second )
  if (year and month) and (day or hour or minute or second) then
    return os_time(_ReDTime(year,month,day,hour,minute,second));
  end
  return os_time();
end

-- 取得当前时间(单位:second)
function M.getCurrentTime()
  local _val = this.getTime() + this.DIFF_SEC;
  return math_round(_val);
end

-- 相差时间秒 = (t2-t1)
function M.diffSec(t1Sec,t2Sec)
  t2Sec = t2Sec or this.getCurrentTime();
  t1Sec = t1Sec or this.getZeroTime(t2Sec);
  return os_difftime(t2Sec,t1Sec);
end

function M.format(sec,fmtStr)
	sec = sec or this.getCurrentTime();
	fmtStr = fmtStr or "%Y%m%d";
	return os_date(fmtStr,sec);
end

function M.getDate(sec)
  sec = sec or this.getCurrentTime();
  return this.format(sec,"*t");
end

-- 零点时间
function M.getZeroTime( sec )
  local _dt = this.getDate(sec);
  return this.getTime(_dt.year,_dt.month,_dt.day);
end

-- 取得当前时间的yyyyMMdd
function M.getYyyyMMdd()
  return this.format();
end

-- 服务器差值时间
function M.setDiffSec( diffSec )
  this.DIFF_SEC = diffSec or 0;
end

-- 时分秒
function M.getHMS( ms )
  local hh,mm,ss = 0,0,0;
  hh = math_floor( ms / this.HOUR );
  
  ms = ms % this.HOUR;
  mm = math_floor( ms / this.MINUTE );

  ms = ms % this.MINUTE;
  ss = math_floor(ms / this.SECOND);
  return hh,mm,ss;
end

-- 天时分秒
function M.getDHMS( ms )
  local dd = math_floor( ms / this.DAY );

  ms = ms % this.DAY;
  local hh,mm,ss = this.getHMS(ms);
  return hh,mm,ss,dd;
end

function M.getHMSBySec( sec )
  return this.getHMS(sec * this.SECOND)
end

function M.getDHMSBySec( sec )
  return this.getDHMS(sec * this.SECOND)
end

function M.addDHMS( day,hour,minute,second,isZero )
  local _val = (isZero == true) and this.getZeroTime() or this.getCurrentTime()
  _val = _val + this.toSec((day or 0) * this.DAY + (hour or 0) * this.HOUR + (minute or 0) * this.MINUTE + (second or 0) * this.SECOND);
  return _val;
end

function M.addDay( day,isZero )
  return this.addDHMS(day,0,0,0,isZero);
end

function M.addHour( hour,isZero )
  return this.addDHMS(0,hour,0,0,isZero);
end

function M.addMinue( minute,isZero )
  return this.addDHMS(0,0,minute,0,isZero);
end

function M.addSecond( second,isZero )
  return this.addDHMS(0,0,0,second,isZero);
end

-- 与0点的时间差
function M.getDiffZero( second )
  return this.diffSec(nil,second);
end

function M.toMS( sec )
  return sec * this.SECOND
end

function M.toSec( ms )
  return ms * this.TO_SECOND
end

this.MS = 1;
this.TO_SECOND = 0.001;
this.SECOND = this.MS * 1000;
this.MINUTE = this.SECOND * 60;
this.HOUR = this.MINUTE * 60;
this.DAY = this.HOUR * 24;
this.WEEK = this.DAY * 7;
this.DIFF_SEC = 0; -- 相差时间(秒)
TimeEx = this;

return M;