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

Evt_SendRay4ScreenPoint = "Evt_SendRay4ScreenPoint"; -- 发射线 (v2,lfCall[ray,hit,layer],distance,isImmediate,nameLayers = ... )
Evt_UserLog2Net = "Evt_UserLog2Net"; -- 用户日志记录
Evt_UserProcessLog2Net = "Evt_UserProcessLog2Net"; -- 用户流程日志记录

Evt_Net_ShutDown = "Evt_Net_ShutDown"; -- 断开链接(true = 断开)

-------- 摄像机 - 所用事件
Evt_Vw_Def3DCamera = "Evt_Vw_Def3DCamera"; -- 显/隐 默认的3D 摄像机 (true/false,otherCamera)
Evt_Get_UICamera = "Evt_Get_UICamera"; -- 取得UI摄像机 ( self.lfunc(lbUICamera),self )
Evt_Brocast_UICamera = "Evt_Brocast_UICamera"; -- 广播UI摄像机 (lbUICamera)

Evt_Loading_Show = "Evt_Loading_Show"; -- 显示 Loading 加载界面
Evt_Loading_Showing = "Evt_Loading_Showing"; -- Loading 加载界面 显示中ing
Evt_Loading_UpPlg = "Evt_Loading_UpPlg"; -- 更新 Loading 加载界面 的进度条
Evt_Loading_Hide = "Evt_Loading_Hide"; -- 隐藏 Loading 加载界面
Evt_Loading_Hided = "Evt_Loading_Hided"; -- Loading 加载界面 已执行了 隐藏

Evt_Circle_Show = "Evt_Circle_Show"; -- 显示 Circle 界面
Evt_Circle_Showing = "Evt_Circle_Showing"; -- Circle 界面 显示中ing
Evt_Circle_Hide = "Evt_Circle_Hide"; -- 隐藏 Circle 界面
Evt_Circle_Hided = "Evt_Circle_Hided"; -- 隐藏了 Circle 界面

Evt_View_Vdo = "Evt_View_Vdo"; -- Vdo 界面 显/隐 ( true/false,vdo,callEnd,callReady)

-------- 资源更新完毕后 - 所用事件
Evt_LoadAllShaders = "Evt_LoadAllShaders"; -- 加载所有的shaders
Evt_GameEntryAfterUpRes = "Evt_GameEntryAfterUpRes"; -- 处理更新完毕后的入口

-------- 地图场景 - 所用事件
Evt_Map_Load = "Evt_Map_Load"; -- 执行加载地图 (mapid)
Evt_Map_Loaded = "Evt_Map_Loaded"; -- 地图加载完成
Evt_Map_AddObj = "Evt_Map_AddObj"; -- 添加 map 场景里面的 对象 (objType,resid,lfunc,lbObject)
Evt_Map_GetObj = "Evt_Map_GetObj"; -- 取 map 场景里面的 对象 (uniqueID,lfunc,lbObject)
Evt_Map_ReSInfo = "Evt_Map_ReSInfo"; -- 重写设置下当前场景的场景数据

Evt_State_Battle_Start = "Evt_State_Battle_Start"; -- 战斗状态开始
Evt_Map_SV_AddObj = "Evt_Map_SV_AddObj"; -- 服务器消息 - 添加对象 (objType,svData)
Evt_Map_SV_RmvObj = "Evt_Map_SV_RmvObj"; -- 服务器消息 - 删除对象 (svData.id)
Evt_Map_SV_MoveObj = "Evt_Map_SV_MoveObj"; -- 服务器消息 - 移动对象 (svData,isEndPos)
Evt_Map_SV_BreakSkill = "Evt_Map_SV_BreakSkill"; -- 服务器消息 - 打断 对象 技能 (svData)
Evt_Map_SV_Skill = "Evt_Map_SV_Skill"; -- 服务器消息 - 技能播放
Evt_Map_SV_Skill_Effect = "Evt_Map_SV_Skill_Effect"; -- 服务器消息 - 技能效果(伤害数值和表现)
Evt_Map_SV_Skill_Pause = "Evt_Map_SV_Skill_Pause"; -- 服务器消息 - 技能停止
Evt_Map_SV_Skill_GoOn = "Evt_Map_SV_Skill_GoOn"; -- 服务器消息 - 技能继续
Evt_Msg_B_Buff_Add = "Evt_Msg_B_Buff_Add"; -- buff add
Evt_Msg_B_Buff_Rmv = "Evt_Msg_B_Buff_Rmv"; -- buff remove
Evt_Msg_B_Trigger_Add = "Evt_Msg_B_Trigger_Add"; -- trigger add
Evt_Msg_B_Trigger_Rmv = "Evt_Msg_B_Trigger_Rmv"; -- trigger remove
Evt_Bat_OneAttrChg = "Evt_Bat_OneAttrChg"; -- 战斗单体属性改变
Evt_Msg_Battle_End = "Evt_Msg_Battle_End"; -- 战斗消息结束(进入表现了)
Evt_Battle_Delay_End_MS = "Evt_Battle_Delay_End_MS"; -- 设置延迟结束战斗
Evt_Battle_End = "Evt_Battle_End"; -- 战斗 - 结束

-------- 界面所用事件
Evt_UI_Showing = "Evt_UI_Showing"; -- UI显示中ing事件
Evt_UI_Closed = "Evt_UI_Closed"; -- UI关闭ed事件
Evt_Popup_Tips = "Evt_Popup_Tips"; -- 弹出提示
Evt_Desc_Tip = "Evt_Desc_Tip"; -- 弹出描述tip
Evt_Error_Tips = "Evt_Error_Tips"; -- 错误提示
Evt_EnterGameBeforeMain = "Evt_EnterGameBeforeMain"; -- 进入主界面前
Evt_ToView_Login = "Evt_ToView_Login"; -- 登录界面  ( isHide )

Evt_Re_Login = "Evt_Re_Login"; -- 返回登陆

Evt_View_FightUI = "Evt_View_FightUI"; -- 显隐 - 战斗UI  ( isHide )
Evt_FightUI_Showing = "Evt_FightUI_Showing"; -- 战斗UI 显示中ing

Evt_LoginSDK = "Evt_LoginSDK"; -- SDK登录成功返回
