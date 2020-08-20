using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 类名 : Render的lightmap渲染数据
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-08-19 09:27
/// 功能 : 
/// </summary>
[System.Serializable]
public class RenderLightMapData
{
	public int m_lightmapIndex = -1;
	protected Vector4 m_lightmapScaleOffset = Vector4.zero;

	protected LightProbeUsage m_lightProbeUsage = LightProbeUsage.Off;
	
	public int m_realtimeLightmapIndex = -1;
	protected Vector4 m_realtimeLightmapScaleOffset = Vector4.zero;
	// GameObject m_lightProbeProxyVolumeOverride; // lightProbeProxyVolumeOverride

	public RenderLightMapData(){}
	
	public RenderLightMapData Init(int lightmapIndex,Vector4 lightmapScaleOffset,LightProbeUsage lightProbeUsage,int realtimeLightmapIndex,Vector4 realtimeLightmapScaleOffset){
		this.m_lightmapIndex = lightmapIndex;
		this.m_lightmapScaleOffset = lightmapScaleOffset;
		this.m_lightProbeUsage = lightProbeUsage;
		this.m_realtimeLightmapIndex = realtimeLightmapIndex;
		this.m_realtimeLightmapScaleOffset = realtimeLightmapScaleOffset;
		// this.m_lightProbeProxyVolumeOverride = lightProbeProxyVolumeOverride;
		this.OnInit();
		return this;
	}

	public RenderLightMapData Init(Renderer renderer){
		return Init(renderer.lightmapIndex,renderer.lightmapScaleOffset,renderer.lightProbeUsage,renderer.realtimeLightmapIndex,renderer.realtimeLightmapScaleOffset);
	}

	protected virtual void OnInit(){}
	
	public void BackToRender(Renderer renderer){
		if(renderer == null) return;
		// renderer.gameObject.isStatic = true;
		renderer.lightmapIndex = this.m_lightmapIndex;
		renderer.lightmapScaleOffset = this.m_lightmapScaleOffset;
		renderer.lightProbeUsage = this.m_lightProbeUsage;
		renderer.realtimeLightmapIndex = this.m_realtimeLightmapIndex;
		renderer.realtimeLightmapScaleOffset = this.m_realtimeLightmapScaleOffset;
		// renderer.lightProbeProxyVolumeOverride = this.m_lightProbeProxyVolumeOverride;
		// renderer.gameObject.isStatic = false;
	}

	void LogErrorRenderer(Renderer renderer){
		if(renderer == null) return;

		string fmt = "render = [{0}],lightmapIndex = [{1}],lightmapScaleOffset = [{2}],lightProbeUsage = [{3}],realtimeLightmapIndex = [{4}],realtimeLightmapScaleOffset = [{5}]";
		string _str =  string.Format (
			fmt,
			renderer.name,
			renderer.lightmapIndex,
			renderer.lightmapScaleOffset,
			renderer.lightProbeUsage,
			renderer.realtimeLightmapIndex,
			renderer.realtimeLightmapScaleOffset
		);

		Debug.LogError(_str);
	}

	public override string ToString ()
	{
		string fmt = "lightmapIndex = [{0}],lightmapScaleOffset = [{1}],lightProbeUsage = [{2}],realtimeLightmapIndex = [{3}],realtimeLightmapScaleOffset = [{4}]";
		return string.Format (
			fmt,
			this.m_lightmapIndex,
			this.m_lightmapScaleOffset,
			this.m_lightProbeUsage,
			this.m_realtimeLightmapIndex,
			this.m_realtimeLightmapScaleOffset
		);
	}

	static public bool IsEmptyRMap(Renderer renderer,int nLenLMap){
		return nLenLMap <= 0 || renderer == null;
	}

	static public bool IsLightMap(Renderer renderer,int nLenLMap){
		if(IsEmptyRMap(renderer,nLenLMap)) return false;
		if(renderer.lightmapIndex < 0 || nLenLMap <= renderer.lightmapIndex) return false;
		return true;
	}

	static public bool IsLightMapStatic(Renderer renderer,int nLenLMap){
		if(IsLightMap(renderer,nLenLMap)) return renderer.gameObject.isStatic;
		return false;
	}

	static public RenderLightMapData Builder(Renderer renderer,int nLenLMap){
		if(!IsLightMapStatic(renderer,nLenLMap)) return null;
		return new RenderLightMapData().Init(renderer);
	}
}