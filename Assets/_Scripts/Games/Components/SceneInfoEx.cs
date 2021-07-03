using UnityEngine;

/// <summary>
/// 类名 : 场景参数
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-21 10:37
/// 功能 : 场景的雾效，摄像机参数等
/// 修改 ：2020-10-10 10:02
/// </summary>
[AddComponentMenu("Scene/SceneInfoEx")]
public class SceneInfoEx : SceneBasicEx
{
	static public new SceneInfoEx Get(Object uobj,bool isAdd){
		return UtilityHelper.Get<SceneInfoEx>(uobj,isAdd);
	}

	static public new SceneInfoEx Get(Object uobj){
		return Get(uobj,true);
	}
}