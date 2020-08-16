using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// 类名 : 场景参数
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-21 10:37
/// 功能 : 场景的雾效，摄像机参数等
/// </summary>
// [ExecuteInEditMode]
public class SceneEx : MonoBehaviour
{
	static public SceneEx Get(GameObject gobj,bool isAdd){
		return UtilityHelper.Get<SceneEx>(gobj,isAdd);
	}

	static public SceneEx Get(GameObject gobj){
		return Get(gobj,true);
	}
	
	// fog 雾相关的属性
	public bool m_fogEnable = false;
	public FogMode m_fogMode;
	public Color m_fogColor;
	public float m_fogDensity = 0.0f;
	public float m_fogStartDistance = 0.0f;
	public float m_fogEndDistance = 0.0f;

	public Material m_skybox;
	public string[] m_userShaderHeads = {
		"custom/",
	};
	[HideInInspector] public bool m_isUserShader = false; // 是否是自己创建的
	public MatProperty[] m_skyboxTexs; // 记录默认skybox的材质所用贴图
	
	void Awake () {
        if(Application.isPlaying){
            LoadSettings();
        }
    }
	
#if UNITY_EDITOR
	bool IsCustomShader(string name){
		if(string.IsNullOrEmpty(name)) return false;
		string[] _arrs = m_userShaderHeads;
		
		name = name.ToLower();
		foreach(string it in _arrs){
			if(name.Contains(it))
				return true;
		}

		return false;
	}

	static MatProperty[] GetCertainMaterialTextures(Material material)
    {
        List<MatProperty> _ret = new List<MatProperty>();
		MatProperty _it = null;
        Shader shader = material.shader;
		string _pname;
		Texture _tex;
		UnityEditor.ShaderUtil.ShaderPropertyType _em_spt;
		int nLens = UnityEditor.ShaderUtil.GetPropertyCount(shader);
		int nLens2 = material.GetPropertyCount();
		Debug.LogErrorFormat("====[{0}] == [{1}]",nLens,nLens2);
		var _dic = material.GetTextureDic();
		foreach(var item in _dic){
			Debug.LogErrorFormat("====[{0}] == [{1}]",item.Key,item.Value);
		}
        for (int i = 0; i < nLens; ++i)
        {
			_em_spt = UnityEditor.ShaderUtil.GetPropertyType(shader,i);
			Debug.LogError(_em_spt);
            if (_em_spt == UnityEditor.ShaderUtil.ShaderPropertyType.TexEnv)
            {
                _pname = UnityEditor.ShaderUtil.GetPropertyName(shader, i);
                _tex = material.GetTexture(_pname);
				if(_tex != null){
					_it = new MatProperty(_pname,(int)_em_spt,_tex);
					_ret.Add(_it);
				}
            }
        }
        return _ret.ToArray();
	}

	[ContextMenu("Save Fog")]
	void _SaveSetting(){
		m_fogEnable = RenderSettings.fog;
		m_fogMode = RenderSettings.fogMode;
		m_fogColor = RenderSettings.fogColor;
		m_fogDensity = RenderSettings.fogDensity;
		m_fogStartDistance = RenderSettings.fogStartDistance;
		m_fogEndDistance = RenderSettings.fogEndDistance;
		
		Material skybox = RenderSettings.skybox;
		string _nmSkyShader = "";
		m_isUserShader = false;
		if(skybox != null){
			Shader _sd = skybox.shader;
			_nmSkyShader =  _sd.name;
			if(!string.IsNullOrEmpty(_nmSkyShader)){
				m_isUserShader = IsCustomShader(_nmSkyShader);
			}
			if(!m_isUserShader){
				m_skyboxTexs = GetCertainMaterialTextures(skybox);
			}
		}
	}
#endif

	[ContextMenu("Load Fog")]
	public void LoadSettings ()
	{
		RenderSettings.fog = m_fogEnable;
		RenderSettings.fogMode = m_fogMode;
		RenderSettings.fogColor = m_fogColor;
		RenderSettings.fogDensity = m_fogDensity;
		RenderSettings.fogStartDistance = m_fogStartDistance;
		RenderSettings.fogEndDistance = m_fogEndDistance;

		if(m_skybox != null){
			if(!m_isUserShader){
				if(m_skyboxTexs != null){
					int  nLens = m_skyboxTexs.Length;
					for (int i = 0; i < nLens; i++)
					{
						m_skyboxTexs[i].SetMatProperty(m_skybox);
					}
				}
			}
		}
		RenderSettings.skybox = m_skybox;
	}
}