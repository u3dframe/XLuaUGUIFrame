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
L_UI = LayerMask.NameToLayer("UI")

-- 场景 - 对象类型
LES_Object = {
	Object         = _add(0),
	MapObj         = _add(), -- 地图
	Creature       = _add(), -- 生物
	Monster        = _add(), -- 怪兽
	Partner        = _add(), -- 伙伴
	Hero           = _add(), -- 英雄
	UIModel        = _add(), -- UI模型
}

LES_Layer = {
	[LES_Object.Object]         =    L_SObj,
	[LES_Object.MapObj]         =    L_SObj,
	[LES_Object.Creature]       =    L_SMonster,
	[LES_Object.Monster]        =    L_SMonster,
	[LES_Object.Partner]        =    L_SPartner,
	[LES_Object.Hero]           =    L_SHero,
	[LES_Object.UIModel]        =    L_UI,
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


-- 人性角色 - 动作枚举
LES_C_Animator_State = {
	None           = -1,
	Idle           = 0,      -- 待机
	Die            = 1,      -- 死亡
	Run            = 2,      -- 跑
	
	Attack_1       = 11,     -- 普攻_1
	Attack_2       = 12,     -- 普攻_2
	Attack_3       = 13,     -- 普攻_3
	
	Skill_Power    = 20,     -- 技能_大招
	Skill_1        = 21,     -- 技能_1
	
	Show_1         = 31,     -- 展示_1
	Show_2         = 32,     -- 展示_2
	
	Grab           = 51,     -- 被拧起
	Lose           = 52,     -- 失败
	Win            = 53,     -- 胜利
	Dizzy          = 54,     -- 眩晕
	Hit_Fly_1      = 55,     -- 击飞
	Hit_Back_2     = 56,     -- 击退
	Hit_Down_3     = 57,     -- 击倒
	Fear           = 58,     -- 恐惧
	Sleep          = 59,     -- 睡眠
}

-- 人性角色 - 状态
LES_C_State = {
	None                 = _add(0),     -- 无
	Idle                 = _add(),      -- 待机
	Idle_Exed            = _add(),      -- 待机_已执行
	Die                  = _add(),      -- 死亡
	Die_Exed             = _add(),      -- 死亡_已执行
	Run                  = _add(),      -- 跑
	Run_Exed             = _add(),      -- 跑_已执行
	Attack_1             = _add(),      -- 普攻_1
	Attack_1_Exed        = _add(),      -- 普攻_1_已执行
	Grab                 = _add(),      -- 被拧起
	Grab_Exed            = _add(),      -- 被拧起_已执行
}