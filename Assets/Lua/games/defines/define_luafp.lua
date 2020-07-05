-- lua脚本的父节点
_LuaPacakge = {
	[1] = "games/defines/",
	[2] = "games/basics/",
	[3] = "games/ugui/",
	[4] = "games/net/",
	[5] = "games/logics/",
	[6] = "games/logics/login/",
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
	{"LuUGobj","u_gobj",2}, -- gobj
	{"LuUTrsf","u_transform",2}, -- transform
	{"LuUComonet","u_component",2}, -- component
	{"LuCFabBasic","uc_fabbasic",2}, -- PrefabBasic
	{"LuCFabElement","uc_fabelement",2}, -- PrefabElement
	{"LuBase","ugui_base",3}, -- UGUI 组件 - 基础类
	{"LuText","ugui_text",3}, -- UGUI 组件 - 文本
}

-- 中间
_LuaFpMidle = {
	{"","protocal",4}, -- 常量 网络层协议
	{"Network","network",4}, -- 网络层
	{"MgrRes","mgr_res",5}, -- 控制 资源加载了
	{"LuaAsset","lua_asset",5}, -- 资源
	{"LuaFab","lua_fab",5}, -- 为场景对象和ui_base对象的父类
	{"UIBase","ui_base",5}, -- UI的基础类
	{"UIRoot","ui_root",5}, -- 加载 UI的根uiroot
}

-- 最后
_LuaFpEnd = {
	{"MgrLogin","mgr_login",6}, -- 登录管理
}