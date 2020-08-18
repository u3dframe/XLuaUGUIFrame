using UnityEngine;
using UnityEngine.Rendering;
using System;
using System.Collections;
using System.Collections.Generic;
using LitJson;
using Core;

/// <summary>
/// 类名 : Render的lightmap渲染
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-21 10:37
/// 功能 : 
/// </summary>
[Serializable]
public class LightMapRender
{
	static Type TP_LPU = typeof(LightProbeUsage);

	public string m_key;
	public int m_lightmapIndex;
	public int m_realtimeLightmapIndex;

	public int m_em_lpu = (int)LightProbeUsage.Off;

	public double m_sfX,m_sfY,m_sfZ,m_sfW;
	public double m_rsfX,m_rsfY,m_rsfZ,m_rsfW;

	LightProbeUsage m_lightProbeUsage = LightProbeUsage.Off;
	Vector4 m_lightmapScaleOffset = Vector4.zero;
	Vector4 m_realtimeLightmapScaleOffset = Vector4.zero;
	//GameObject m_lightProbeProxyVolumeOverride; // lightProbeProxyVolumeOverride

	public LightMapRender(){}
	public LightMapRender(int lightmapIndex,Vector4 lightmapScaleOffset,LightProbeUsage lightProbeUsage,int realtimeLightmapIndex,Vector4 realtimeLightmapScaleOffset){
		Init(lightmapIndex,lightmapScaleOffset,lightProbeUsage,realtimeLightmapIndex,realtimeLightmapScaleOffset);
	}

	public LightMapRender Init(int lightmapIndex,Vector4 lightmapScaleOffset,LightProbeUsage lightProbeUsage,int realtimeLightmapIndex,Vector4 realtimeLightmapScaleOffset){
		this.m_lightmapIndex = lightmapIndex;
		this.m_lightmapScaleOffset = lightmapScaleOffset;
		this.m_lightProbeUsage = lightProbeUsage;
		this.m_realtimeLightmapIndex = realtimeLightmapIndex;
		this.m_realtimeLightmapScaleOffset = realtimeLightmapScaleOffset;
		// this.m_lightProbeProxyVolumeOverride = lightProbeProxyVolumeOverride;

		this.m_em_lpu = (int) this.m_lightProbeUsage;
		this.m_sfX = this.m_lightmapScaleOffset.x;
		this.m_sfY = this.m_lightmapScaleOffset.y;
		this.m_sfZ = this.m_lightmapScaleOffset.z;
		this.m_sfW = this.m_lightmapScaleOffset.w;
		
		this.m_rsfX = this.m_realtimeLightmapScaleOffset.x;
		this.m_rsfY = this.m_realtimeLightmapScaleOffset.y;
		this.m_rsfZ = this.m_realtimeLightmapScaleOffset.z;
		this.m_rsfW = this.m_realtimeLightmapScaleOffset.w;
		return this;
	}

	public LightMapRender ReBack(){
		this.m_lightProbeUsage = (LightProbeUsage)Enum.ToObject(TP_LPU,this.m_em_lpu);

		this.m_lightmapScaleOffset.x = (float) this.m_sfX;
		this.m_lightmapScaleOffset.y = (float) this.m_sfY;
		this.m_lightmapScaleOffset.z = (float) this.m_sfZ;
		this.m_lightmapScaleOffset.w = (float) this.m_sfW;
		
		this.m_realtimeLightmapScaleOffset.x = (float) this.m_rsfX;
		this.m_realtimeLightmapScaleOffset.y = (float) this.m_rsfY;
		this.m_realtimeLightmapScaleOffset.z = (float) this.m_rsfZ;
		this.m_realtimeLightmapScaleOffset.w = (float) this.m_rsfW;
		return this;
	}

	public LightMapRender Init(Renderer renderer){
		return Init(renderer.lightmapIndex,renderer.lightmapScaleOffset,renderer.lightProbeUsage,renderer.realtimeLightmapIndex,renderer.realtimeLightmapScaleOffset);
	}

	public void BackToRender(Renderer renderer){
		if(renderer == null) return;
		renderer.lightmapIndex = this.m_lightmapIndex;
		renderer.lightmapScaleOffset = this.m_lightmapScaleOffset;
		renderer.lightProbeUsage = this.m_lightProbeUsage;
		renderer.realtimeLightmapIndex = this.m_realtimeLightmapIndex;
		renderer.realtimeLightmapScaleOffset = this.m_realtimeLightmapScaleOffset;
		// renderer.lightProbeProxyVolumeOverride = this.m_lightProbeProxyVolumeOverride;
	}

	static public LightMapRender Builder(Renderer renderer,int index){
		if(renderer == null) return null;
		LightMapRender ret = new LightMapRender().Init(renderer);
		ret.m_key = string.Format("[{0}]_[{1}]_[{2}]",index,renderer.name,renderer.GetType());
		return ret;
	}

	static public LightMapRender Builder(Renderer renderer){
		if(renderer == null) return null;
		LightMapRender ret = new LightMapRender().Init(renderer);
		ret.m_key = string.Format("[{0}]_[{1}]",renderer.name,renderer.GetType());
		return ret;
	}

	static public string ReFname(string fname){
		if(string.IsNullOrEmpty(fname)) return null;
		if(!fname.StartsWith("maps/")) fname = "maps/" + fname;
		if(!fname.EndsWith(".minfo")) fname += ".minfo";
		return fname;
	}

	static public bool SaveInfos(string fname,List<LightMapRender> infos){
		if(infos == null || infos.Count <= 0) return false;
		fname = ReFname(fname);
		if(string.IsNullOrEmpty(fname)) return false;
		string _vc = JsonMapper.ToJson(infos);
		if(string.IsNullOrEmpty(_vc)) return false;
		GameFile.WriteText(fname,_vc);
		return true;
	}

	static public List<LightMapRender> GetInfos(string fname){
		fname = ReFname(fname);
		if(string.IsNullOrEmpty(fname)) return null;
		string _vc = GameFile.GetText(fname);
		if(string.IsNullOrEmpty(_vc)) return null;
		JsonData _jd = JsonMapper.ToObject<JsonData>(_vc);
		List<LightMapRender> _ret = new List<LightMapRender>();
		LightMapRender _obj = null;
		string _val = null;
		foreach(JsonData item in _jd)
		{
			_val = item.ToJson();
			_obj = JsonMapper.ToObject<LightMapRender>(_val);
			_ret.Add(_obj.ReBack());
		}
		return _ret;
	}
}