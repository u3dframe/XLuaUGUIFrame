using UnityEngine;
using System.Collections.Generic;
namespace Core{
	/// <summary>
	/// 类名 : GameObject 对象池
	/// 作者 : Canyon / 龚阳辉
	/// 日期 : 2020-06-26 10:29
	/// 功能 : 
	/// </summary>
	internal class GameObjectPool
	{
		static bool IsNull(object uobj){
			return UtilityHelper.IsNull(uobj);
		}

		static AssetBundleManager abMgr {get {return AssetBundleManager.instance;} }

		static char[] m_cSp = "@@".ToCharArray();
		
		// 池名 = abName@@assetName
		public string poolName {get; private set;}
		protected string abName {get; private set;}
		protected string assetName {get; private set;}
		
		// 内存对象
		public AssetInfo poolObject;

		// 最大数量
		private int maxSize;

		// 初始数量
		private int initSize;
		
		// 当前数量
		private int poolSize;

		// 根节点
		private Transform trsfRoot;

		// 数据记录
		private Stack<GameObject> availableObjStack = new Stack<GameObject> ();
		private List<GameObject> listTemp = new List<GameObject> ();

		// 借出数量
		int borrowNum = 0;

		// 是否有fab对象
		public bool isHasPrefab { get { if(!IsNull(this.poolObject)) return this.poolObject.isHasObj; return false; } }

		/// <summary>
		/// 超过了最大数量是否自动销毁
		/// </summary>
		public bool isAutoHandler4MoreThanMax = true;
		private bool preIsAutoHandler = true;

		public DF_LoadedFab m_cfLoadedFab = null;

		private GameObjectPool (string poolName, int initCount, int maxSize,Transform root)
		{
			Init(poolName,initCount,maxSize,root);
		}
		
		static public GameObjectPool builder(string poolName, int initCount, int maxSize,Transform root)
		{
			return new GameObjectPool(poolName,initCount,maxSize,root);
		}

		static public GameObjectPool builder(string poolName, int initCount,Transform root)
		{
			return builder(poolName,initCount,30,root);
		}

		static public GameObjectPool builder(string poolName,Transform root)
		{
			return builder(poolName,1,root);
		}

		static public GameObjectPool builder(string poolName)
		{
			return builder(poolName,null);
		}

		public override string ToString ()
		{
			return string.Format (
				"poolName = [{0}],maxSize = [{1}],poolSize = [{2}],borrowNum = [{3}],availableObjStackSize = [{4}],isAutoHandler = [{5}],assetInfo = [{6}]",
				this.poolName,
				this.maxSize,
				this.poolSize,
				this.borrowNum,
				this.availableObjStack.Count,
				this.isAutoHandler4MoreThanMax,
				this.poolObject
			);
		}
		
		private void Init(string poolName,int initCount, int maxSize,Transform root)
		{
			this.poolName = poolName;
			this.initSize = initCount;
			this.poolSize = 0;
			this.maxSize = maxSize;
			this.trsfRoot = root;
			string[] _ars = GameFile.Split(poolName,m_cSp,true);
			if(_ars != null && _ars.Length > 2){
				this.abName = _ars[0];
				this.assetName = _ars[1];
				this.poolObject = abMgr.LoadAsset<GameObject>(this.abName,this.assetName,OnLoadedCall);
			}
		}
		
		// 设置最大数量
		public void SetMaxSize(int max){
			max = max < 0 ? 20 : max;
			if(this.maxSize != max){
				bool isReduce = this.maxSize > max;
				this.maxSize = max;
				if(isReduce){
					HandlerMoreThanMax(true);
				}
			}
		}

		public void SetParent(Transform trsf){
			this.trsfRoot = trsf;
		}
		
		// 加载回调
		void OnLoadedCall(AssetBase asset){
			if(isHasPrefab)
			{
				InitPool();
			}
			var func = m_cfLoadedFab;
			this.m_cfLoadedFab = null;
			if(func != null){
				func(BorrowObject());
			}
		}

		// 初始化对象
		void InitPool(){
			if (isAutoHandler4MoreThanMax) {
				this.initSize = Mathf.Min (this.maxSize, this.initSize);
			}

			if (isHasPrefab && this.poolSize < this.initSize) {
				int index = this.poolSize;
				for (; index < initSize; index++) {
					AddObjectToPool (NewObjectInstance ());
				}
			}
		}

		// 记录
		private void AddObjectToPool (GameObject go)
		{
			//add to pool
			lock (availableObjStack) {
				go.SetActive (false);

				bool isAdd = (!isAutoHandler4MoreThanMax) || (isAutoHandler4MoreThanMax && this.poolSize < this.maxSize);
				if (isAdd) {
					availableObjStack.Push (go);
					go.transform.SetParent (trsfRoot, false);
					this.poolSize = availableObjStack.Count;
					if (borrowNum > 0)
						borrowNum--;
				} else {
					GameObject.Destroy (go);
				}
			}
		}

		// 创建
		private GameObject NewObjectInstance ()
		{
			if (IsNull(this.poolObject)) return null;
			GameObject gobj = this.poolObject.NewGObjInstance(trsfRoot);
			if(!IsNull(gobj)){
				var cs = GobjLifeListener.Get(gobj,true);
				cs.poolName = this.poolName;
				cs.m_onDestroy += _OnCFGobjDestroy;
			}
			return gobj;
		}

		private void _OnCFGobjDestroy(GobjLifeListener goLife){
			OnDestroy(goLife.poolName,goLife.m_gobj);
		}

		// 取得一个对象
		public GameObject BorrowObject (bool isActive)
		{
			lock (availableObjStack) {
				GameObject go = null;
				while (this.poolSize > 0) {
					go = availableObjStack.Pop ();
					this.poolSize = availableObjStack.Count;
					if (go) {
						break;
					}
				}

				if (IsNull(go)) {
					go = NewObjectInstance ();
				}

				if (!IsNull(go)) {
					borrowNum++;
					go.SetActive (isActive);
				}
				return go;
			}
		}
		
		public GameObject BorrowObject ()
		{
			return BorrowObject(true);
		}

		// 还原
		public void ReturnObject (string pool, GameObject po)
		{
			if (poolName.Equals (pool)) {
				AddObjectToPool (po);
			} else {
				Debug.LogError (string.Format ("Trying to add object to incorrect pool = [{0}] , need_pool = [{1}] ", poolName,pool));
			}
		}

		// 对象销毁时，移除对象池
		void OnDestroy(string pool,GameObject go){
			lock (availableObjStack) {
				if (poolName.Equals (pool) && go != null) {
					bool isHas = availableObjStack.Contains (go);
					if (isHas) {
						listTemp.AddRange(availableObjStack.ToArray ());
						listTemp.Remove (go);
						availableObjStack.Clear ();
						int lens = listTemp.Count;
						for (int i = 0; i < lens; i++) {
							availableObjStack.Push (listTemp [i]);
						}
						listTemp.Clear();
					}
					borrowNum--;
					this.poolSize = availableObjStack.Count;
				}
			}
		}

		/// <summary>
		/// 主动处理过多资源
		/// </summary>
		public void HandlerMoreThanMax(bool isMust){
			isMust = isMust || !(this.isAutoHandler4MoreThanMax && this.preIsAutoHandler == this.isAutoHandler4MoreThanMax);
			if(!isMust) return;
			this.preIsAutoHandler = this.isAutoHandler4MoreThanMax;
			
			lock (availableObjStack) {
				int curSize = this.poolSize;
				if (curSize > this.maxSize) {
					GameObject go = null;
					GobjLifeListener _life = null;
					for (int i = this.maxSize; i < curSize; i++) {
						go = availableObjStack.Pop ();
						if (go) {
							_life = GobjLifeListener.Get(go);
							if(_life != null){
								_life.m_onDestroy -= _OnCFGobjDestroy;
							}
							GameObject.Destroy (go);
						}
					}
					this.poolSize = availableObjStack.Count;
					go = null;
				}
			}
		}
		
		public void HandlerMoreThanMax(){
			HandlerMoreThanMax(false);
		}

		public void Clear()
		{
			SetMaxSize(0);
			abMgr.UnLoadAsset(this.abName);
		}

		public void SetAssetBundleUnload(bool isImmUnload,float sec){
			var ab = abMgr.GetABInfo(this.abName);;
			if(!IsNull(ab)){
				ab.m_isImmUnload = isImmUnload;
				ab.SetDefOut(sec);
			}
		}
	}
}