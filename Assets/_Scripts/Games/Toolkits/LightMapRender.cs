using UnityEngine;
using UnityEngine.Rendering;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// 类名 : Render的lightmap渲染
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-21 10:37
/// 功能 : 
/// </summary>
[System.Serializable]
public class LightMapRender : RenderLightMapData
{
	static System.Type TP_LPU = typeof(LightProbeUsage);

	public string m_key;
	public int m_em_lpu;

	public int m_sfX,m_sfY,m_sfZ,m_sfW;
	public int m_sfX_1,m_sfY_1,m_sfZ_1,m_sfW_1;
	public int m_rsfX,m_rsfY,m_rsfZ,m_rsfW;
	public int m_rsfX_1,m_rsfY_1,m_rsfZ_1,m_rsfW_1;

	public LightMapRender(){}

	public LightMapRender(int lightmapIndex,Vector4 lightmapScaleOffset,LightProbeUsage lightProbeUsage,int realtimeLightmapIndex,Vector4 realtimeLightmapScaleOffset){
		base.Init(lightmapIndex,lightmapScaleOffset,lightProbeUsage,realtimeLightmapIndex,realtimeLightmapScaleOffset);
	}

	(int,int) _ToIntAndMultiple(float fVal){
		int val = -1;
		int mul = 1;
		string _v = fVal.ToString();
		if(_v.IndexOf(".") != -1){
			string[] _arrs = _v.Split('.');
			int _n = _arrs[1].Length;
			for (int i = 0; i < _n; i++)
			{
				mul *= 10;
			}
		}
		val = (int) (fVal * mul);
		return (val,mul);
	}

	protected override void OnInit(){
		this.m_em_lpu = (int) this.m_lightProbeUsage;

		(this.m_sfX,this.m_sfX_1) = _ToIntAndMultiple(this.m_lightmapScaleOffset.x);
		(this.m_sfY,this.m_sfY_1) = _ToIntAndMultiple(this.m_lightmapScaleOffset.y);
		(this.m_sfZ,this.m_sfZ_1) = _ToIntAndMultiple(this.m_lightmapScaleOffset.z);
		(this.m_sfW,this.m_sfW_1) = _ToIntAndMultiple(this.m_lightmapScaleOffset.w);
		
		(this.m_rsfX,this.m_rsfX_1) = _ToIntAndMultiple(this.m_realtimeLightmapScaleOffset.x);
		(this.m_rsfY,this.m_rsfY_1) = _ToIntAndMultiple(this.m_realtimeLightmapScaleOffset.y);
		(this.m_rsfZ,this.m_rsfZ_1) = _ToIntAndMultiple(this.m_realtimeLightmapScaleOffset.z);
		(this.m_rsfW,this.m_rsfW_1) = _ToIntAndMultiple(this.m_realtimeLightmapScaleOffset.w);
	}

	public LightMapRender ReBack(){
		this.m_lightProbeUsage = (LightProbeUsage)System.Enum.ToObject(TP_LPU,this.m_em_lpu);
		
		int acc = 2; // 保留几位小数
		float _x,_y,_z,_w;

		_x = UtilityHelper.Round(this.m_sfX / (double) this.m_sfX_1,acc);
		_y = UtilityHelper.Round(this.m_sfY / (double) this.m_sfY_1,acc);
		_z = UtilityHelper.Round(this.m_sfZ / (double) this.m_sfZ_1,acc);
		_w = UtilityHelper.Round(this.m_sfW / (double) this.m_sfW_1,acc);

		this.m_lightmapScaleOffset.x = _x;
		this.m_lightmapScaleOffset.y = _y;
		this.m_lightmapScaleOffset.z = _z;
		this.m_lightmapScaleOffset.w = _w;

		// Debug.LogFormat("===[{0}] === [{1}] = [{2}] = [{3}] = [{4}] = [{5}]",this.m_lightmapScaleOffset,new Vector4(_x,_y,_z,_w),_x,_y,_z,_w);
		
		_x = UtilityHelper.Round(this.m_rsfX / (double) this.m_rsfX_1,acc);
		_y = UtilityHelper.Round(this.m_rsfY / (double) this.m_rsfY_1,acc);
		_z = UtilityHelper.Round(this.m_rsfZ / (double) this.m_rsfZ_1,acc);
		_w = UtilityHelper.Round(this.m_rsfW / (double) this.m_rsfW_1,acc);

		this.m_realtimeLightmapScaleOffset.x = _x;
		this.m_realtimeLightmapScaleOffset.y = _y;
		this.m_realtimeLightmapScaleOffset.z = _z;
		this.m_realtimeLightmapScaleOffset.w = _w;
		return this;
	}

	static public new LightMapRender Builder(Renderer renderer,int nLenLMap){
		if(!IsLightMapStatic(renderer,nLenLMap)) return null;

		LightMapRender ret = new LightMapRender().Init(renderer) as LightMapRender;
		ret.m_key = string.Format("[{0}]_[{1}]",renderer.name,renderer.GetType());
		return ret;
	}
	
	static public LightMapRender Builder(Renderer renderer,int index,int nLenLMap){
		LightMapRender _ret = Builder(renderer,nLenLMap);
		if(_ret == null) return null;
		
		_ret.m_key = string.Format("[{0}]_[{1}]_[{2}]",index,renderer.name,renderer.GetType());
		return _ret;
	}

	static public LightMapRender Builder(Renderer renderer){
		int _nLen = -1;
		var _lightmaps = LightmapSettings.lightmaps;
        if (_lightmaps != null && _lightmaps.Length > 0){
			_nLen = _lightmaps.Length;
		}
		return Builder(renderer,_nLen);
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
		string _vc = LitJson.JsonMapper.ToJson(infos);
		if(string.IsNullOrEmpty(_vc)) return false;
		Core.GameFile.WriteText(fname,_vc);
		return true;
	}

	static public List<LightMapRender> GetInfos(string fname){
		fname = ReFname(fname);
		if(string.IsNullOrEmpty(fname)) return null;
		string _vc = Core.GameFile.GetText(fname);
		if(string.IsNullOrEmpty(_vc)) return null;
		LitJson.JsonData _jd = LitJson.JsonMapper.ToObject<LitJson.JsonData>(_vc);
		List<LightMapRender> _ret = new List<LightMapRender>();
		LightMapRender _obj = null;
		string _val = null;
		foreach(LitJson.JsonData item in _jd)
		{
			_val = item.ToJson();
			_obj = LitJson.JsonMapper.ToObject<LightMapRender>(_val);
			_ret.Add(_obj.ReBack());
		}
		return _ret;
	}
}