using UnityEngine;
using System.Collections;

/// <summary>
/// 类名 : 场景参数
/// 作者 : Canyon
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
	
	void Awake () {
        if(Application.isPlaying){
            LoadSettings();
        }
    }
	
#if UNITY_EDITOR
	[ContextMenu("Save Fog")]
	void _SaveFogSetting(){
		m_fogEnable = RenderSettings.fog;
		m_fogMode = RenderSettings.fogMode;
		m_fogColor = RenderSettings.fogColor;
		m_fogDensity = RenderSettings.fogDensity;
		m_fogStartDistance = RenderSettings.fogStartDistance;
		m_fogEndDistance = RenderSettings.fogEndDistance;
		m_skybox = RenderSettings.skybox;
	}
#endif

	[ContextMenu("Load Fog")]
	public void LoadFogSetting ()
	{
		RenderSettings.fog = m_fogEnable;
		RenderSettings.fogMode = m_fogMode;
		RenderSettings.fogColor = m_fogColor;
		RenderSettings.fogDensity = m_fogDensity;
		RenderSettings.fogStartDistance = m_fogStartDistance;
		RenderSettings.fogEndDistance = m_fogEndDistance;
		RenderSettings.skybox = m_skybox;
	}
	
	[ContextMenu("Load Scene Setting")]
	void LoadSettings(){
		LoadFogSetting();
	}
}