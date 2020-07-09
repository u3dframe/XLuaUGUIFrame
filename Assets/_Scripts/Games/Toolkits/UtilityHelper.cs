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
		TimeSpan ts = new TimeSpan(DateTime.UtcNow.Ticks - new DateTime(1970, 1, 1, 0, 0, 0).Ticks);
		return (long)ts.TotalMilliseconds;
	}

	static public T Get<T>(GameObject go) where T : Component {
		if (go != null) {
			return go.GetComponent<T>();
		}
		return null;
	}

	static public T Get<T>(Transform trsf) where T : Component {
		if (trsf != null) {
			return trsf.GetComponent<T>();
		}
		return null;
	}

	/// <summary>
	/// 搜索子物体组件-GameObject版
	/// </summary>
	static public T Get<T>(GameObject go, string subnode) where T : Component {
		if (go != null) {
			Transform sub = go.transform.Find(subnode);
			if (sub != null) return sub.GetComponent<T>();
		}
		return null;
	}

	/// <summary>
	/// 搜索子物体组件-Transform版
	/// </summary>
	static public T Get<T>(Transform go, string subnode) where T : Component {
		if (go != null) {
			Transform sub = go.Find(subnode);
			if (sub != null) return sub.GetComponent<T>();
		}
		return null;
	}

	/// <summary>
	/// 搜索子物体组件-Component版
	/// </summary>
	static public T Get<T>(Component go, string subnode) where T : Component {
		return go.transform.Find(subnode).GetComponent<T>();
	}

	/// <summary>
	/// 添加组件
	/// </summary>
	static public T Add<T>(GameObject go) where T : Component {
		if (go != null) {
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
		if (trsf == null) return null;
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
		if (gobj == null) return null;
		Transform trsf = ChildRecursion(gobj.transform,subnode);
		if (trsf == null) return null;
		return trsf.gameObject;
	}

	/// <summary>
	/// 查找子对象
	/// </summary>
	static public Transform ChildTrsf(Transform trsf, string subnode) {
		if (trsf == null) return null;
		return trsf.Find(subnode);
	}

	static public Transform ChildTrsf(GameObject gobj, string subnode) {
		if(gobj == null) return null;
		return ChildTrsf(gobj.transform,subnode);
	}

	static public GameObject Child(Transform trsf, string subnode) {
		Transform tf = ChildTrsf(trsf,subnode);
		if (tf == null) return null;
		return tf.gameObject;
	}

	/// <summary>
	/// 查找子对象
	/// </summary>
	static public GameObject Child(GameObject gobj, string subnode) {
		if(gobj == null) return null;
		return Child(gobj.transform, subnode);
	}

	/// <summary>
	/// 取平级对象
	/// </summary>
	static public GameObject Peer(Transform trsf, string subnode) {
		if(trsf == null) return null;
		return Child(trsf.parent,subnode);
	}
	
	/// <summary>
	/// 取平级对象
	/// </summary>
	static public GameObject Peer(GameObject gobj, string subnode) {
		if(gobj == null) return null;
		return Peer(gobj.transform, subnode);
	}

	/// <summary>
	/// 设置父节点
	/// </summary>
	static public void SetParent(Transform trsf,Transform trsfParent,bool isLocalZero) {
		if(trsf == null) return;
		trsf.SetParent (trsfParent,!isLocalZero);
	}

	static public void SetParent(Transform trsf,Transform trsfParent) {
		SetParent(trsf,trsfParent,true); 
	}

	/// <summary>
	/// 设置父节点
	/// </summary>
	static public void SetParent(GameObject gobj, GameObject gobjParent,bool isLocalZero) {
		if(gobj == null) return;
		Transform trsf = gobj.transform;
		Transform trsfParent = null;
		if (gobjParent != null) trsfParent = gobjParent.transform;
		SetParent(trsf, trsfParent, isLocalZero);
	}

	static public void SetParent(GameObject gobj, GameObject gobjParent) {
		SetParent(gobj,gobjParent,true); 
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

	// 在编辑模式下，这个函数有问题，即便为null对象，经过判断就不为空了
	static public bool IsNull(object obj)
	{
		return object.ReferenceEquals(obj,null);
	}

	static public bool IsNotNull(object obj)
	{
		return !IsNull(obj);
	}

	static public bool IsNull(UObject uobj)
	{
		return null == uobj;
	}

	static public bool IsNotNull(UObject uobj)
	{
		return null != uobj;
	}

	static public bool IsComponent(object obj) {
		if(IsNull(obj))	return false;
		return obj is Component;
	}
}