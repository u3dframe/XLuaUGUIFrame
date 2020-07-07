using UnityEngine;
using System.Collections;

/// <summary>
/// 类名 : GameObject对象 生命周期 监听
/// 作者 : Canyon
/// 日期 : 2017-03-21 10:37
/// 功能 : 只针对 OnDestroy的回调
/// </summary>
public class GobjLifeListener : MonoBehaviour,IUpdate {
	static public bool IsNull(UnityEngine.Object uobj)
	{
		return UtilityHelper.IsNull(uobj);
	}

	static public GobjLifeListener Get(GameObject gobj,bool isAdd){
		GobjLifeListener _r = gobj.GetComponent<GobjLifeListener> ();
		if (isAdd && IsNull(_r)) {
			_r = gobj.AddComponent<GobjLifeListener> ();
		}
		return _r;
	}

	static public GobjLifeListener Get(GameObject gobj){
		return Get(gobj,true);
	}

	// 接口函数
	[System.NonSerialized]
	public bool m_isOnUpdate = true;
	public bool IsOnUpdate(){ return this.m_isOnUpdate;} 
	public virtual void OnUpdate(float dt) {}	

	// 自身对象
	Transform _m_trsf;
	
	/// <summary>
	/// 自身对象
	/// </summary>
	public Transform m_trsf
	{
		get{
			if(IsNull(_m_trsf)){
				_m_trsf = transform;
			}
			return _m_trsf;
		}
	}
	
	GameObject _m_gobj;
	
	/// <summary>
	/// 自身对象
	/// </summary>
	public GameObject m_gobj
	{
		get{
			if(IsNull(_m_gobj)){
				_m_gobj = gameObject;
			}
			return _m_gobj;
		}
	}

	[System.NonSerialized]
	public string poolName = "";
	
	/// <summary>
	/// 继承对象实现的销毁回调 (比代理事件快)
	/// </summary>
	protected virtual void OnCall4Destroy(){}
	/// <summary>
	/// 销毁回调
	/// </summary>
	public event Core.DF_OnNotifyDestry m_onDestroy;
	
	// 是否是存活的
	private bool _alive = true;
	public bool alive { get {return _alive;} }

	void _ExcDestoryCall(){
		var _call = this.m_onDestroy;
		this.m_onDestroy = null;
		if (_call != null)
			_call (this);
	}

	void OnDestroy(){
		// Debug.Log ("Destroy,poolName = " + poolName+",gobjname = " + gameObject.name);
		this.m_isOnUpdate = false;
		this._alive = false;
		OnCall4Destroy();
		_ExcDestoryCall();
	}

	void OnApplicationQuit(){
		this.m_isOnUpdate = false;
		this._alive = false;
	}

	public void DetroySelf(){
		GameObject.Destroy(this);
	}
}
