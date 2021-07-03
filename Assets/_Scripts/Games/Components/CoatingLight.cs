using UnityEngine;

/// <summary>
/// 类名 : 人物角色阴暗分块处理(就是自身光照，或者全局环境光照)
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2021-06-25 10:19
/// 功能 : 结合工程，添加人物造影
/// 参考 : CelLight脚本 和 CoatingEffects的Shader内容
/// </summary>
public class CoatingLight : MonoBehaviour 
{
    static public CoatingLight Get(Object uobj,bool isAdd = true)
    {
        CoatingLight _ret = UtilityHelper.Get<CoatingLight>(uobj,isAdd);
        _ret?._Init();
        return _ret;
    }

	void Start ()
	{
        _Init();
	}

    bool _isInited = false;
    bool _needDestory = true;
    RendererMatData[] m_rmats = null;

    void _Init()
    {
        if(_isInited)
            return;
        _isInited = true;

        CharacterControllerEx cex = CharacterControllerEx.Get(this.gameObject,false);
        if(cex != null)
        {
            this.m_rmats = cex.m_skinDatas;
            this._needDestory = false;
            return;
        }

        //包含隐藏的Renderer
        Renderer[] _arrs = GetComponentsInChildren<Renderer>(true);
        Renderer _render = null;
        int _lens = _arrs.Length;
        this.m_rmats = new RendererMatData[_lens];
        for (int i = 0; i < _lens; ++i)
        {
            _render = _arrs[i];
            this.m_rmats[i] = RendererMatData.BuilderNew(_render);
        }
    }

    void OnDestroy()
    {
        RendererMatData[] _rmats = this.m_rmats;
        this.m_rmats = null;
        if(this._needDestory && _rmats != null)
        {
            int _lens = _rmats.Length;
            RendererMatData _it;
            for (int i = 0; i < _lens; ++i)
            {
                _it = _rmats[i];
                if(_it != null)
                    _it.ClearAll();
            }
        }
    }

    // Update is called once per frame
	void Update () 
	{
        Lighting();
	}

    private void Lighting()
    {
        if(this.m_rmats == null)
            return;
        int _lens = this.m_rmats.Length;
        int _lens2 = 0;
        RendererMatData _it;
        bool _hasLight = m_light != null;
        string _keyLigth,_keyShadow;
        Material _mat;
        for (int i = 0; i < _lens; ++i)
        {
            _it = this.m_rmats[i];
            if(_it == null)
                continue;
            _lens2 = _it.m_allMats.Count;
            for (int j = 0; j < _lens2; j++)
            {
                _mat = _it.m_allMats[j];
                if(_mat == null)
                    continue;
                _keyLigth = _hasLight ? "CUSTOM_LIGHT" : "UNITY_LIGHT";
                _mat.EnableKeyword(_keyLigth);
                if(_mat.IsKeywordEnabled(_keyLigth) && _hasLight)
                {
                    _mat.SetVector("_LightDir", -m_light.transform.forward);
                    _mat.SetColor("_LightColor", m_light.color);
                }

                _keyShadow = receiveShadows ? "RECEIVE_SHADOWS_ON" : "RECEIVE_SHADOWS_OFF";
                _mat.EnableKeyword(_keyShadow);
            }
        }
    }
    /// <summary>
    /// 自定义平行光
    /// 需要在Start前设置 否则无效
    /// 考虑参考Coating 自定义观察相机的方式 设置light时 主动设置一次材质的Keyword
    /// </summary>
    public Light m_light;
    /// <summary>
    /// 是否接受阴影
    /// 目前只有小房间的人才接受阴影
    /// </summary>
    public bool receiveShadows;

    public void SetLight(Object uobj)
    {
        Light _light = UtilityHelper.Get<Light>(uobj);
        this.m_light = _light;
    }
}
