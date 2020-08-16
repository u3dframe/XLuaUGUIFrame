using UnityEngine;
using System;
using System.Collections;

/// <summary>
/// 类名 : GameObject 不能被消耗
/// 作者 : Canyon
/// 日期 : 2017-03-21 10:37
/// 功能 : 
/// </summary>
public class GobjNotDestroy : MonoBehaviour {
	static public GobjNotDestroy Get(GameObject gobj,bool isAdd){
		GobjNotDestroy _r = gobj.GetComponent<GobjNotDestroy> ();
		if (isAdd && null == _r) {
			_r = gobj.AddComponent<GobjNotDestroy> ();
		}
		return _r;
	}

	static public GobjNotDestroy Get(GameObject gobj){
		return Get(gobj,true);
	}

	void Awake()
	{
		GameObject.DontDestroyOnLoad(this.gameObject);
	}
}
