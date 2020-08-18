using UnityEngine;
using UnityEngine.Rendering;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// 类名 : 烘培光照贴图
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-21 10:37
/// 功能 : 场景烘培的贴图信息
/// </summary>
[ExecuteInEditMode]
public class LightMapEx : MonoBehaviour
{
	static readonly LightmapData[] ltEmpty = new LightmapData[0];
	static public LightMapEx Get(GameObject gobj,bool isAdd){
		return UtilityHelper.Get<LightMapEx>(gobj,isAdd);
	}

	static public LightMapEx Get(GameObject gobj){
		return Get(gobj,true);
	}
	
	// 光照图列表
	public Texture2D[] lightmapFar,lightmapNear,lightMask;
	public LightmapsMode mode; //  = LightmapsMode.NonDirectional;

	
	System.Type _tpExPsr = typeof(ParticleSystemRenderer);

	[SerializeField]
	int m_nRender = 0;

	public string m_nameMInfo = "map_";

	int NMax(params int[] vals){
		if(vals == null || vals.Length <= 0) return 0;
		int max = vals[0];
		for (int i = 1; i < vals.Length; i++)
		{
			if(max < vals[i]){
				max = vals[i];
			}
		}
		return max;
	}
	
	// 光照图数据
	LightmapData[] _datas = null;
	public LightmapData[] lightmapDatas {
		get {
			int l1 = (lightmapFar == null) ? 0 : lightmapFar.Length;
			int l2 = (lightmapNear == null) ? 0 : lightmapNear.Length;
			int l3 = (lightMask == null) ? 0 : lightMask.Length;
			int lens = NMax(l1,l2,l3);
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
					if(i < l3) _ld.shadowMask = lightMask [i];
					_datas [i] = _ld;
				}
			}
			return _datas;
		}
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

	void OnDestroy(){
		_datas = null;
	}

#if UNITY_EDITOR
	void OnEnable()
    {
        UnityEditor.Lightmapping.bakeCompleted += SaveSettings;
    }
	
	[ContextMenu("Save LMapSettings")]
	void SaveSettings()
    {
        _SaveLightmap();
		_SaveRenders();
	}

	[ContextMenu("Save Lightmap")]
    void _SaveLightmap()
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
			lightMask = new Texture2D[lens];
            for (int i = 0; i < lens; i++)
            {
                lightmapFar[i] = _lightmaps[i].lightmapColor;
                lightmapNear[i] = _lightmaps[i].lightmapDir;
				lightMask[i] = _lightmaps[i].shadowMask;
            }
        }		
	}

	[ContextMenu("Save LightmapInfo")]
	void _SaveRenders(){
		if(string.IsNullOrEmpty(this.m_nameMInfo))
			this.m_nameMInfo = this.name;
		
		m_nRender = 0;
		var _arrs = GetComponentsInChildren<Renderer>(true);
		int nLen = _arrs.Length;
		Renderer _render;
		LightMapRender _lmr;
		List<LightMapRender> _infos = new List<LightMapRender>();
		for (int i = 0; i < nLen; i++) {
			_render = _arrs[i];
			if("gbox".Equals(_render.name) || "gbox".Equals(_render.transform.parent.name))
				continue;
			
			if(_tpExPsr == _render.GetType())
				continue;

			m_nRender++;

			_lmr = _RenderInfo(_infos,_render);
			if(_lmr != null){
				Debug.LogErrorFormat("========= has same name = [{0}]",_lmr.m_key);
				continue;
			}
			_lmr = LightMapRender.Builder(_render);
			_infos.Add(_lmr);
		}
		LightMapRender.SaveInfos(this.m_nameMInfo,_infos);
   	}
#endif

	[ContextMenu("Load LMapSettings")]
	public void LoadSettings ()
	{
		_LoadLightmap();
		_LoadRenders();
	}

	void _LoadLightmap ()
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

	void _BackToRender(List<LightMapRender> infos,Renderer render){
		LightMapRender _it = _RenderInfo(infos,render);
		if(_it == null) return;
		_it.BackToRender(render);
	}

	LightMapRender _RenderInfo(List<LightMapRender> infos,Renderer render){
		if(render == null) return null;
		int lens = infos.Count;
		string _key = string.Format("[{0}]_[{1}]",render.name,render.GetType());
		LightMapRender _it;
		for (int i = 0; i < lens; i++)
		{
			_it = infos[i];
			if(_key.Equals(_it.m_key)){
				return _it;
			}
		}
		return null;
	}

	void _LoadRenders(){
		List<LightMapRender> _infos = LightMapRender.GetInfos(this.m_nameMInfo);
		if(_infos == null) return;

		var _arrs = GetComponentsInChildren<Renderer>(true);
		int nLen = _arrs.Length;
		Renderer _render;
		for (int i = 0; i < nLen; i++) {
			_render = _arrs[i];
			if("gbox".Equals(_render.name) || "gbox".Equals(_render.transform.parent.name))
				continue;
			
			if(_tpExPsr == _render.GetType())
				continue;
			
			_BackToRender(_infos,_render);
		}
   	}
}
