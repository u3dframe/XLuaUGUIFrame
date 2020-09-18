using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Coating Shader设置脚本
/// 自定义观察摄像机的位置
/// 需要Coating Shader的战斗单位都需要该脚本
/// 不要和CelLight同时使用
/// </summary>
public class Coating : MonoBehaviour
{  
    void Awake()
    {
        INit();
    }

    public void INit()
    {
        if (0 == materials.Count)
        {            
            Renderer[] render = GetComponentsInChildren<Renderer>(true);
            for (int i = 0; i < render.Length; ++i)
            {
                for (int j = 0; j < render[i].sharedMaterials.Length; ++j)
                {
                    Material mat = render[i].sharedMaterials[j];
                    if (null == mat || null == mat.shader)
                        continue;
                    if (!materials.ContainsKey(mat) && mat.shader.name == "Custom/Coating")
                        materials.Add(mat, render[i].transform);                    
                }
            }            

            //自定义摄像机位置
            CustomCamera(view);                     
        }        
    }

#if UNITY_EDITOR
    void Update()
    {
        CustomCamera(view);        
    }
#endif   

    /// <summary>
    /// 自定义摄像机位置 取代shader中的_WorldSpaceCameraPos
    /// </summary>
    /// <param name="position"></param>
    public void CustomCamera(Transform view)
    {
        this.view = view;        
        var itor = materials.GetEnumerator();
        while (itor.MoveNext())
        {
            Material mat = itor.Current.Key;
            //使用Unity主摄像机位置
            if (null == view)
            {
                mat.EnableKeyword("UNITY_CAMERA");
                mat.DisableKeyword("CUSTOM_CAMERA");
            }
            //自定义观察相机位置
            else
            {
                mat.EnableKeyword("CUSTOM_CAMERA");
                mat.DisableKeyword("UNITY_CAMERA");
                mat.SetVector("_CameraPos", view.position);
            }
        }
    }

    public Dictionary<Material, Transform> materials = new Dictionary<Material, Transform>();
    /// <summary>
    /// 自定义观察相机
    /// </summary>
    public Transform view;
    /// <summary>
    /// 是否由UI摄像机渲染
    /// </summary>
    public bool UI;
}
