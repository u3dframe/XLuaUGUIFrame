﻿using UnityEngine;
using System;
using System.Collections;
using UnityEngine.SceneManagement;

/// <summary>
/// 类名 : 场景加载器
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-12-10 11:15
/// 功能 : 
/// </summary>
public class MgrLoadScene : GobjLifeListener {
	static WaitForSeconds _wait = new WaitForSeconds(0.01f);
	static MgrLoadScene _instance;
	static public MgrLoadScene instance{
		get{
			if (IsNull(_instance)) {
				GameObject _gobj = GameMgr.mgrGobj;
				_instance = _gobj.GetComponent<MgrLoadScene>();
				if (IsNull(_instance))
				{
					_instance = _gobj.AddComponent<MgrLoadScene> ();
				}
			}
			return _instance;
		}
	}
	
	string m_curName = null;
	Action m_callLoadedScene;
	
	void ExcuteCallLoadedScene(){
		var _func = m_callLoadedScene;
		m_callLoadedScene = null;
		if(_func != null){
			_func();
		}
	}

    public void ReLoadScene(string name,Action callLoadedScene){
		m_curName = null;
		StopAllCoroutines ();
		LoadScene (name,callLoadedScene);
	}
	
	 public void ReLoadScene(string name){
		ReLoadScene (name,null);
	}

	public void LoadScene(string name,Action callLoadedScene){
		if(name.Equals(m_curName)) return;
		this.m_curName = name;
		this.m_callLoadedScene = callLoadedScene;
		StartCoroutine (LoadSceneByMgr(name));
	}
	
	public void LoadScene(string name){
		LoadScene(name,null);
	}

	IEnumerator LoadSceneByApp(string name)
	{
		yield return _wait;
		AsyncOperation asyncOper = Application.LoadLevelAsync(name);
		yield return asyncOper;
		ExcuteCallLoadedScene();
	}

	IEnumerator LoadSceneByMgr(string name)
	{
		yield return _wait;
		AsyncOperation asyncOper = SceneManager.LoadSceneAsync(name);
		yield return asyncOper;
		ExcuteCallLoadedScene();
	}

	// 是否当前的Scene窗体
	public bool IsCurScene(string name){
		if (string.IsNullOrEmpty (name)) {
			return false;
		}
		Scene cur = SceneManager.GetActiveScene ();
		return (name.Equals (cur.name));
	}
}
