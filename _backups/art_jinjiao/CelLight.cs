using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// 自定义平行光 (Coating & ACoating)
/// 是否接收阴影 (Coating)
/// 小房间家具和小房间人物都有该脚本
/// 不要和Coating同时使用
/// </summary>
public class CelLight : MonoBehaviour 
{
	void Start ()
	{
        INit();        
	}

    private void INit()
    {
        if (0 == materials.Count)
        {            
            //包含隐藏的Renderer
            Renderer[] render = GetComponentsInChildren<Renderer>(true);
            for (int i = 0; i < render.Length; ++i)
            {
                for (int j = 0; j < render[i].sharedMaterials.Length; ++j)
                {
                    Material mat = render[i].sharedMaterials[j];
                    if (null == mat || null == mat.shader)
                        continue;
                    if (!materials.ContainsKey(mat))
                    {
                        bool flag = false;
                        //小房间墙饰用Shader ACoating 有alpha混合
                        //不接收阴影 无RECEIVE_SHADOWS_ON, RECEIVE_SHADOWS_OFF
                        if (mat.shader.name == "Custom/Coating"
                            || mat.shader.name == "Custom/ACoating")
                        {                            
                            //设置自定义灯光
                            if (null != m_light)
                            {
                                mat.EnableKeyword("CUSTOM_LIGHT");
                                mat.DisableKeyword("UNITY_LIGHT");
                            }
                            else
                            {
                                mat.EnableKeyword("UNITY_LIGHT");
                                mat.DisableKeyword("CUSTOM_LIGHT");
                            }

                            flag = true;
                        }
                        if (mat.shader.name == "Custom/Coating")
                        {
                            //是否接收阴影
                            if (receiveShadows)
                            {
                                mat.EnableKeyword("RECEIVE_SHADOWS_ON");
                                mat.DisableKeyword("RECEIVE_SHADOWS_OFF");
                            }
                            else
                            {
                                mat.EnableKeyword("RECEIVE_SHADOWS_OFF");
                                mat.DisableKeyword("RECEIVE_SHADOWS_ON");
                            }

                            flag = true;
                        }
                        
                        //只添加Coating和ACoating
                        if(flag)
                            materials.Add(mat, render[i].transform);                        
                    }                 
                }
            }            
        }
    }

    /// <summary>
    /// 手动刷新
    /// </summary>
    public void Refresh()
    {
        materials.Clear();
        INit();        
    }

	// Update is called once per frame
	void Update () 
	{
        Lighting();        
	}

    private void Lighting()
    {        
        if (null == m_light || 0 == materials.Count)
            return;

        if (!m_light.transform.hasChanged)
            return;

        var itor = materials.GetEnumerator();
        while (itor.MoveNext())
        {
            Material mat = itor.Current.Key;            
            mat.SetVector("_LightDir", -m_light.transform.forward);
            mat.SetColor("_LightColor", m_light.color);
        }
        itor.Dispose();        
    }    

    /// <summary>
    /// 自定义平行光
    /// 需要在Start前设置 否则无效
    /// 考虑参考Coating 自定义观察相机的方式 设置light时 主动设置一次材质的Keyword
    /// </summary>
    public Light m_light;   
    /// <summary>
    /// 受自定义平行光影响的材质
    /// </summary>    
    public Dictionary<Material, Transform> materials = new Dictionary<Material, Transform>();
    /// <summary>
    /// 是否接受阴影
    /// 目前只有小房间的人才接受阴影
    /// </summary>
    public bool receiveShadows;
    /// <summary>
    /// 是否由UI摄像机渲染(影响描边修正参数)
    /// </summary>
    public bool UI;
}
