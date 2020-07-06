--主入口函数。从这里开始lua逻辑
function Main()
	require("games/game_main").Init()
	-- print("logic start")	 		
end

--场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	if Event then
		Event.Brocast(Evt_SceneLoaded,level)
		print("Event Brocast OnLevelWasLoaded")	 
	end
end

function Update(dt)
	Event.Brocast(Evt_Update,dt);
end

function LateUpdate()
end

function OnApplicationQuit()
end