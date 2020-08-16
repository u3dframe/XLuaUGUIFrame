using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections;

// ShaderUtil 是 UnityEditor模式下面的，怕使用了会出问题
public static class ShaderUtilInterface
{
    public static Dictionary<string, MethodInfo> methods = new Dictionary<string, MethodInfo>();
 
    static ShaderUtilInterface()
    {
        var asm = AppDomain.CurrentDomain.GetAssemblies().FirstOrDefault(a=>a.GetTypes().Any(t=>t.Name == "ShaderUtil"));
        if(asm != null)
        {
            var tp = asm.GetTypes().FirstOrDefault(t=>t.Name == "ShaderUtil");
            foreach(var method in tp.GetMethods(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static))
            {
                methods[method.Name] = method;
            }
        }
    }

    public static Dictionary<int,Texture> GetTextureDic(this Material mat)
    {
        var ret = new Dictionary<int,Texture>();
        var count = mat.GetPropertyCount();
        for(var i = 0; i < count; i++)
        {
            if(mat.GetPropertyType(i)==4)
            {
                ret.Add(i,(Texture)mat.GetProperty(i));
            }
        }
        return ret;
    }
 
    public static List<Texture> GetTextures(this Material mat)
    {
        var list = new List<Texture>();
        var count = mat.GetPropertyCount();
        for(var i = 0; i < count; i++)
        {
            if(mat.GetPropertyType(i)==4)
            {
                list.Add((Texture)mat.GetProperty(i));
            }
        }
        return list;
    }
 
    public static int GetPropertyCount(this Material mat)
    {
        return Call<int>("GetPropertyCount", mat.shader);
    }
 
    public static int GetPropertyType(this Material mat, int index)
    {
        return Call<int>("GetPropertyType", mat.shader, index);
    }
 
    public static string GetPropertyName(this Material mat, int index)
    {
        return Call<string>("GetPropertyName", mat.shader, index);
    }
 
    public static void SetProperty(this Material material, int index, object value)
    {
        var name = material.GetPropertyName(index);
        var type = material.GetPropertyType(index);
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
        case 3:
            material.SetFloat(name, (float)value);
            break;
        case 4:
            material.SetTexture(name, (Texture) value);
            break;
        }
    }
    
    public static object GetProperty(this Material material, int index)
    {
        var name = material.GetPropertyName(index);
        var type = material.GetPropertyType(index);
        switch(type)
        {
        case 0:
            return material.GetColor(name);
 
        case 1:
            return material.GetVector(name);
        case 2:
        case 3:
            return material.GetFloat(name);
        case 4:
            return material.GetTexture(name);
        }
        return null;
    }
 
    public static T Call<T>(string name, params object[] parameters)
    {
        return (T)methods[name].Invoke(null, parameters);
    }
 
}