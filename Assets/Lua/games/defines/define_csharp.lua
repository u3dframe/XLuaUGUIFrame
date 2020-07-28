-- U开头代表Unity的CSharp Class, C开头代表自身封装的CSharp Class

-- UAnimation = UnityEngine.Animation
UGameObject = CS.UnityEngine.GameObject
UTransform = CS.UnityEngine.Transform
URectTransform = CS.UnityEngine.RectTransform
UWaitForSeconds = CS.UnityEngine.WaitForSeconds
UWebRequest = CS.UnityEngine.Networking.UnityWebRequest
UText = CS.UnityEngine.UI.Text
UImage = CS.UnityEngine.UI.Image
URawImage = CS.UnityEngine.UI.RawImage
UCamera = CS.UnityEngine.Camera

CWWWMgr = CS.Core.Kernel.WWWMgr
CBtBuffer = CS.TNet.ByteBuffer
CNetMgr = CS.NetworkManager
CResMgr = CS.Core.ResourceManager
CLuaMgr = CS.LuaManager
CGameFile = CS.Core.GameFile
CGobjLife = CS.GobjLifeListener
CPElement = CS.PrefabElement
CHelper = CS.LuaHelper
CTxt = CS.UGUILocalize
CBtn = CS.UGUIButton
CLoadSceneMgr = CS.MgrLoadScene
CFollower = CS.SmoothFollower
CMCaneraMgr = CS.MainCameraManager
CInpMgr = CS.InputMgr

-- Charpe 的 常量 cost 属性 ([[初始化后，不会在变化的属性]])
GM_IsEditor = CGameFile.isEditor
-- TP_UText = typeof(UText)