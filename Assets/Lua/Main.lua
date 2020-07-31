
require "tolua"

local _evt
local function evt()
	if not _evt then _evt = Event end
	return _evt
end

function Main()
	reimport("games/game_main").Init()
end

--场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	_evt = evt()
	if _evt then
		_evt.Brocast(Evt_SceneLoaded,level)
		-- printInfo("Event Brocast OnLevelWasLoaded = [%s]",level)
	end
end

function Update(dt,unscaledDt)
	Time:SetDeltaTime(dt,unscaledDt)
	_evt = evt()
	if _evt then
		_evt.Brocast(Evt_Update,dt,unscaledDt);
	end
end

function FixedUpdate(dt,unscaledDt)
	Time:SetFixedDelta(dt,unscaledDt)
	_evt = evt()
	if _evt then
		_evt.Brocast(Evt_FixedUpdate,dt,unscaledDt);
	end
end

function LateUpdate()
	Time:SetFrameCount()
	_evt = evt()
	if _evt then
		_evt.Brocast(Evt_LateUpdate);
	end
end

function OnApplicationQuit()
	_evt = evt()
	if _evt then
		_evt.Brocast(Evt_OnAppQuit);
	end
end

function OnApplicationPause(isPause)
	_evt = evt()
	if _evt then
		_evt.Brocast(Evt_OnAppPause,isPause);
	end
end