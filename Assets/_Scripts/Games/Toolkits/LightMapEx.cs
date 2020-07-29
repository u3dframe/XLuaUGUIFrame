using UnityEngine;
using System.Collections;

/// <summary>
/// 类名 : 烘培光照贴图
/// 作者 : Canyon
/// 日期 : 2017-03-21 10:37
/// 功能 : 场景烘培的贴图信息
/// </summary>
[ExecuteInEditMode]
public class LightmapEx : MonoBehaviour
{
	static readonly LightmapData[] ltEmpty = new LightmapData[0];
	static public LightmapEx Get(GameObject gobj,bool isAdd){
		return UtilityHelper.Get<LightmapEx>(gobj,isAdd);
	}

	static public LightmapEx Get(GameObject gobj){
		return Get(gobj,true);
	}
	
	// 光照图列表
	public Texture2D[] lightmapFar, lightmapNear;
	public LightmapsMode mode; //  = LightmapsMode.NonDirectional;
	
	// 光照图数据
	LightmapData[] _datas = null;

	public LightmapData[] lightmapDatas {
		get {
			int l1 = (lightmapFar == null) ? 0 : lightmapFar.Length;
			int l2 = (lightmapNear == null) ? 0 : lightmapNear.Length;
			int lens = (l1 < l2) ? l2 : l1;
			if (lens <= 0) {
				return null;
			}
			if (_datas == null) {
				_datas = new LightmapData[lens];
				LightmapData _ld;
				for (int i = 0; i < lens; i++) {
					_ld = new LightmapData ();
					if(i < l1) _ld.lightmapColor = lightmapFar [i];
					if(i < l2) _ld.lightmapDir = lightmapNear [i];
					_datas [i] = _ld;
				}
			}
			return _datas;
		}
	}
	
	[ContextMenu("Load Lightmap")]
	public void LoadSettings ()
	{
		LightmapSettings.lightmapsMode = mode;
		LightmapData[] data = lightmapDatas;
		if (data != null) {
			LightmapSettings.lightmaps = data;
		} else {
			ClearLightmapping ();
		}
	}

	public void ClearLightmapping ()
	{
		LightmapSettings.lightmaps = ltEmpty;
	}

	void Awake () {
        if(Application.isPlaying){
            LoadSettings();
        }
    }

	void OnDisable ()
	{
#if UNITY_EDITOR
        UnityEditor.Lightmapping.bakeCompleted -= SaveSettings; // completed
#else
		ClearLightmapping ();
#endif
	}

#if UNITY_EDITOR
	void OnEnable()
    {
        UnityEditor.Lightmapping.bakeCompleted += SaveSettings;
    }
	
	[ContextMenu("Save Lightmap")]
	public void SaveSettings()
    {
        mode = LightmapSettings.lightmapsMode;
        lightmapFar = null;
        lightmapNear = null;
		var _lightmaps = LightmapSettings.lightmaps;
        if (_lightmaps != null && _lightmaps.Length > 0)
        {
            int lens = _lightmaps.Length;
            lightmapFar = new Texture2D[lens];
            lightmapNear = new Texture2D[lens];
            for (int i = 0; i < lens; i++)
            {
                lightmapFar[i] = _lightmaps[i].lightmapColor;
                lightmapNear[i] = _lightmaps[i].lightmapDir;
            }
        }
   }
#endif
}
