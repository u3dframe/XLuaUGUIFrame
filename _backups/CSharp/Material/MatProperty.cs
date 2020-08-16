using System;
using UnityEngine;

/// <summary>
/// 类名 : Material 属性
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-08-16 16:33
/// 功能 : 记录下属性
/// </summary>
[Serializable]
public class MatProperty {
    public string Key;
    public object Value;
    public int nType;
    public Type objType;

    public MatProperty(){}

    public MatProperty(string key,int nType,object obj){
        Init(key,nType,obj);
    }

    public MatProperty Init(string key,int nType,object obj){
        this.Key = key;
        this.nType = nType;
        this.Value = obj;
        if(this.Value != null){
            this.objType = this.Value.GetType();
        }
        return this;
    }

    public void SetMatProperty(Material material){
        if(material != null)
            material.SetProperty(this.nType,this.Key,this.Value);
    }
}
