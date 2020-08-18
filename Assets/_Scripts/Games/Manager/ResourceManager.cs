using UnityEngine;
using UnityEngine.Timeline;
using System.Collections.Generic;
namespace Core
{
	using UObject = UnityEngine.Object;
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
					string NM_Gobj = "ObjectPools";
					GameObject gobj = GameObject.Find(NM_Gobj);
					if (IsNull(gobj))
					{
						gobj = new GameObject(NM_Gobj);
					}
					GameObject.DontDestroyOnLoad (gobj);
					_trsfRoot = gobj.transform;
					// gobj.SetActive(false);
				}

				return _trsfRoot;
			}
		}

		static AssetBundleManager abMgr {get {return AssetBundleManager.instance;} }

		static public void LoadFab(string abName,string assetName,DF_LoadedFab callLoaded,Transform parent){
			abMgr.LoadAsset<GameObject>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					GameObject _ret = aInfo.NewGObjInstance(parent);
					callLoaded(_ret);
				}
			});
		}

		static public void LoadFabNoParent(string abName,string assetName,DF_LoadedFab callLoaded){
			LoadFab(abName,assetName,callLoaded,null);
		}

		static public void LoadFabDeParent(string abName,string assetName,DF_LoadedFab callLoaded){
			LoadFab(abName,assetName,callLoaded,trsfRoot);
		}

		static public void LoadSprite(string abName,string assetName,DF_LoadedSprite callLoaded){
			abMgr.LoadAsset<Sprite>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					callLoaded(aInfo.GetObject<Sprite>());
				}
			});
		}

		static public void LoadTexture(string abName,string assetName,DF_LoadedTex2D callLoaded){
			abMgr.LoadAsset<Texture2D>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					callLoaded(aInfo.GetObject<Texture2D>());
				}
			});
		}

		static public void LoadAnimator(string abName,string assetName,DF_LoadedAnimator callLoaded){
			abMgr.LoadAsset<Animator>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					callLoaded(aInfo.GetObject<Animator>());
				}
			});
		}

		static public void LoadAnimationClip(string abName,string assetName,DF_LoadedAnimationClip callLoaded){
			abMgr.LoadAsset<AnimationClip>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					callLoaded(aInfo.GetObject<AnimationClip>());
				}
			});
		}

		static public void LoadAudioClip(string abName,string assetName,DF_LoadedAudioClip callLoaded){
			abMgr.LoadAsset<AudioClip>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					callLoaded(aInfo.GetObject<AudioClip>());
				}
			});
		}

		static public void LoadTimelineAsset(string abName,string assetName,DF_LoadedTimelineAsset callLoaded){
			abMgr.LoadAsset<TimelineAsset>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					callLoaded(aInfo.GetObject<TimelineAsset>());
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
			return GetAsset<Texture>(abName,assetName);
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

		static public void UnLoadAsset(string abName)
		{
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
