using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Rendering.PostProcessing;
namespace Core
{
	public delegate void DF_LoadedPPFile(PostProcessProfile ppfile);

	/// <summary>
	/// 类名 : 资源管理器
	/// 作者 : Canyon / 龚阳辉
	/// 日期 : 2020-06-26 10:29
	/// 功能 : 
	/// </summary>
	public static class ResourceManager
	{
		static bool IsNull(object uobj){
			return UtilityHelper.IsNull(uobj);
		}

		static Transform _trsfRoot;
		static public Transform trsfRoot{
			get{
				if (IsNull(_trsfRoot)) {
					string NM_Gobj = "ObjPools";
					GameObject gobj = new GameObject(NM_Gobj);
					GameObject.DontDestroyOnLoad (gobj);
					_trsfRoot = gobj.transform;
					// gobj.SetActive(false);
				}
				return _trsfRoot;
			}
		}

		static Transform _trsfRootHide;
		static public Transform trsfRootHide{
			get{
				if (IsNull(_trsfRootHide)) {
					string NM_Gobj = "ObjPools_Hide";
					GameObject gobj = new GameObject(NM_Gobj);
					GameObject.DontDestroyOnLoad (gobj);
					_trsfRootHide = gobj.transform;
					gobj.SetActive(false);
				}
				return _trsfRootHide;
			}
		}

		static public Transform GetRoot(int nRoot){
			Transform parent = null;
			switch(nRoot){
				case 1:
				parent = trsfRoot;
				break;
				case 2:
				parent = trsfRootHide;
				break;
			}
			return parent;
		}

		static AssetBundleManager abMgr {get {return AssetBundleManager.instance;} }
		static private bool m_isOrgAsset{ get{ return GameFile.isLoadOrg4Editor; } }
		static public float m_secLmtUp{ get{return abMgr.m_secLmtUp;} set{abMgr.m_secLmtUp = value;} }
		static public float m_abOutSec{ get{return abMgr.m_abOutSec;} set{abMgr.m_abOutSec = value;} }

		static private bool LoadAsset<T>(string abName,string assetName,System.Action<T> cfunc) where T : UnityEngine.Object
		{
#if UNITY_EDITOR
			if(m_isOrgAsset){
				T _ret_ = GameFile.LoadInEditor<T>(abName,assetName);
				if (cfunc != null){
					cfunc(_ret_);
				}
			}
#endif
			return m_isOrgAsset;
		}

		static private void LoadFab(string abName,string assetName,DF_LoadedFab callLoaded,Transform parent,bool isUI){
			if(LoadAsset<GameObject>(abName,assetName,obj => {
				if(callLoaded != null) {
					GameObject gobj = null;
					if(obj){
						gobj = GameObject.Instantiate (obj,parent,false) as GameObject;
					}
					callLoaded(gobj);
				}
			}))
				return;

			abMgr.LoadAsset<GameObject>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					GameObject _ret = null;
					if(aInfo != null){
						_ret = aInfo.NewGObjInstance(parent);
						if(isUI)
							StaticEx.ReUIShader(_ret);
						else
							StaticEx.ReShader(_ret);
					}
					callLoaded(_ret);
				}
			});
		}

		static public void LoadFab(string abName,string assetName,DF_LoadedFab callLoaded,Transform parent){
			LoadFab(abName,assetName,callLoaded,parent,false);
		}

		static public void LoadFabParent(string abName,string assetName,DF_LoadedFab callLoaded,int nRoot){
			LoadFab(abName,assetName,callLoaded,GetRoot(nRoot));
		}

		static public void LoadFabNoParent(string abName,string assetName,DF_LoadedFab callLoaded){
			LoadFab(abName,assetName,callLoaded,null);
		}

		static public void LoadUI(string abName,string assetName,DF_LoadedFab callLoaded,Transform parent){
			LoadFab(abName,assetName,callLoaded,parent,true);
		}

		static public void LoadUIParent(string abName,string assetName,DF_LoadedFab callLoaded,int nRoot){
			LoadUI(abName,assetName,callLoaded,GetRoot(nRoot));
		}

		static public AssetInfo LoadSprite(string abName,string assetName,DF_LoadedSprite callLoaded){
			if(LoadAsset<Sprite>(abName,assetName,obj => {if(callLoaded != null) callLoaded(obj);}))
				return null;
			
			return abMgr.LoadAsset<Sprite>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					Sprite _ret = null;
					if(aInfo != null){
						_ret = aInfo.GetObject<Sprite>();
					}
					callLoaded(_ret);
				}
			});
		}

		static public void LoadTexture(string abName,string assetName,DF_LoadedTex2D callLoaded){
			if(LoadAsset<Texture2D>(abName,assetName,obj => {if(callLoaded != null) callLoaded(obj);}))
				return;

			abMgr.LoadAsset<Texture2D>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					Texture2D _ret = null;
					if(aInfo != null){
						_ret = aInfo.GetObject<Texture2D>();
					}
					callLoaded(_ret);
				}
			});
		}

		static public void LoadTexture(string abName,string assetName,DF_LoadedTex2DExt callLoaded,object ext1,object ext2){
			if(LoadAsset<Texture2D>(abName,assetName,obj => {if(callLoaded != null) callLoaded(obj,ext1,ext2);}))
				return;

			abMgr.LoadAsset<Texture2D>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					Texture2D _ret = null;
					if(aInfo != null){
						_ret = aInfo.GetObject<Texture2D>();
					}
					callLoaded(_ret,ext1,ext2);
				}
			});
		}

		static public void LoadMat(string abName,string assetName,DF_LoadedMaterial callLoaded){
			if(LoadAsset<Material>(abName,assetName,obj => {if(callLoaded != null) callLoaded(obj);}))
				return;

			abMgr.LoadAsset<Material>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					Material _ret = null;
					if(aInfo != null){
						_ret = aInfo.GetObject<Material>();
					}
					callLoaded(_ret);
				}
			});
		}

		static public void LoadAnimator(string abName,string assetName,DF_LoadedAnimator callLoaded){
			if(LoadAsset<Animator>(abName,assetName,obj => {if(callLoaded != null) callLoaded(obj);}))
				return;

			abMgr.LoadAsset<Animator>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					Animator _ret = null;
					if(aInfo != null){
						_ret = aInfo.GetObject<Animator>();
					}
					callLoaded(_ret);
				}
			});
		}

		static public void LoadAnimationClip(string abName,string assetName,DF_LoadedAnimationClip callLoaded){
			if(LoadAsset<AnimationClip>(abName,assetName,obj => {if(callLoaded != null) callLoaded(obj);}))
				return;

			abMgr.LoadAsset<AnimationClip>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					AnimationClip _ret = null;
					if(aInfo != null){
						_ret = aInfo.GetObject<AnimationClip>();
					}
					callLoaded(_ret);
				}
			});
		}

		static public void LoadAudioClip(string abName,string assetName,DF_LoadedAdoClip callLoaded){
			if(LoadAsset<AudioClip>(abName,assetName,obj => {if(callLoaded != null) callLoaded(obj);}))
				return;

			abMgr.LoadAsset<AudioClip>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					AudioClip _ret = null;
					if(aInfo != null){
						_ret = aInfo.GetObject<AudioClip>();
					}
					callLoaded(_ret);
				}
			});
		}

		static public void LoadTimelineAsset(string abName,string assetName,DF_LoadedTimelineAsset callLoaded){
			if(LoadAsset<TimelineAsset>(abName,assetName,obj => {if(callLoaded != null) callLoaded(obj);}))
				return;

			abMgr.LoadAsset<TimelineAsset>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					TimelineAsset _ret = null;
					if(aInfo != null){
						_ret = aInfo.GetObject<TimelineAsset>();
					}
					callLoaded(_ret);
				}
			});
		}

		static public void LoadPPFile(string abName,string assetName,DF_LoadedPPFile callLoaded){
			if(LoadAsset<PostProcessProfile>(abName,assetName,obj => {if(callLoaded != null) callLoaded(obj);}))
				return;

			abMgr.LoadAsset<PostProcessProfile>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					PostProcessProfile _ret = null;
					if(aInfo != null){
						_ret = aInfo.GetObject<PostProcessProfile>();
					}
					callLoaded(_ret);
				}
			});
		}

		static public AssetInfo GetAsset<T>(string abName,string assetName)  where T : UnityEngine.Object
		{
			return abMgr.GetAssetInfo<T>(abName,assetName);
		}

		static public AssetInfo GetAsset4Fab(string abName,string assetName){
			return GetAsset<GameObject>(abName,assetName);
		}

		static public AssetInfo GetAsset4Sprite(string abName,string assetName){
			return GetAsset<Sprite>(abName,assetName);
		}

		static public AssetInfo GetAsset4Texture(string abName,string assetName){
			return GetAsset<Texture2D>(abName,assetName);
		}

		static public AssetInfo GetAsset4Mat(string abName,string assetName){
			return GetAsset<Material>(abName,assetName);
		}

		static public AssetInfo GetAsset4Animator(string abName,string assetName){
			return GetAsset<Animator>(abName,assetName);
		}

		static public AssetInfo GetAsset4AnimationClip(string abName,string assetName){
			return GetAsset<AnimationClip>(abName,assetName);
		}

		static public AssetInfo GetAsset4AudioClip(string abName,string assetName){
			return GetAsset<AudioClip>(abName,assetName);
		}

		static public AssetInfo GetAsset4TimelineAsset(string abName,string assetName){
			return GetAsset<TimelineAsset>(abName,assetName);
		}

		static public AssetInfo GetAsset4PPFile(string abName,string assetName){
			return GetAsset<PostProcessProfile>(abName,assetName);
		}

		static public void UnLoadAsset(string abName)
		{
			if(GHelper.Is_App_Quit) return;
			abMgr.UnLoadAsset(abName);
		}

		static public ABInfo GetABInfo(string abName)
		{
			return abMgr.GetABInfo(abName);
		}

		static public void LoadShaders(System.Action cfLoaded)
		{
			abMgr.LoadShadersAndWarmUp(cfLoaded);
		}

		static public string[] GetDependences(string abName)
		{
			return abMgr.GetDependences(abName);
		}
	}
}
