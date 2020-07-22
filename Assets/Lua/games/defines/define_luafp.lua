-- lua脚本的父节点
_LuaPacakge = {
	[1] = "games/defines/",
	[2] = "games/basics/",
	[3] = "games/basics/monos/",
	[4] = "games/basics/ugui/",
	[5] = "games/net/",
	[6] = "games/logics/",
	[7] = "games/logics/base/",
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
	{"LuaBasic","lua_basic",2}, -- Basic 类
	{"LuaObject","lua_object",2}, -- 基础类
	{"LUGobj","u_gobj",3}, -- gobj
	{"LUTrsf","u_transform",3}, -- transform
	{"LUComonet","u_component",3}, -- component
	{"LCFabBasic","uc_fabbasic",3}, -- PrefabBasic
	{"LCFabElement","uc_fabelement",3}, -- PrefabElement
	{"LuaAsset","lua_asset",2}, -- 资源
	{"LuaFab","lua_fab",2}, -- 为场景对象和ui_base对象的父类
	{"LuaPubs","lua_pubs",2}, -- 取得所有脚本的父类
	{"MgrRes","mgr_res",2}, -- 控制 资源加载了
	{"LuBase","ugui_base",4}, -- 组件 - 基础类
	{"LuText","ugui_text",4}, -- 组件 - 文本
	{"LuBtn","ugui_button",4}, -- 组件 - 按钮
	{"LuTog","ugui_toggle",4}, -- 组件 - toggle
	{"LuScl","ugui_scroll",4}, -- 组件 - 循环滚动
	{"LuImg","ugui_image",4}, -- 组件 - 图片
	{"LuInpFld","ugui_inputfield",4}, -- 组件 - 输入框
}

-- 中间
_LuaFpMidle = {
	{"","protocal",5}, -- 常量 网络层协议
	{"Network","network",5}, -- 网络层
	{"UIPubs","ui_pubs",7}, -- UI的Pubs
	{"UIBase","ui_base",7}, -- UI的基础类
	{"UICell","uicell_base",7}, -- UICell的基础类
	{"UIRow","uicell_row",7}, -- 行单元（多行多列使用）
	{"UIRoot","ui_root",7}, -- 加载 UI的根uiroot
	{"SceneBase","scene_base",7}, --场景对象基础类
	{"MgrBase","mgr_base",7}, -- 管理基础类
	{"MgrInput","mgr_input",7}, -- 管理 - 场景单击
	{"MgrCamera","mgr_camera",7}, -- 管理 - 场景摄像头
	{"GEntry","game_entry",6}, -- 游戏入口
}

-- 最后
_LuaFpEnd = {
	{"MgrScene","scene/mgr_scene",6}, -- 场景管理
	{"MgrLogin","login/mgr_login",6}, -- 登录管理
}