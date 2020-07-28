﻿using UnityEngine;
using System;
using System.Collections;

/// <summary>
/// 类名 : GameObject对象 生命周期 监听
/// 作者 : Canyon
/// 日期 : 2017-03-21 10:37
/// 功能 : this.enabled 不能在自身的 回调事件里面设置(只能通过外包设置)
/// </summary>
public class GobjLifeListener : MonoBehaviour,IUpdate {
	static public bool IsNull(UnityEngine.Object uobj)
	{
		return UtilityHelper.IsNull(uobj);
	}

	static protected GameObject GetGobj(string name)
	{
		return UtilityHelper.GetGobjNo(name);
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
	[HideInInspector] public bool m_isOnUpdate = true;
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

	[HideInInspector] public string poolName = "";
	[HideInInspector] public string csAlias = ""; // CSharp 别名
	// 是否是存活的
	private bool _isAlive = false;
	public bool isAlive { get {return _isAlive;} }
	public bool isAppQuit { get;private set;}


	/// <summary>
	/// 继承对象可实现的函数 (比代理事件快)
	/// </summary>
	protected virtual void OnCall4Awake(){}
	protected virtual void OnCall4Start(){}
	protected virtual void OnCall4Show(){}
	protected virtual void OnCall4Hide(){}
	protected virtual void OnCall4Destroy(){}

	
	public Action m_callAwake;
	public Action m_callStart;
	public Action m_callShow; // 显示
	public Action m_callHide; // 隐藏
	public event Core.DF_OnNotifyDestry m_onDestroy; // 销毁

	void Awake()
	{
		this._isAlive = true;
		OnCall4Awake();
		if(m_callAwake != null) m_callAwake ();
		if(string.IsNullOrEmpty(this.csAlias)){
			this.csAlias = this.m_gobj.name;
		}
	}

	void Start() {
		OnCall4Start ();
		if(m_callStart != null) m_callStart ();
	}

	void OnEnable()
	{
		OnCall4Show ();
		if (m_callShow != null) m_callShow ();
	}

	void OnDisable()
	{
		OnCall4Hide ();
		if (m_callHide != null) m_callHide ();
	}

	void OnDestroy(){
		// Debug.Log ("Destroy,poolName = " + poolName+",gobjname = " + gameObject.name);
		if(!this.isAppQuit){
			OnCall4Destroy();
			_ExcDestoryCall();
		}
		_OnClear();
	}

	protected void OnApplicationQuit(){
		this.isAppQuit = true;
		_OnClear();
	}
	
	private void _OnClear(){
		this.m_isOnUpdate = false;
		this._isAlive = false;
		this.m_callAwake = null;
		this.m_callStart = null;
		this.m_callShow = null;
		this.m_callHide = null;
		this._m_gobj = null;
		this._m_trsf = null;

		OnClear();
	}

	protected virtual void OnClear(){
	}

	void _ExcDestoryCall(){
		var _call = this.m_onDestroy;
		this.m_onDestroy = null;
		if (_call != null)
			_call (this);
	}

	public void DetroySelf(){
		GameObject.Destroy(this);
	}
}
