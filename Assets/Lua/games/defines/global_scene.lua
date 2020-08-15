-- 场景 - 对象类型
LES_Object = {
	Object         = 1,
	Creature       = 2, -- 生物
	Monster        = 3, -- 怪兽
	Partner        = 4, -- 伙伴
	Hero           = 5, -- 英雄
}

-- 场景 - 状态
LES_State = {
    None = 0,
	Wait_Vw_Loading = 1,
	Clear_Pre_Map_Objs = 2,
	Clear_Pre_Map_Scene = 3,
	Load_Scene = 4,
	Wait_Loading_Scene = 5,
	Load_Map_Scene = 6,
	Load_Map_Objs = 7,
	Complete = 8,
	FinshedEnd = 9,
}