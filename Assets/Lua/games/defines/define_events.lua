------------- event names 消息定义
Evt_Update = "Evt_Update"; -- update 更新函数
Evt_LateUpdate = "Evt_LateUpdate"; -- lateupdate 更新函数
Evt_FixedUpdate = "Evt_FixedUpdate"; -- fixedupdate 更新函数
Evt_OnAppQuit = "Evt_OnAppQuit"; -- On App Quit
Evt_OnAppPause = "Evt_OnAppPause"; -- On App Pause
Evt_UpEverySecond = "Evt_UpEverySecond"; -- 每秒更新
Evt_UpEveryMin = "Evt_UpEveryMin"; -- 每分钟更新 参数 : 当前分钟 0 -59
Evt_UpEveryHour = "Evt_UpEveryHour"; -- 每小时更新 参数 : 当前时钟 0 -23

Evt_ToChangeScene = "Evt_ToChangeScene"; -- 执行 - 切换场景
Evt_SceneLoaded = "Evt_SceneLoaded"; -- 场景加载完成 (level)
Evt_SceneChanged = "Evt_SceneChanged"; -- 场景切换完成 [ 晚于 Evt_SceneLoaded ]

Evt_MapLoad = "Evt_MapLoad"; -- 执行加载地图
Evt_MapLoaded = "Evt_MapLoaded"; -- 地图加载完成

Evt_SendRay4ScreenPoint = "Evt_SendRay4ScreenPoint"; -- 发射线 (v2,lfCall[ray,hit,layer],distance,isMust,nameLayers = [...] )

Evt_View_MainCamera = "Evt_View_MainCamera"; -- 显示主摄像机
Evt_Show_Loading = "Evt_Show_Loading"; -- 显示 Loading 加载界面
Evt_Hide_Loading = "Evt_Hide_Loading"; -- 隐藏 Loading 加载界面
Evt_ToView_UpRes = "Evt_ToView_UpRes"; -- 更新界面

-------- 资源更新后所用事件
Evt_GameEntryAfterUpRes = "Evt_GameEntryAfterUpRes"; -- 处理更新完毕后的入口

-------- 界面所用事件
Evt_Popup_Tips = "Evt_Popup_Tips"; -- 弹出提示
Evt_Error_Tips = "Evt_Error_Tips"; -- 错误提示
Evt_EnterGameBeforeMain = "Evt_EnterGameBeforeMain"; -- 进入主界面前
Evt_ToView_Login = "Evt_ToView_Login"; -- 登录界面

