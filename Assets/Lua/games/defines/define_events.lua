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

Evt_SendRay4ScreenPoint = "Evt_SendRay4ScreenPoint"; -- 发射线 (v2,lfCall[ray,hit,layer],distance,isMust,nameLayers = ... )

Evt_View_MainCamera = "Evt_View_MainCamera"; -- 显示主摄像机 (true/false)
Evt_Vw_MainCamera = "Evt_Vw_MainCamera"; -- 显示主摄像机 (true/false,otherCamera)
Evt_Loading_Show = "Evt_Loading_Show"; -- 显示 Loading 加载界面
Evt_Loading_UpPlg = "Evt_Loading_UpPlg"; -- 更新 Loading 加载界面 的进度条
Evt_Loading_Hide = "Evt_Loading_Hide"; -- 隐藏 Loading 加载界面
Evt_ToView_UpRes = "Evt_ToView_UpRes"; -- 更新界面

-------- 资源更新完毕后 - 所用事件
Evt_LoadAllShaders = "Evt_LoadAllShaders"; -- 加载所有的shaders
Evt_GameEntryAfterUpRes = "Evt_GameEntryAfterUpRes"; -- 处理更新完毕后的入口

-------- 地图场景 - 所用事件
Evt_Map_Load = "Evt_Map_Load"; -- 执行加载地图 (mapid)
Evt_Map_Loaded = "Evt_Map_Loaded"; -- 地图加载完成
Evt_Map_AddObj = "Evt_Map_AddObj"; -- 添加 map 场景里面的 对象 (objType,resid,lfunc,lbObject)
Evt_Map_GetObj = "Evt_Map_GetObj"; -- 取 map 场景里面的 对象 (uniqueID,lfunc,lbObject)

-------- 界面所用事件
Evt_Popup_Tips = "Evt_Popup_Tips"; -- 弹出提示
Evt_Error_Tips = "Evt_Error_Tips"; -- 错误提示
Evt_EnterGameBeforeMain = "Evt_EnterGameBeforeMain"; -- 进入主界面前
Evt_ToView_Login = "Evt_ToView_Login"; -- 登录界面

