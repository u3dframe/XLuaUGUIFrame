-- U开头代表Unity的CSharp Class, C开头代表自身封装的CSharp Class

-- UAnimation = UnityEngine.Animation
UPlayerPrefs = CS.UnityEngine.PlayerPrefs
UGameObject = CS.UnityEngine.GameObject
UTransform = CS.UnityEngine.Transform
URectTransform = CS.UnityEngine.RectTransform
UWaitForSeconds = CS.UnityEngine.WaitForSeconds
UWebRequest = CS.UnityEngine.Networking.UnityWebRequest
UText = CS.UnityEngine.UI.Text
UImage = CS.UnityEngine.UI.Image
UImageType = CS.UnityEngine.UI.Image.Type
URawImage = CS.UnityEngine.UI.RawImage
UCamera = CS.UnityEngine.Camera
UAnimator =  CS.UnityEngine.Animator
UTime = CS.UnityEngine.Time

CGobjLife = CS.GobjLifeListener
CPElement = CS.PrefabElement
CFollower = CS.SmoothFollower
CAnimator = CS.AnimatorEx
CCCtrler = CS.CharacterControllerEx
CParticleEx = CS.ParticleSystemEx

CTxt = CS.UGUILocalize
CGray = CS.UGUIGray
CBtn = CS.UGUIButton
CEvtListener = CS.UGUIEventListener

CWWWMgr = CS.Core.Kernel.WWWMgr
CBtBuffer = CS.TNet.ByteBuffer
CNetMgr = CS.NetworkManager
CResMgr = CS.Core.ResourceManager
CLuaMgr = CS.LuaManager
CGameFile = CS.Core.GameFile
CHelper = CS.LuaHelper
CLocliz = CS.Localization
CLoadSceneMgr = CS.MgrLoadScene
CMCaneraMgr = CS.MainCameraManager
CInpMgr = CS.InputMgr


-- Charpe 的 常量 cost 属性 ([[初始化后，不会在变化的属性]])
GM_IsEditor = CGameFile.isEditor
Is_LoadOrg4Editor = CGameFile.isLoadOrg4Editor
CRC_DPath = CGameFile.crcDataPath

UIT_Simple = UImageType.Simple
UIT_Sliced = UImageType.Sliced
UIT_Tiled  = UImageType.Tiled
UIT_Filled = UImageType.Filled

Is_PPLayer_Enabled = (Is_LoadOrg4Editor) or (not GM_IsEditor) -- 设置 PostProcessLayer 的 enabled

-- TP_UText = typeof(UText)