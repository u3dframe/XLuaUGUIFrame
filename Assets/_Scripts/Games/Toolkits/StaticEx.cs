using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using System;
using UObject = UnityEngine.Object;


/// <summary>
/// 类名 : 静态类工具
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-08-16 17:03
/// 功能 : Extension method must be defined in a non-generic static class
/// </summary>
public static class StaticEx {
	static public void SetProperty(this Material material, int type, string name, object value)
    {
        if(null == material) return;

        switch(type)
        {
        case 0:
            material.SetColor(name, (Color)value);
            break;
        case 1:
            material.SetVector(name, (Vector4) value);
            break;
        case 2:
            material.SetFloat(name, (float)value);
            break;
        case 3: // Range
            material.SetFloat(name, (float)value);
            break;
        case 4:
            material.SetTexture(name, (Texture) value);
            break;
        }
    }

    static public void SetProperty(this Material material,string name,Color value)
    {
        SetProperty(material,0,name,value);
    }

    static public void SetProperty(this Material material,string name,Vector4 value)
    {
        SetProperty(material,1,name,value);
    }

    static public void SetProperty(this Material material,string name,float value)
    {
        SetProperty(material,2,name,value);
    }

    static public void SetProperty(this Material material,string name,Texture value)
    {
        SetProperty(material,4,name,value);
    }

    static public void ReShader(this Material material)
    {
        if(null == material) return;
        
        Shader _sd = material.shader;
        if(_sd != null && !string.IsNullOrEmpty(_sd.name)){
            material.shader = Shader.Find(_sd.name);
        }
    }

    static public void ReShader(this Renderer render)
    {
        if(null == render) return;

        ReShader(render.sharedMaterial);
        if (render.sharedMaterials != null)
        {
            foreach (Material mat in render.sharedMaterials)
            {
                ReShader(mat);
            }
        }
    }

    static public void ReShader(this GameObject gobj)
    {
        if(null == gobj) return;
        Renderer[] _arrs = gobj.GetComponentsInChildren<Renderer>(true);
        if(null == _arrs) return;
        int _lens = _arrs.Length;
        for (int i = 0; i < _lens; i++)
        {
            ReShader(_arrs[i]);
        }
    }

    static public void ReUIShader(this UnityEngine.UI.Image img)
    {
        if(null == img) return;
        Material material = img.material;
        if(null == material) return;
        Shader shader = material.shader;
        if(null == shader) return;
        if ("UI/Default".Equals(shader.name,StringComparison.OrdinalIgnoreCase)) {
            material.shader = Shader.Find(shader.name);
        }
    }

    static public void ReUIShader(this GameObject gobj)
    {
        if(null == gobj) return;
        UnityEngine.UI.Image[] _arrs = gobj.GetComponentsInChildren<UnityEngine.UI.Image>(true);
        if(null == _arrs) return;
        int _lens = _arrs.Length;
        for (int i = 0; i < _lens; i++)
        {
            ReUIShader(_arrs[i]);
        }
    }
}