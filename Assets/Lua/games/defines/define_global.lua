-- atlas_uimain = "texture/ui/atlas/uimain.atlas"; -- 主要的
-- atlas_com = "texture/ui/atlas/uicommon.atlas"; -- 常用的
-- game_version = "12"; -- 游戏版本号

TB_EMPTY = {}; -- 全局空的对象(用于返回)
TB_NEW = {__call=function() return {}; end}; -- 用法: TB_NEW();

LE_AsType = {
    Fab = 1,
    Sprite = 2,
    Texture = 3
}

LE_StateLoad = {
    None = 0,
    PreLoad = 1,
    Loading = 2,
    Loaded = 3,
}

LE_StateView = {
    None = 0,
    Show = 1,
    Hide = 2,
    Destroy = 3,
}