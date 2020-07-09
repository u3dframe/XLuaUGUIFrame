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

	static public void ThrowError(string msg) {
		throw new Exception(msg);
	}

	static public bool IsElement(object obj) {
		if(IsNull(obj))	return false;
		return obj is PrefabElement;
	}
}