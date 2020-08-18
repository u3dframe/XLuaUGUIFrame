using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using System;
using UObject = UnityEngine.Object;


/// <summary>
/// 类名 : 基础公用帮助脚本
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-06-26 09:33
/// 功能 : 泛型是不能被Tolua导成函数的
/// </summary>
public class UtilityHelper {
	
	static public readonly DateTime DT_Start = new DateTime(1970, 1, 1, 0, 0, 0);

	static public DateTime ToTZLoc{
		get{
			return TimeZone.CurrentTimeZone.ToLocalTime(DT_Start);
		} 
	}
	
	static public long TickStartUtc{
		get{
			return ToTZLoc.ToUniversalTime().Ticks;
		}
	}
	
	static public long TickStartLoc{
		get{
			return ToTZLoc.ToLocalTime().Ticks;
		}
	}

	/// <summary>
	/// getType
	/// </summary>
	/// <param name="classname"></param>
	/// <returns></returns>
	static public System.Type GetType(string classname) {
		Assembly assb = Assembly.GetExecutingAssembly();  //.GetExecutingAssembly();
		System.Type t = null;
		t = assb.GetType(classname);
		return t;
	}
	
	static public long GetTime() {
		TimeSpan ts = new TimeSpan(DateTime.UtcNow.Ticks - TickStartUtc);
		return (long)ts.TotalMilliseconds;
	}

	static public void ThrowError(string msg) {
		throw new Exception(msg);
	}

	static public bool IsNull(UObject uobj)
	{
		return null == uobj;
	}

	static public bool IsNoNull(UObject uobj)
	{
		return null != uobj;
	}
	
	// 在编辑模式下，这个函数有问题，即便为null对象，经过判断就不为空了
	static public bool IsNull(object obj)
	{
		return object.ReferenceEquals(obj,null);
	}

	static public bool IsNoNull(object obj)
	{
		return !IsNull(obj);
	}

	static public bool IsComponent(object obj) {
		if(IsNull(obj))	return false;
		return obj is Component;
	}

	static public bool IsCamera(object obj) {
		if(IsNull(obj))	return false;
		return obj is Camera;
	}

	static public bool IsTransform(object obj) {
		if(IsNull(obj))	return false;
		return obj is Transform;
	}

	static public bool IsGameObject(object obj) {
		if(IsNull(obj))	return false;
		return obj is GameObject;
	}

	static public T Get<T>(GameObject go) where T : Component {
		if(IsNull(go)) return null;
		return go.GetComponent<T>();
	}

	static public T Get<T>(Transform trsf) where T : Component {
		if(IsNull(trsf)) return null;
		return trsf.GetComponent<T>();
	}

	static public T Get<T>(GameObject gobj,bool isAdd) where T : Component {
		if(IsNull(gobj)) return null;
		T _r = gobj.GetComponent<T> ();
		if (isAdd && IsNull(_r)) {
			_r = gobj.AddComponent<T> ();
		}
		return _r;
	}

	static public T Get<T>(Transform trsf,bool isAdd) where T : Component {
		if(IsNull(trsf)) return null;
		return Get<T>(trsf.gameObject,isAdd);
	}

	/// <summary>
	/// 搜索子物体组件-GameObject版
	/// </summary>
	static public T Get<T>(GameObject go, string subnode) where T : Component {
		if(IsNull(go)) return null;
		Transform sub = go.transform.Find(subnode);
		return Get<T>(sub);
	}

	/// <summary>
	/// 搜索子物体组件-Transform版
	/// </summary>
	static public T Get<T>(Transform trsf, string subnode) where T : Component {
		if(IsNull(trsf)) return null;
		Transform sub = trsf.Find(subnode);
		return Get<T>(sub);
	}

	static public T Get<T>(GameObject go, string subnode,bool isAdd) where T : Component {
		if(IsNull(go)) return null;
		Transform sub = go.transform.Find(subnode);
		return Get<T>(sub,isAdd);
	}

	static public T Get<T>(Transform trsf, string subnode,bool isAdd) where T : Component {
		if(IsNull(trsf)) return null;
		Transform sub = trsf.Find(subnode);
		return Get<T>(sub,isAdd);
	}

	/// <summary>
	/// 搜索子物体组件-Component版
	/// </summary>
	static public T Get<T>(Component go, string subnode) where T : Component {
		return go.transform.Find(subnode).GetComponent<T>();
	}

	static public T GetInParent<T>(GameObject gobj) where T : Component {
		if(IsNull(gobj)) return null;
		T ret = gobj.GetComponent<T> ();
		if (!ret) {
			ret = gobj.GetComponentInParent<T> ();
		}
		return ret;
	}

	static public T GetInParent<T>(Transform trsf) where T : Component {
		if(IsNull(trsf)) return null;
		return GetInParent<T>(trsf.gameObject);
	}

	static public T GetInParentRecursion<T>(Transform trsf) where T : Component {
		if(IsNull(trsf)) return null;
		T ret = trsf.GetComponent<T> ();
		if (ret != null) return ret;
		return GetInParentRecursion<T>(trsf.parent);
	}

	static public T GetInParentRecursion<T>(GameObject gobj) where T : Component {
		if(IsNull(gobj)) return null;
		return GetInParentRecursion<T>(gobj.transform);
	}

	/// <summary>
	/// 添加组件
	/// </summary>
	static public T Add<T>(GameObject go) where T : Component {
		if (IsNoNull(go)) {
			T[] ts = go.GetComponents<T>();
			for (int i = 0; i < ts.Length; i++) {
				if (ts[i] != null) GameObject.Destroy(ts[i]);
			}
			return go.gameObject.AddComponent<T>();
		}
		return null;
	}

	/// <summary>
	/// 添加组件
	/// </summary>
	static public T Add<T>(Transform go) where T : Component {
		return Add<T>(go.gameObject);
	}

	/// <summary>
	/// 递归查找子对象
	/// </summary>
	static public Transform ChildRecursion(Transform trsf, string subnode) {
		if(IsNull(trsf)) return null;
		if(trsf.name.Equals(subnode)) return trsf;
		int lens = trsf.childCount;
		Transform _ret = null; 
		for(int i = 0; i < lens;i++){
			_ret = ChildRecursion(trsf.GetChild(i),subnode);
			if(_ret != null)
				return _ret;
		}
		return null;
	}

	static public GameObject ChildRecursion(GameObject gobj, string subnode) {
		if(IsNull(gobj)) return null;
		Transform trsf = ChildRecursion(gobj.transform,subnode);
		if(IsNull(trsf)) return null;
		return trsf.gameObject;
	}

	/// <summary>
	/// 查找子对象
	/// </summary>
	static public Transform ChildTrsf(Transform trsf, string subnode) {
		if(IsNull(trsf)) return null;
		return trsf.Find(subnode);
	}

	static public Transform ChildTrsf(GameObject gobj, string subnode) {
		if(IsNull(gobj)) return null;
		return ChildTrsf(gobj.transform,subnode);
	}
	
	static public GameObject Child(Transform trsf, string subnode) {
		Transform tf = ChildTrsf(trsf,subnode);
		if(IsNull(tf)) return null;
		return tf.gameObject;
	}

	/// <summary>
	/// 查找子对象
	/// </summary>
	static public GameObject Child(GameObject gobj, string subnode) {
		if(IsNull(gobj)) return null;
		return Child(gobj.transform, subnode);
	}

	/// <summary>
	/// 取平级对象
	/// </summary>
	static public GameObject Peer(Transform trsf, string subnode) {
		if(IsNull(trsf)) return null;
		return Child(trsf.parent,subnode);
	}
	
	/// <summary>
	/// 取平级对象
	/// </summary>
	static public GameObject Peer(GameObject gobj, string subnode) {
		if(IsNull(gobj)) return null;
		return Peer(gobj.transform, subnode);
	}

	static public GameObject GetGobj(string name,bool isNew,bool isNoDestroy) {
		GameObject gobj = GameObject.Find(name);
		if (isNew && IsNull(gobj)) {
			gobj = new GameObject(name);
		}
		if(isNoDestroy) GameObject.DontDestroyOnLoad (gobj);
		return gobj;
	}

	static public GameObject GetGobj(string name,bool isNew) {
		return GetGobj(name,isNew,false);
	}

	static public GameObject GetGobj(string name) {
		return GetGobj(name,true);
	}

	static public GameObject GetGobjNo(string name) {
		return GetGobj(name,true,true);
	}

	/// <summary>
	/// 设置父节点
	/// </summary>
	static public void SetParent(Transform trsf,Transform trsfParent,bool isLocalZero) {
		if(IsNull(trsf)) return;
		trsf.SetParent (trsfParent,!isLocalZero);
	}

	static public void SetParent(Transform trsf,Transform trsfParent) {
		SetParent(trsf,trsfParent,true); 
	}

	/// <summary>
	/// 设置父节点
	/// </summary>
	static public void SetParent(GameObject gobj, GameObject gobjParent,bool isLocalZero) {
		if(IsNull(gobj)) return;
		Transform trsf = gobj.transform;
		Transform trsfParent = null;
		if (gobjParent != null) trsfParent = gobjParent.transform;
		SetParent(trsf, trsfParent, isLocalZero);
	}

	static public void SetParent(GameObject gobj, GameObject gobjParent) {
		SetParent(gobj,gobjParent,true); 
	}

	static public bool IsInParent(Transform trsf, Transform trsfParent) {
		if(IsNull(trsf)) return false;
		return trsf.parent == trsfParent;
	}

	static public bool IsInParent(GameObject gobj, GameObject gobjParent) {
		return IsInParent(gobj?.transform,gobjParent?.transform);
	}

	static public GameObject Clone(GameObject gobj,Transform parent) {
		if(IsNull(gobj)) return null;
		return GameObject.Instantiate (gobj,parent,false) as GameObject;
	}

	static public GameObject Clone(GameObject gobj,GameObject gobjParent) {
		return Clone(gobj,gobjParent?.transform);
	}

	static public GameObject Clone(Transform trsf,Transform parent) {
		return Clone (trsf?.gameObject,parent);
	}

	static public GameObject Clone(GameObject gobj) {
		return Clone (gobj,gobj?.transform.parent);
	}

	static public GameObject Clone(Transform trsf) {
		return Clone(trsf?.gameObject);
	}

	static public RectTransform ToRectTransform(Transform trsf) {
		if(IsNull(trsf)) return null;
		return trsf as RectTransform;
	}

	static public RectTransform ToRectTransform(GameObject gobj) {
		return ToRectTransform(gobj?.transform);
	}

	static public bool IsInLayerMask(GameObject gobj, LayerMask layerMask) {
        // 根据Layer数值进行移位获得用于运算的Mask值
		if(IsNull(gobj)) return false;
        int objLayerMask = 1 << gobj.layer;
        return (layerMask.value & objLayerMask) > 0;
    }

	static public void SetLayer(GameObject gobj,int layer){
		if(IsNull(gobj)) return;
		gobj.layer = layer;
	}

	static public void SetLayer(Transform trsf,int layer){
		if(IsNull(trsf)) return;
		SetLayer(trsf.gameObject,layer);
	}

	static public void SetLayer(GameObject gobj,string nmLayer){
		if(IsNull(gobj)) return;
		int layer = LayerMask.NameToLayer(nmLayer);
		gobj.layer = layer;
	}

	static public void SetLayer(Transform trsf,string nmLayer){
		if(IsNull(trsf)) return;
		SetLayer(trsf.gameObject,nmLayer);
	}

	static public void SetLayerAll(Transform trsf,int layer){
		if(IsNull(trsf)) return;
		SetLayer(trsf,layer);

		int lens = trsf.childCount;
		for (int i = 0; i < lens; i++)
		{
			SetLayerAll(trsf.GetChild(i),layer);
		}
	}

	static public void SetLayerAll(GameObject gobj,int layer){
		if(IsNull(gobj)) return;
		SetLayer(gobj.transform,layer);
	}

	static public void SetLayerAll(Transform trsf,string nmLayer){
		if(IsNull(trsf)) return;
		int layer = LayerMask.NameToLayer(nmLayer);
		SetLayerAll(trsf,layer);
	}

	static public void SetLayerAll(GameObject gobj,string nmLayer){
		if(IsNull(gobj)) return;
		int layer = LayerMask.NameToLayer(nmLayer);
		SetLayerAll(gobj,layer);
	}

	static public void SetLayerBy(GameObject gobj,string nmLayer,bool isAll){
		if(isAll){
			SetLayerAll(gobj,nmLayer);
		}else{
			SetLayer(gobj,nmLayer);
		}
	}

	static public void SetLayerBy(Transform trsf,string nmLayer,bool isAll){
		if(isAll){
			SetLayerAll(trsf,nmLayer);
		}else{
			SetLayer(trsf,nmLayer);
		}
	}

	static public void SetLayerBy(GameObject gobj,int layer,bool isAll){
		if(isAll){
			SetLayerAll(gobj,layer);
		}else{
			SetLayer(gobj,layer);
		}
	}

	static public void SetLayerBy(Transform trsf,int layer,bool isAll){
		if(isAll){
			SetLayerAll(trsf,layer);
		}else{
			SetLayer(trsf,layer);
		}
	}
	
	/// <summary>
	/// 网络可用
	/// </summary>
	static public bool NetAvailable {
		get {
			return Application.internetReachability != NetworkReachability.NotReachable;
		}
	}

	/// <summary>
	/// 是否是无线
	/// </summary>
	static public bool IsWifi {
		get {
			return Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork;
		}
	}
	
	static public void Log(string str) {
		Debug.Log(str);
	}

	static public void LogWarning(string str) {
		Debug.LogWarning(str);
	}

	static public void LogError(string str) {
		Debug.LogError(str);
	}
}