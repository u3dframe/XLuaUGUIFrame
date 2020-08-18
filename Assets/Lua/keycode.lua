local KeyCodeState = {
	KeyDown = 1,
	KeyUp = 2,
	GetKey = 3
}

local _code_keys = {
	"W","A","S","D","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
	"Escape","KeypadPlus","KeypadDivide","KeypadMultiply",
	"UpArrow","DownArrow","LeftArrow","RightArrow","PageUp","PageDown"
}

local M = {}
local function OnGetKey(key)
	
end

local function OnKeyDown(key)
	
end

local function OnKeyUp(key)
	---按键触发的一些调试
	if key == 'F1' then

	elseif key == 'F2' then

	elseif key == 'F3' then

	elseif key == 'F4' then

	elseif key =='F5'  then
		MgrUI.OpenUI(UIType.MainMission)
	elseif key =='F6'  then

	elseif key =='F7'  then

	elseif key =='F8'  then

	elseif key =='F9'  then

	elseif key =='F10'  then

	elseif key == "F11" then
		printTable(MgrScene.GetState())
	elseif key =='F12'  then
		Event.Brocast(Evt_Map_Load,1)
	end
end

local function _OnCall(key,state)
	if state == KeyCodeState.GetKey then
		OnGetKey(key)
	elseif state == KeyCodeState.KeyDown then
		OnKeyDown(key)
	else
		OnKeyUp(key)
	end
end

function M.Init()
	local _CKeyCode = CInpMgr
	for _,v in ipairs(_code_keys) do
		_CKeyCode.RegKeyCode(v,_OnCall);
	end
end

return M