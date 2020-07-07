-- atlas_uimain = "texture/ui/atlas/uimain.atlas"; -- 主要的
-- atlas_com = "texture/ui/atlas/uicommon.atlas"; -- 常用的
-- game_version = "12"; -- 游戏版本号

TB_EMPTY = {}; -- 全局空的对象(用于返回)
TB_NEW = {__call=function() return {}; end}; -- 用法: TB_NEW();

-- asset 资源类型
LE_AsType = {
    Fab = 1,
    UI = 2,
    Sprite = 3,
    Texture = 4,
    [1] = "prefab",
    [2] = "prefab",
    [3] = "png",
    [4] = "png",
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
    UpRes = "UpRes",
    Default = "Default",
    Main = "Main",
    Background = "Background",
    Normal = "Normal",
    Pop = "Pop",
    Message = "Message",
    Guide = "Guide",
    Top = "Top",
}