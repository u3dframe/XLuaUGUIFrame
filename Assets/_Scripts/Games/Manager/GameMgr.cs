using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using TNet;
using Core;

/// <summary>
/// 类名 : Update 管理
/// 作者 : Canyon
/// 日期 : 2020-06-27 20:37
/// 功能 : 所有需要Update函数，统一从这里调用
/// </summary>
public class GameMgr : GobjLifeListener {

	static GameObject _mgrGobj;
	static public GameObject mgrGobj{
		get{
			if (IsNull(_mgrGobj)) {
				string NM_Gobj = "GameManager";
				_mgrGobj = GameObject.Find(NM_Gobj);
				if (IsNull(_mgrGobj))
				{
					_mgrGobj = new GameObject(NM_Gobj);
				}
				GameObject.DontDestroyOnLoad (_mgrGobj);
			}

			return _mgrGobj;
		}
	}

	static GameMgr _instance;
	static public GameMgr instance{
		get{
			if (IsNull(_instance)) {
				_instance = mgrGobj.GetComponent<GameMgr>();
				if (IsNull(_instance))
				{
					_instance = mgrGobj.AddComponent<GameMgr> ();
				}
			}
			return _instance;
		}
	}
	
	static private DF_OnUpdate onUpdate = null;
	static private List<IUpdate> mListUps = new List<IUpdate>(); // 无用质疑，直接调用函数，比代理事件快

	static private Action onLateUpdate = null;
	static private List<ILateUpdate> mListLateUps = new List<ILateUpdate>();

	List<IUpdate> upList = new List<IUpdate>();
	IUpdate upItem = null;
	List<ILateUpdate> upLateList = new List<ILateUpdate>();
	ILateUpdate upLateItem = null;
	int upLens = 0;
	float _dt = 0;
	
	/// <summary>
	/// 初始化
	/// </summary>
	public void Init()
	{
		GameLanguage.Init();
		Localization.language = GameLanguage.strCurLanguage;
		
		LuaManager.instance.Init();
	}

	void Update() {
		_dt = Time.deltaTime;
		_Exc_Up(_dt);
	}
	
	void LateUpdate() {
		_Exc_LateUp();
	}

	/// <summary>
	/// 销毁
	/// </summary>
	void OnDestroy() {
		onUpdate = null;
		onLateUpdate = null;
		upItem = null;
		upLateItem = null;
		mListUps.Clear();
		mListLateUps.Clear();
		upList.Clear();
		upLateList.Clear();
	}

	void _Exc_Up(float dt){
		upList.AddRange(mListUps);
		upLens = upList.Count;
		for (int i = 0; i < upLens; i++)
		{
			upItem = upList[i];
			if(upItem != null && upItem.IsOnUpdate()){
				upItem.OnUpdate(dt);
			}
		}
		upList.Clear();

		if(onUpdate != null)
		{
			onUpdate(dt);
		}
	}

	void _Exc_LateUp(){
		upLateList.AddRange(mListLateUps);
		upLens = upLateList.Count;
		for (int i = 0; i < upLens; i++)
		{
			upLateItem = upLateList[i];
			if(upLateItem != null && upLateItem.IsOnLateUpdate()){
				upLateItem.OnLateUpdate();
			}
		}
		upLateList.Clear();

		if(onLateUpdate != null)
		{
			onLateUpdate();
		}
	}
	
	static public void RegisterUpdate(IUpdate up) {
		if(mListUps.Contains(up))
			return;
		mListUps.Add(up);
	}

	static public void DiscardUpdate(IUpdate up) {
		mListUps.Remove(up);
	}

	static public void DisposeUpEvent(DF_OnUpdate call,bool isReBind) {
		onUpdate -= call;
		if(isReBind)
		{
			if(onUpdate == null)
				onUpdate = call;
			else
				onUpdate += call;
		}
	}

	static public void RegisterLateUpdate(ILateUpdate up) {
		if(mListLateUps.Contains(up))
			return;
		mListLateUps.Add(up);
	}

	static public void DiscardLateUpdate(ILateUpdate up) {
		mListLateUps.Remove(up);
	}

	static public void DisposeLateUpEvent(Action call,bool isReBind) {
		onLateUpdate -= call;
		if(isReBind)
		{
			if(onLateUpdate == null)
				onLateUpdate = call;
			else
				onLateUpdate += call;
		}
	}
}