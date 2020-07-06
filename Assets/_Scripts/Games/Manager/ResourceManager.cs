using UnityEngine;
using System.Collections.Generic;
namespace Core
{
	using UObject = UnityEngine.Object;
	public delegate void DF_LoadedTex2D(Texture2D tex);
	public delegate void DF_LoadedSprite(Sprite sprite);

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
					gobj.SetActive(false);
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

		static private GameObjectPool GetGPool(string abName,string assetName,bool isNew)
		{
			string poolName = string.Format(fmtPoolName,abName,assetName,GameFile.tpGobj);
			return GetGPool(poolName,isNew);
		}

		static public void LoadFab(string abName,string assetName,DF_LoadedFab callLoaded){
			GameObjectPool gpool = GetGPool(abName,assetName,true);
			if(gpool.isHasPrefab){
				if(callLoaded != null)
				{
					callLoaded(gpool.BorrowObject());
				}
			}else{
				gpool.m_cfLoadedFab += callLoaded;
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

		static public void UnLoadFab(string abName,string assetName){
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
