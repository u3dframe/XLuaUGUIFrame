-- atlas_uimain = "texture/ui/atlas/uimain.atlas"; -- 主要的
-- game_version = "12"; -- 游戏版本号

TB_EMPTY = {}; -- 全局空的对象(用于返回)
TB_NEW = {__call=function() return {}; end}; -- 用法: TB_NEW();

-- asset 资源类型
LE_AsType = {
    Fab = 1,
    UI = 2,
    Sprite = 3,
    Texture = 4,
    Animator = 5,
    AnimationClip = 6,
    AudioClip = 7,
    Playable = 8,
    TextureExr = 9,
    Mat = 10,
    PPFile = 11,
    [1] = "prefab",
    [2] = "prefab",
    [3] = "png",
    [4] = "png",
    [5] = "controller",
    [6] = "anim",
    [7] = "mp3",
    [8] = "playable",
    [9] = "exr",
    [10] = "mat",
    [11] = "asset",
}

-- asset 加载状态
LE_StateLoad = {
    None = 0,
    PreLoad = 1,
    Loading = 2,
    Loaded = 3,
    UnLoad = 4,
}

-- fab 的状态
LE_StateView = {
    None = 0,
    Show = 1,
    Hide = 2,
    Destroy = 3,
}

-- ui 层级
LE_UILayer = {
    URoot = "URoot",
    UTemp = "UTemp",
    Default = "Default",
    Main = "Main",
    Background = "Background",
    Normal = "Normal",
    Pop = "Pop",
    Message = "Message",
    Guide = "Guide",
    Top = "Top",
}

--UI开启的互斥关系
LE_UI_Mutex = {
	None	  = 1, -- 互斥: 无
	All		  = 2, -- 互斥: 所有
	SelfLayer = 3, -- 互斥: 自身相同layer
	Main      = 4, -- 互斥: 主界面
	AllExceptGuide = 5, -- 互斥: 所有(排除guide layer)
	MainAndSelf    = 6, -- 互斥: 主界面 和 自身层级界面
}

-- 组件 Transform 平滑常量
LE_Trsf_Smooth = {
    None     = 0,
    PosLocal = 1, -- local position
    Pos      = 2, -- position
    AnPos    = 3, -- anchored position
    AnPos3D  = 4  -- anchored position 3D
}

-- 游戏 虚拟资源
LE_VCoin = {
    Item = 5,
    Hero = 6,
    Equip = 7,
    Chip = 15,
    Skill = 999
}

-- UI动作
LE_Anim_Unique = {
    anc_pos_up2down = 1001,
}

-- 场景类型
LE_SceneType = {
    MainHome = 0, -- home主场景
    Fight = 1, -- 战斗地图
    Explore = 2, -- 探索地图
    CityState = 3, -- 城邦
    OutSide = 4, -- 野外
    Card = 5, -- 抽卡
}