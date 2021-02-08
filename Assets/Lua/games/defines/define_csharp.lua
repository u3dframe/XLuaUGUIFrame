-- U开头代表Unity的CSharp Class, C开头代表自身封装的CSharp Class

-- UAnimation = UnityEngine.Animation
UApplication = CS.UnityEngine.Application
UPlayerPrefs = CS.UnityEngine.PlayerPrefs
UGameObject = CS.UnityEngine.GameObject
UTransform = CS.UnityEngine.Transform
URectTransform = CS.UnityEngine.RectTransform
UCanvasGroup = CS.UnityEngine.CanvasGroup
UWaitForSeconds = CS.UnityEngine.WaitForSeconds
UWebRequest = CS.UnityEngine.Networking.UnityWebRequest
UText = CS.UnityEngine.UI.Text
UImage = CS.UnityEngine.UI.Image
UEImgType = CS.UnityEngine.UI.Image.Type
UESpace = CS.UnityEngine.Space
URawImage = CS.UnityEngine.UI.RawImage
UCamera = CS.UnityEngine.Camera
UAnimator =  CS.UnityEngine.Animator
UTime = CS.UnityEngine.Time
UScreen = CS.UnityEngine.Screen

CGobjLife = CS.GobjLifeListener
CPElement = CS.PrefabElement
CLookAt = CS.SmoothLookAt
CFollower = CS.SmoothFollower
CAnimator = CS.AnimatorEx
CCCtrler = CS.CharacterControllerEx
CParticleEx = CS.ParticleSystemEx
CRSortOrder = CS.RendererSortOrder
CRMatProp   = CS.RendererMatProperty

CRCClass = CS.CRCClass
CTxt = CS.UGUILocalize
CGray = CS.UGUIGray
CBtn = CS.UGUIButton
CEvtListener = CS.UGUIEventListener

CWVCert = CS.Core.Kernel.WebVerifyCert
CWWWMgr = CS.Core.Kernel.WWWMgr
CBtBuffer = CS.TNet.ByteBuffer
CNetMgr = CS.TNet.NetworkManager
CResMgr = CS.Core.ResourceManager
CLuaMgr = CS.LuaManager
CGameFile = CS.Core.GameFile
CGFile = CGameFile.curInstance
CHelper = CS.LuaHelper
CLocliz = CS.Localization
CLoadSceneMgr = CS.MgrLoadScene
CMCaneraMgr = CS.MainCameraManager
CInpMgr = CS.InputMgr
CELog2Net =  CELog2Net or CS.LogToNetHelper.shareInstance
CRSettingEx = CS.RenderSettingsEx
CCurveEx = CS.CurveEx
CSMapEx = CS.SceneMapEx
CEDComp = CS.ED_Animator
CEDUIImg = CS.ED_UIImg
CEDUIItem = CS.ED_UIItem
CEDCamera = CS.ED_Camera
CEDUIEffect = CS.ED_UIEffect
CEDUISpine = CS.ED_UISpine

CCardUtil = CS.CardUtil
CTimelineUtil = CS.TimelineUtil

-- Charpe 的 常量 cost 属性 ([[初始化后，不会在变化的属性]])
GM_IsEditor = CGameFile.isEditor
Is_LoadOrg4Editor = CGameFile.isLoadOrg4Editor
CRC_DPath = CGameFile.crcDataPath
Ltmap_End = CGameFile.m_strLightmap
Mat_End = CGameFile.m_strMat
Scriptable_End = CGameFile.m_strScriptable

UIT_Simple = UEImgType.Simple
UIT_Sliced = UEImgType.Sliced
UIT_Tiled  = UEImgType.Tiled
UIT_Filled = UEImgType.Filled
UES_World  = UESpace.World

FrameRate = UApplication.targetFrameRate
OneFrameSec = todecimal( 1 / FrameRate,4,0.016,true)

Is_PPLayer_Enabled = (Is_LoadOrg4Editor) or (not GM_IsEditor) -- 设置 PostProcessLayer 的 enabled

CGameFile.VwFps(true)
-- CGameFile.VwMems(true)

-- CGameFile.bLoadOrg4Editor = false -- 编辑模式下，读取 ab 资源
-- TP_UText = typeof(UText)