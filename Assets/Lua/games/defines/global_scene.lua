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
L_SHero = LayerMask.NameToLayer("Hero")
L_SPartner = LayerMask.NameToLayer("Partner")
L_SMPartner = LayerMask.NameToLayer("M_Partner")
L_UI = LayerMask.NameToLayer("UI")
L_CG = LayerMask.NameToLayer("CG")

-- 场景 - 对象类型
LES_Object = {
	Object         = _add(0),
	MapObj         = _add(), -- 地图
	Creature       = _add(), -- 生物
	Monster        = _add(), -- 怪兽
	Hero           = _add(), -- 英雄
	Partner        = _add(), -- 伙伴
	MPartner       = _add(), -- 怪物的伙伴
	UIModel        = _add(), -- UI模型
	CG             = _add(), -- CG
}

LES_Layer = {
	[LES_Object.Object]         =    L_SObj,
	[LES_Object.MapObj]         =    L_SObj,
	[LES_Object.Creature]       =    L_SMonster,
	[LES_Object.Monster]        =    L_SMonster,
	[LES_Object.Hero]           =    L_SHero,
	[LES_Object.Partner]        =    L_SPartner,
	[LES_Object.MPartner]       =    L_SMPartner,
	[LES_Object.UIModel]        =    L_UI,
	[LES_Object.CG]             =    L_CG,
}

-- 场景 - 状态
LES_State = {
    None                     = _add(0),
	Wait_Vw_Loading          = _add(),
	Clear_Pre_Map_Objs       = _add(),
	Clear_Pre_Map_Scene      = _add(),
	Load_Scene               = _add(),
	Wait_Loading_Scene       = _add(),
	Load_Map_Scene           = _add(),
	Load_Map_Objs            = _add(),
	Complete                 = _add(),
	FinshedEnd               = _add(),
}

-- 场景 - 战斗 - 状态
LES_Battle_State = {
	None                     = _add(100),
	Start                    = _add(),

	Create_Objs              = _add(),
	LoadOtherObjs            = _add(),

	Entry_CG                 = _add(),
	Entry_CG_Ing             = _add(),
	Entry_CG_End             = _add(),
	
	Play_BG                  = _add(),
	Ready                    = _add(),
	Ready_Ing                = _add(),
	GO                       = _add(),
	Battle_End               = _add(),
	Battle_Error             = _add(),
	End                      = _add(),
}

-- 人性角色 - 动作枚举
LES_C_Action_State = {
	None           = -1,
	Idle           = 0,      -- 待机
	Die            = 1,      -- 死亡
	Run            = 2,      -- 跑
	
	Attack_1       = 11,     -- 普攻_1
	Attack_2       = 12,     -- 普攻_2
	Attack_3       = 13,     -- 普攻_3
	
	Skill_Power    = 20,     -- 技能_大招
	Skill_1        = 21,     -- 技能_1
	Skill_2        = 22,     -- 技能_2
	Skill_3        = 23,     -- 技能_3
	
	Show_1         = 31,     -- 展示_1
	Show_2         = 32,     -- 展示_2
	Show_3         = 33,     -- 展示_3
	
	Grab           = 51,     -- 被拧起
	Lose           = 52,     -- 失败
	Win            = 53,     -- 胜利
	Dizzy          = 54,     -- 眩晕
	Hit_Fly_1      = 55,     -- 击飞
	Hit_Back_2     = 56,     -- 击退
	Hit_Down_3     = 57,     -- 击倒
	Fear           = 58,     -- 恐惧
	Sleep          = 59,     -- 睡眠
	StandUp        = 60,     -- 站起来
}

-- Animator的层级Layer
LES_Ani_Layer = {
	BaseLayer     = 0,
	[0]           = "BaseLayer",
}

-- Animator 的 State 名
LES_Ani_State = {
	[LES_C_Action_State.Idle]        = "idle",
	[LES_C_Action_State.Die]         = "die",
	[LES_C_Action_State.Run]         = "run",
	[LES_C_Action_State.Attack_1]    = "attack_1",
	[LES_C_Action_State.Attack_2]    = "attack_2",
	[LES_C_Action_State.Attack_3]    = "attack_3",
	[LES_C_Action_State.Skill_Power] = "skill_power",
	[LES_C_Action_State.Skill_1]     = "skill_1",
	[LES_C_Action_State.Show_1]      = "show_1",
	[LES_C_Action_State.Show_2]      = "show_2",
	[LES_C_Action_State.Grab]        = "grab",
	[LES_C_Action_State.Lose]        = "lose",
	[LES_C_Action_State.Win]         = "win",
	[LES_C_Action_State.Dizzy]       = "dizzy",
	[LES_C_Action_State.Hit_Fly_1]   = "fall_1",
	[LES_C_Action_State.Hit_Back_2]  = "fall_2",
	[LES_C_Action_State.Hit_Down_3]  = "fall_3",
	[LES_C_Action_State.Fear]        = "fear",
	[LES_C_Action_State.Sleep]       = "sleep",
}

-- 人性角色 - 状态
LES_C_State = {
	None                 = _add(1000),     -- 无
	Idle                 = _add(),      -- 待机
	Die                  = _add(),      -- 死亡
	Run                  = _add(),      -- 跑
	Grab                 = _add(),      -- 被拧起
	Show_1               = _add(),      -- 展示1
	Attack               = _add(),      -- 攻击
}

-- 人性角色 - 状态 转为 动作Action状态
LES_C_State_2_Action_State = {}

-- 人性角色 - flag 控制
LES_C_Flag = {
	None                     = _add(0),
	Dead                     = _add(),
	No_Idle                  = _add(),
	No_Run                   = _add(),
	No_Attack                = _add(),
	No_Skill                 = _add(),
	-- Total                    = _add(),
} 

-- flag 控制 - 子状态
LES_C_Flag_No_Sub = {
	No                       = 1, -- 通用的禁止
	Ride                     = 2, -- 坐骑
	Buff_Stay                = 4, -- 定身
	Buff_Stone               = 8, -- 石化
	Buff_Levitate            = 16, -- 浮空
}

-- 人物动作事件Action的 State 
LES_C_Action = {
	Create                     = _add(0), -- 创建
	Enter                      = _add(),  -- 进入
	Update                     = _add(),  -- 更新
	Exit                       = _add(),  -- 退出
	End                        = _add(),  -- 结束
}

-- 特效 - 类型
LE_Effect_Type = {
	Effect               = _add(0),     -- 特效 - 创建 & 不显示
	Buff                 = _add(),      -- buff - 创建 & 不显示
	Bullet               = _add(),      -- 子弹 - 创建 & 不显示
	
	Effect_Show          = _add(),      -- 特效 - 创建 & 显示
	Buff_Show            = _add(),      -- buff - 创建 & 显示
	Bullet_Show          = _add(),      -- 子弹 - 创建 & 显示
	
	Pre_Effect           = _add(),      -- 特效 - 预加载
}

-- 动作特效 - 类型
LES_Ani_Eft_Type = {
	BigSkill             = 1,      -- 大招
	SelfBone             = 2,      -- 自身 - 跟随骨骼点
	SelfBonePos          = 7,      -- 自身 - 只当时取下骨骼点位置
	TargetBody           = 3,      -- 目标 - 身上点
	TargetBodyPos        = 4,      -- 目标 - 只当时取下身上点位置
	FlyTarget            = 5,      -- 飞行 到 目标身上
	FlyPosition          = 6,      -- 飞行 到 目标当时的位置
	Stone                = 8,      -- 石化
}

-- 动作特效 - 挂接点
LES_Ani_Eft_Point = {
	[1]                  = "f_head",
	[2]                  = "f_l_hand",
	[3]                  = "f_r_hand",
	[4]                  = "f_l_hand;f_r_hand",
	[5]                  = "f_mid",
	[6]                  = "f_back",
	[7]                  = "f_l_foot",
	[8]                  = "f_r_foot",
	[9]                  = "foot",
}

-- shader特效 - 类型
LET_Shader_Effect = {
	None                 = _add(0),     -- 无效果
	Stone                = _add(),      -- 石化效果
}

AET_2_SE = {
	[LES_Ani_Eft_Type.Stone] = LET_Shader_Effect.Stone,
}

local function _init_global()
	for k, v in pairs(LES_C_State) do
		if k ~= "None" and LES_C_Action_State[k] then
			LES_C_State_2_Action_State[v] = LES_C_Action_State[k]
		end
	end
end

_init_global()