local _k_increase = 0
local function _add(rVal)
	if rVal then
		_k_increase = rVal
	else
		_k_increase = _k_increase + 1
	end
	return _k_increase
end

L_SObj = LayerMask.NameToLayer("SceneObj")
L_SGround = LayerMask.NameToLayer("Ground")
L_SMonster = LayerMask.NameToLayer("Monster")
L_SPartner = LayerMask.NameToLayer("Partner")
L_SHero = LayerMask.NameToLayer("Hero")

-- 场景 - 对象类型
LES_Object = {
	Object         = _add(0),
	MapObj         = _add(), -- 地图
	Creature       = _add(), -- 生物
	Monster        = _add(), -- 怪兽
	Partner        = _add(), -- 伙伴
	Hero           = _add(), -- 英雄
}

LES_Layer = {
	[0]         =    L_SObj,
	[1]         =    L_SObj,
	[2]         =    L_SMonster,
	[3]         =    L_SMonster,
	[4]         =    L_SPartner,
	[5]         =    L_SHero,
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

