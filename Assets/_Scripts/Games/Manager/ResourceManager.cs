using UnityEngine;
using UnityEngine.Playables;
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

		static string fmtPoolName = "{0}@@{1}@@{2}";
		static Dictionary<string,GameObjectPool> m_pools = new Dictionary<string, GameObjectPool>();
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

		static private GameObjectPool GetGPool(string poolName,bool isNew)
		{
			GameObjectPool gpool = null;
			if(!m_pools.TryGetValue(poolName,out gpool) && isNew)
			{
				gpool = GameObjectPool.builder(poolName,1,trsfRoot);
				m_pools.Add(poolName,gpool);
			}
			return gpool;
		}

		static private (GameObjectPool,string) GetGPoolPName(string abName,string assetName,bool isNew)
		{
			string poolName = string.Format(fmtPoolName,abName,assetName,GameFile.tpGobj);
			GameObjectPool pool =  GetGPool(poolName,isNew);
			return (pool,poolName);
		}

		static private GameObjectPool GetGPool(string abName,string assetName,bool isNew)
		{
			(GameObjectPool pool,_) =  GetGPoolPName(abName,assetName,isNew);
			return pool;
		}

		static public void LoadFab(string abName,string assetName,DF_LoadedFab callLoaded){
			GameObjectPool gpool = GetGPool(abName,assetName,true);
			if(gpool.isHasPrefab){
				if(callLoaded != null)
				{
					callLoaded(gpool.BorrowObject());
				}
			}else{
				gpool.StartLoad(callLoaded);
			}
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

		static public void LoadPlayableAsset(string abName,string assetName,DF_LoadedPlayableAsset callLoaded){
			abMgr.LoadAsset<PlayableAsset>(abName,assetName,(obj) => {
				AssetInfo aInfo = obj as AssetInfo;
				if (callLoaded != null)
				{
					callLoaded(aInfo.GetObject<PlayableAsset>());
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

		static public AssetInfo GetAsset4PlayableAsset(string abName,string assetName){
			return GetAsset<PlayableAsset>(abName,assetName);
		}

		static public void ReturnObj(string abName,string assetName,GameObject obj){
			(GameObjectPool pool,string poolName) =  GetGPoolPName(abName,assetName,false);
			if (IsNull(pool)){
				if(obj)
					GameObject.Destroy(obj);
			}else{
				pool.ReturnObject(poolName,obj);
			}
		}

		static public void UnLoadPool(string abName,string assetName){
			GameObjectPool gpool = GetGPool(abName,assetName,false);
			if (!IsNull(gpool)){
				m_pools.Remove(gpool.poolName);
				gpool.Clear();
			}
		}

		static public void UnLoadAsset(string abName)
		{
			abMgr.UnLoadAsset(abName);
		}

	}
}
