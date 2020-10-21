using UnityEditor;
using UnityEngine;

/// <summary>
/// 类名 : 脚本编译完成
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-10-14 14:56
/// 功能 : 
/// </summary>
[InitializeOnLoad]
public class USCompiling : AssetPostprocessor
{
    [UnityEditor.Callbacks.DidReloadScripts]
    static void AllScriptsReloaded()
    {
        // BuildTools.Call_BuildApk(); 成功，但是编译还是会有错误
    }
}
