local _k_increase = 0
local function _add(rVal)
	if rVal then
		_k_increase = rVal
	else
		_k_increase = _k_increase + 1
	end
	return _k_increase
end

-- 场景 - 对象类型
LES_Object = {
	Object         = _add(0),
	MapObj         = _add(), -- 地图对象
	Creature       = _add(), -- 生物
	Monster        = _add(), -- 怪兽
	Partner        = _add(), -- 伙伴
	Hero           = _add(), -- 英雄
}

-- 场景 - 状态
LES_State = {
    None                 = _add(0),
	Wait_Vw_Loading      = _add(),
	Clear_Pre_Map_Objs   = _add(),
	Clear_Pre_Map_Scene  = _add(),
	Load_Scene           = _add(),
	Wait_Loading_Scene   = _add(),
	Load_Map_Scene       = _add(),
	Load_Map_Objs        = _add(),
	Complete             = _add(),
	FinshedEnd           = _add(),
}