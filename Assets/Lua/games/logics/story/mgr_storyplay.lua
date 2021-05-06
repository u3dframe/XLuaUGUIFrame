--[[
-- 剧情动画控制器抽象类
-- Author : zhouyuxiang
-- Date : 2020-07-23 17:25
-- Desc :
--]]
local evt = Event
local function DebugLog(...)---剧情播放专用打印（用于排查流程Bug时使用，正常情况下设置未false）
    if (false)then
        printTable(...)
    end
end
local super = MgrBase
---@class StoryPlay 剧情播放
local M = class("mgr_storyplay", super)
local ChildStory = require("games/logics/story/storyplaychild");
objsPool:AddClassBy( ChildStory )
--Story:事件--TODO:做完在移动到event里面
Evt_StopPlayStory  = "Evt_StartPlayStop"; --停止播放剧情动画
Evt_StartPlayStory = "Evt_StartPlayStory";--开始播放剧情动画
--region 构造
function M:Init()
    --播放剧情
    self.CurrPlayStory = nil;       ---当前播放剧情动画数据（为Nil则代表当前没有动画可播放，但有值并不代表剧情正在播放，有可能在加载资源）
    self.IsStoryPlaying = false;    ---当前是否播放动画（CurrPlayStory有值代表有动画数据但可能在加载中，只有这个值为T才代表已经开始播放）
    self.CurrPlayStoryChild = nil;  ---当前播放剧情动画子类
    self.PlayStoryCacheQueue = {};  ---剧情动画播放缓存队列（此队列先进先出，按顺序播放）
    return self;
end
--endregion

--region 播放方法
---剧情播放
---@param id int 资源配置表ID
---@param onBindCallBack func<util> 剧情播放开始前bind回调(此时资源已经准备完成，但还未开始，再此方法中手动调用开始)
---@param onOverCallBack func<剧情ID,是否播放成功> 剧情播放完成回调
function M:PlayStory(id ,onBindCallBack ,onOverCallBack,time)
    local config = self:GetCfgData("resource",id);
    if (config)then
        self:AddPlayStoryCacheQueue(id, onBindCallBack, onOverCallBack,time);--将剧情加入播放缓存队列
        self:PlayStoryCheck()--尝试播放动画(不管有没有加成功都尝试播放一次，驱动其他序列的东)
        return;
    end
    printError("资源配置表未查找到 ID = %s 相关配置，请检查~", id)
end


---暂停当前播放
function M:PauseCurrStory()
    if (self.CurrPlayStoryChild)then
        self.CurrPlayStoryChild:PauseCurrStory()
    end
end

---继续播放暂停动画
function M:ResumeCurrStory()
    if (self.CurrPlayStoryChild)then
        self.CurrPlayStoryChild:ResumeCurrStory()
    end
end

---完全停止结束播放
function M:StopCurrStory()
    if (self.CurrPlayStoryChild)then
        self.CurrPlayStoryChild:StopCurrStory()
    end
end

function M:SetClip(ch, name)
    if (self.CurrPlayStoryChild)then
        self.CurrPlayStoryChild:SetClip(ch, name)
    end
end

--endregion

--region 播放流程
--region 播放检测
---检测当前动画是否播放（如果没有当前播放数据，则设置当前播放数据，不允许私自调用）
function M:CheckCurrIsPlay()
    if (self.CurrPlayStory == nil)then
        local data = {};
        self.IsStoryPlaying = false;
        for i, v in ipairs(self.PlayStoryCacheQueue) do
            if (i == 1)then
                self.CurrPlayStory = v;
            else
                table.insert(data, v);
            end
        end
        self.PlayStoryCacheQueue = data;
        if (self.CurrPlayStory)then
            return true
        end
    else
        if (self.IsStoryPlaying == false)then
            return true;--有当前数据但还没开始播放，可能当前正在加载资源或上一次因为某种原因未成功播放，允许继续执行下一步，如果时资源未加载完成则在加载的地方进行阻断
        end
    end
    DebugLog(self.CurrPlayStory and "当前有动画正在播放" or "当前没有播放的动画")
    return false;
end

--endregion
---剧情播放检测（检测是否可以播放剧情动画）
function M:PlayStoryCheck()
    --判断当前是否可以播放剧情动画
    if (self:CheckCurrIsPlay())then--检测当前动画是否正在播放
        DebugLog("PlayStoryCheck() ================================ <<< Begin")
        --TODO:判断当前是否在游戏场景
        --TODO:判断当前游戏场景是否显示（避免在Loading，但是如果打开全屏界面会隐藏游戏场景的话，值得商榷是否应该添加丢弃动画的机制）
        --TODO:判断当前玩家状态是否允许播放
        --TODO:判断当前是否符合配置条件
        self:PlayStoryPreparation();
        DebugLog("PlayStoryCheck() ================================ <<< Over")
    end
end

---剧情播放前准备
function M:PlayStoryPreparation()
    if (self.IsStoryPlaying ~= true)then
        self.IsStoryPlaying = true;
        --创建剧情
        --MgrUI.HideAll()--TODO：播放剧情前避免打开全屏界面，如果打开 应该强制关掉他
        --TODO：部分剧情可能需要打开某些可操作或显示的UI,在此将UI打开后通过回调再加载需要播放的资源，避免UI还未打开剧情已经播放完了（比如阴阳师画符）
        local _tCurr = self.CurrPlayStory
        self.CurrPlayStoryChild = ChildStory.Builder(_tCurr.id, function ()
            self:StoryPlayOver();
        end, function ()
            self:OfficialStartDoPlayStory();
        end,_tCurr.time);
        self.CurrPlayStoryChild:ShowView(true);
    end
end

---正式开始播放剧情动画
function M:OfficialStartDoPlayStory()
    --时间模式
    self.CurrPlayStoryChild:SetTimeType(true);
    --回调回上一层进行播放资源绑定
    if (self.CurrPlayStory.onBindCallBack)then
        self.CurrPlayStory.onBindCallBack(self);
    end
    --摄像机准备
    MgrCamera:GetMainCamera():SetActive(false);
    --正式开始播放
    self:OfficialPlay();
end

function M:SetBinding(tarckname , go)
    self.CurrPlayStoryChild:SetBinding(tarckname, go)
end

function M:SetPosition(x, y, z)
    self.CurrPlayStoryChild:SetPosition(x,y,z);
end

function M:GetPElement()
    return self.CurrPlayStoryChild.comp;
end



function M:IsCanBinding(tarckname)
    if (self.CurrPlayStoryChild)then
        return self.CurrPlayStoryChild:IsCanBinding(tarckname);
    end
end

function M:OfficialPlay()
    if(self.IsOfficiaPlaying ~= true)then
        --通知其他系统开始播放剧情(该关界面关界面，该暂停的暂停)
        evt.Brocast(Evt_StartPlayStory, self.CurrPlayStory.id);--注意 这个事件即使连续播放都会通知，主要方便区分播放不同动画时的特殊表现，监听时可以自行加锁避免多次调用代码
        self.IsOfficiaPlaying = true;
        self.CurrPlayStoryChild:Play()
    end
end

function M:StoryPlayOver()
    if (self.CurrPlayStoryChild)then
        --清除播放资源
        self.CurrPlayStoryChild:View(false);--清除模型资源
        --打开隐藏的摄像机
        MgrCamera:GetMainCamera():SetActive(true);
        --清除当前播放数据
        self.IsOfficiaPlaying = false;
        self.IsStoryPlaying = false;
        local lastId = nil
        if (self.CurrPlayStory)then
            local _dd = self.CurrPlayStory
            self.CurrPlayStory = nil;
            lastId = _dd.id;
            if (_dd.onOverCallBack)then
                _dd.onOverCallBack()
            end
        end
        if #self.PlayStoryCacheQueue <= 0 then
            --通知其他系统播放剧情完成 大家爱咋咋滴
            evt.Brocast(Evt_StopPlayStory, lastId);
        else
            --递归，看看还有没有其他需要播放的
            self:PlayStoryCheck();
        end
    end
end
--endregion

--region 剧情缓存（可在切换场景或剧情发生改变时移除还未播放的相关剧情）
---添加剧情（此方法不会触发播放逻辑，不允许私自调用）
function M:AddPlayStoryCacheQueue(id,onBindCallBack,onOverCallBack,time)
    if (onBindCallBack == nil or onOverCallBack == nil)then return end
    table.insert(self.PlayStoryCacheQueue, { id = id, onBindCallBack = onBindCallBack, onOverCallBack = onOverCallBack,time = time});
end


---移除等待播放的剧情（注意：正在播放的剧情不会停止）
---@param id int 所需移除的剧情配置表ID
function M:RemovePlayStoryCacheQueueByID(id)
    local data = {};
    for _, v in ipairs(self.PlayStoryCacheQueue) do
        if v.id == id then
            table.insert(data, v);
        end
    end
    self.PlayStoryCacheQueue = data;
end


---清除所有剧情（注意：正在播放的剧情不会停止）
function M:ClearAllPlayStoryCacheQueueData()
    self.PlayStoryCacheQueue = {};
end
--endregion

function M:GetCamera()
    return self.CurrPlayStoryChild:GetCamera();
end
function M:SetCaster(gobj)
    return self.CurrPlayStoryChild:SetCaster(gobj);
end
function M:SetTarget(gobj,index)
    return self.CurrPlayStoryChild:SetTarget(gobj,index);
end
function M:SetTargetActive(index, isActive)
    return self.CurrPlayStoryChild:SetTargetActive(index, isActive)
end
return M