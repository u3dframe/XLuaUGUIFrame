using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// 类名 : Prefab 基础对象
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-08-04 00:10
/// 功能 : 
/// </summary>
public class PrefabBasic : GobjLifeListener {
	static public new PrefabBasic Get(GameObject gobj,bool isAdd){
		PrefabBasic _r = gobj.GetComponent<PrefabBasic> ();
		if (isAdd && IsNull(_r)) {
			_r = gobj.AddComponent<PrefabBasic> ();
		}
		return _r;
	}

	static public new PrefabBasic Get(GameObject gobj){
		return Get(gobj,true);
	}
}