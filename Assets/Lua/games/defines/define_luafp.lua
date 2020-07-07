-- lua脚本的父节点
_LuaPacakge = {
	[1] = "games/defines/",
	[2] = "games/basics/",
	[3] = "games/basics/monos/",
	[4] = "games/basics/ugui/",
	[5] = "games/net/",
	[6] = "games/logics/",
}

-- 不需要全局变量的lua
_LuaFpNoKey = {
	"luaex/toolex",
	"class",
	"games/game_tools",
}

-- 基础
_LuaFpBasic = {
	{"Event","events"}, -- 引入通用的消息对象
	{"","define_global",1}, -- 常量 Lua 全局变量
	{"","define_events",1}, -- 常量 事件 相关
	{"","define_csharp",1}, -- 常量 CSharp 相关
	{"LuaObject","lua_object",2}, -- 基础类
	{"LUGobj","u_gobj",3}, -- gobj
	{"LUTrsf","u_transform",3}, -- transform
	{"LUComonet","u_component",3}, -- component
	{"LCFabBasic","uc_fabbasic",3}, -- PrefabBasic
	{"LCFabElement","uc_fabelement",3}, -- PrefabElement
	{"LuBase","ugui_base",4}, -- UGUI 组件 - 基础类
	{"LuText","ugui_text",4}, -- UGUI 组件 - 文本
	{"LuaAsset","lua_asset",2}, -- 资源
	{"LuaFab","lua_fab",2}, -- 为场景对象和ui_base对象的父类
	{"MgrRes","mgr_res",2}, -- 控制 资源加载了
}

-- 中间
_LuaFpMidle = {
	{"","protocal",5}, -- 常量 网络层协议
	{"Network","network",5}, -- 网络层
	{"UIBase","ui_base",6}, -- UI的基础类
	{"UIRoot","ui_root",6}, -- 加载 UI的根uiroot
	{"GEntry","game_entry",6}, -- 游戏入口
}

-- 最后
_LuaFpEnd = {
	{"MgrLogin","login/mgr_login",6}, -- 登录管理
}