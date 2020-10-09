using UnityEngine;
using UnityEngine.Rendering;
using System.Collections;

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

	// Environment 相关
	public Material m_skybox;
	public Light m_sunlight;

	// ambient
	public SphericalHarmonicsL2 m_ambientProbe;
	public Color m_ambientLight;
	public Color m_ambientGroundColor;
	public Color m_ambientEquatorColor;
	public Color m_ambientSkyColor;
	public AmbientMode m_ambientMode;
	public float m_ambientIntensity;

	// reflection
	public DefaultReflectionMode m_reflectionSource;
	public int m_defaultReflectionResolution;
	public int m_reflectionBounces;
	public float m_reflectionIntensity;
	public Cubemap m_customReflection;

	// flare
	public float m_flareStrength;
	public float m_flareFadeSpeed;

	void Start () {
        if(Application.isPlaying){
            LoadSetting();
        }
    }
	
#if UNITY_EDITOR
	[ContextMenu("Save RenderSettings")]
	void _SaveSetting(){
		_SaveFog();
		_SaveEnvironment();
	}

	void _SaveFog(){
		m_fogEnable = RenderSettings.fog;
		m_fogMode = RenderSettings.fogMode;
		m_fogColor = RenderSettings.fogColor;
		m_fogDensity = RenderSettings.fogDensity;
		m_fogStartDistance = RenderSettings.fogStartDistance;
		m_fogEndDistance = RenderSettings.fogEndDistance;
	}

	void _SaveEnvironment(){
		m_skybox = RenderSettings.skybox;
		m_sunlight = RenderSettings.sun;

		m_ambientProbe = RenderSettings.ambientProbe;
		m_ambientLight = RenderSettings.ambientLight;
		m_ambientGroundColor = RenderSettings.ambientGroundColor;
		m_ambientEquatorColor = RenderSettings.ambientEquatorColor;
		m_ambientSkyColor = RenderSettings.ambientSkyColor;
		m_ambientMode = RenderSettings.ambientMode;
		m_ambientIntensity = RenderSettings.ambientIntensity;

		m_reflectionSource = RenderSettings.defaultReflectionMode;
		m_defaultReflectionResolution = RenderSettings.defaultReflectionResolution;
		m_reflectionBounces = RenderSettings.reflectionBounces;
		m_reflectionIntensity = RenderSettings.reflectionIntensity;
		m_customReflection = RenderSettings.customReflection;

		m_flareStrength = RenderSettings.flareStrength;
		m_flareFadeSpeed = RenderSettings.flareFadeSpeed;
	}
#endif

	void _LoadFog(){
		RenderSettings.fog = m_fogEnable;
		RenderSettings.fogMode = m_fogMode;
		RenderSettings.fogColor = m_fogColor;
		RenderSettings.fogDensity = m_fogDensity;
		RenderSettings.fogStartDistance = m_fogStartDistance;
		RenderSettings.fogEndDistance = m_fogEndDistance;
	}

	void _LoadSkyBox(){
		RenderSettings.skybox = m_skybox;
		// RenderSettings.sun = m_sunlight;
	}

	void _LoadEnvironment(){
		RenderSettings.ambientProbe = m_ambientProbe;
		RenderSettings.ambientLight = m_ambientLight;
		RenderSettings.ambientGroundColor = m_ambientGroundColor;
		RenderSettings.ambientEquatorColor = m_ambientEquatorColor;
		RenderSettings.ambientSkyColor = m_ambientSkyColor;
		RenderSettings.ambientMode = m_ambientMode;
		RenderSettings.ambientIntensity = m_ambientIntensity;

		RenderSettings.defaultReflectionMode = m_reflectionSource;
		RenderSettings.defaultReflectionResolution = m_defaultReflectionResolution;
		RenderSettings.reflectionBounces = m_reflectionBounces;
		RenderSettings.reflectionIntensity = m_reflectionIntensity;
		RenderSettings.customReflection = m_customReflection;

		RenderSettings.flareStrength = m_flareStrength;
		RenderSettings.flareFadeSpeed = m_flareFadeSpeed;
	}

	[ContextMenu("Load RenderSettings")]
	public void LoadSetting ()
	{
		_LoadFog();
		_LoadSkyBox();
		// _LoadEnvironment();
	}
}