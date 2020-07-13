--主入口函数。从这里开始lua逻辑
local _evt
local function evt()
	if not _evt then _evt = Event end
	return _evt
end

function Main()
	require("games/game_main").Init()
	-- print("logic start")	 		
end

--场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	_evt = evt()
	if _evt then
		_evt.Brocast(Evt_SceneLoaded,level)
		printInfo("Event Brocast OnLevelWasLoaded = [%s]",level)
	end
end

function Update(dt)
	_evt = evt()
	if _evt then
		_evt.Brocast(Evt_Update,dt);
	end
end

function LateUpdate()
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