using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using System;

public sealed class LuaHelper  : UtilityHelper {
	/// <summary>
	/// 清理内存
	/// </summary>
	static public void ClearMemory() {
		GC.Collect(); Resources.UnloadUnusedAssets();
		var mgr = LuaManager.instance;
		if (mgr != null) mgr.LuaGC();
	}

	// /// <summary>
	// /// 最多9个参数
	// /// </summary>
	static public bool CFuncLua(string funcName, params object[] args) {
		var mgr = LuaManager.instance;
		if (mgr != null) { return mgr.CFuncLua(funcName,args); } 
		return false;
	}

	static public bool IsElement(object obj) {
		if(IsNull(obj))	return false;
		return obj is PrefabElement;
	}

	static public void GetRectSize(GameObject gobj,ref float w,ref float h) {
		w = 0;h = 0;
		if(IsNull(gobj)) return;
		GetRectSize(gobj.transform,ref w,ref h);
	}

	static public void GetRectSize(Transform trsf,ref float w,ref float h) {
		w = 0;h = 0;
		if(IsNull(trsf)) return;
		RectTransform _r = trsf as RectTransform;
		var v2 = _r.rect.size;
		w = v2.x;
		h = v2.y;
	}
}