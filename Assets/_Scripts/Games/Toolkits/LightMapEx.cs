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
	static readonly LightmapData[] ULMD_Empty = new LightmapData[0];
	static readonly SceneLightMapData[] SLMD_Empty = new SceneLightMapData[0];

	static public LightMapEx Get(GameObject gobj,bool isAdd){
		return UtilityHelper.Get<LightMapEx>(gobj,isAdd);
	}

	static public LightMapEx Get(GameObject gobj){
		return Get(gobj,true);
	}
	
	// 光照图列表
	public SceneLightMapData[] m_slmData;
	public LightmapsMode mode; //  = LightmapsMode.NonDirectional;

	[SerializeField] int m_nRLMD = 0;

	public string m_nameMInfo = "map_";

	// 光照图数据
	LightmapData[] _datas = null;
	public LightmapData[] lightmapDatas {
		get {
			int lens = (m_slmData == null) ? 0 : m_slmData.Length;
			if (lens <= 0) {
				return ULMD_Empty;
			}
			if (_datas == null) {
				_datas = new LightmapData[lens];
				for (int i = 0; i < lens; i++) {
					_datas [i] = m_slmData[i].ToLightmapData();
				}
			}
			return _datas;
		}
	}
	
	void Awake () {
        if(Application.isPlaying){
            _LoadLightmap();
        }
    }

	void Start () {
        if(Application.isPlaying){
            _LoadRenders();
        }
    }

	void OnDestroy(){
		ClearLightmapping ();
		_datas = null;
	}

	public int GetLen4RenderLMD(){
		var _lightmaps = LightmapSettings.lightmaps;
        if (_lightmaps != null) return _lightmaps.Length;
		return -1;
	}

#if UNITY_EDITOR
	// void OnDisable ()
	// {
    //     UnityEditor.Lightmapping.bakeCompleted -= SaveSettings; // completed
	// }
	
	// void OnEnable()
    // {
    //     UnityEditor.Lightmapping.bakeCompleted += SaveSettings;
    // }

	[ContextMenu("Save Settings")]
	void SaveSettings()
    {
		_SaveLightmap();
		_SaveMeshRenders();
	}

	[ContextMenu("Save Lightmap")]
    void _SaveLightmap()
    {
        mode = LightmapSettings.lightmapsMode;
        m_slmData = SLMD_Empty;
		var _lightmaps = LightmapSettings.lightmaps;
        if (_lightmaps != null && _lightmaps.Length > 0)
        {
            int _nlen = _lightmaps.Length;
            m_slmData = new SceneLightMapData[_nlen];
            for (int i = 0; i < _nlen; i++)
            {
                m_slmData[i] =  new SceneLightMapData(_lightmaps[i]);
            }
        }
	}

	[ContextMenu("Save Mesh Renders Info")]
	void _SaveMeshRenders(){
		m_nRLMD = GetLen4RenderLMD();

		if(string.IsNullOrEmpty(this.m_nameMInfo))
			this.m_nameMInfo = this.name;
		
		int m_nRender = 0;
		var _arrs = GetComponentsInChildren<Renderer>(true);
		int nLen = _arrs.Length;
		Renderer _render;
		LightMapRender _lmr;
		List<LightMapRender> _infos = new List<LightMapRender>();
		for (int i = 0; i < nLen; i++) {
			_render = _arrs[i];
			
			if(!LightMapRender.IsLightMapStatic(_render,m_nRLMD)) continue;
			
			_lmr = _GetLMRInfo(_infos,_render);
			if(_lmr != null){
				Debug.LogErrorFormat("========= has same name = [{0}]",_lmr.m_key);
				continue;
			}

			_lmr = LightMapRender.Builder(_render,m_nRLMD);
			if(_lmr == null) continue;

			_infos.Add(_lmr);
			m_nRender++;
		}
		LightMapRender.SaveInfos(this.m_nameMInfo,_infos);
		UnityEditor.AssetDatabase.Refresh();
		Debug.Log(m_nRender);
   	}
#endif

	[ContextMenu("Load Settings")]
	public void LoadSettings ()
	{
		_LoadLightmap();
		_LoadRenders();
	}

	void _LoadLightmap ()
	{
		LightmapSettings.lightmapsMode = mode;
		LightmapSettings.lightmaps = lightmapDatas;
	}

	public void ClearLightmapping()
	{
		LightmapSettings.lightmaps = ULMD_Empty;
	}

	LightMapRender _GetLMRInfo(List<LightMapRender> infos,Renderer render){
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

	void _BackToRender(List<LightMapRender> infos,Renderer render){
		LightMapRender _it = _GetLMRInfo(infos,render);
		if(_it == null) return;
		_it.BackToRender(render);
	}

	void _LoadRenders(){
		List<LightMapRender> _infos = LightMapRender.GetInfos(this.m_nameMInfo);
		if(_infos == null) return;

		m_nRLMD = GetLen4RenderLMD();

		var _arrs = GetComponentsInChildren<Renderer>(true);
		int nLen = _arrs.Length;
		Renderer _render;
		for (int i = 0; i < nLen; i++) {
			_render = _arrs[i];
			if(LightMapRender.IsEmptyRMap(_render,m_nRLMD)) continue;
			if("gbox".Equals(_render.name) || "gbox".Equals(_render.transform.parent.name))	continue;
			_BackToRender(_infos,_render);
		}
   	}
}
