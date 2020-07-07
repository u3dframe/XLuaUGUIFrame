using UnityEngine;
using System;
/// <summary>
/// 类名 : 定义 通用的 代理事件
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-06-26 08:29
/// 功能 : 
/// </summary>
namespace Core
{
    public delegate void DF_LoadedAsset(AssetBase asset);
    public delegate void DF_LoadedFab(GameObject gobj);
    public delegate void DF_LoadedTex2D(Texture2D tex);
	public delegate void DF_LoadedSprite(Sprite sprite);
    public delegate void DF_OnUpdate(float dt);
    public delegate void DF_OnSceneChange(int level);
    public delegate void DF_OnNotifyDestry(GobjLifeListener obj);
}