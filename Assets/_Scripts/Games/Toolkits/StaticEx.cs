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
}