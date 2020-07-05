using UnityEngine;
using System.Collections;
using System.IO;
using XLua;
using Core;

/// <summary>
/// 重写里面的ReadFile，
/// </summary>
public class LuaFileLoader { 
    public byte[] ReadFile(ref string fileName) {
        string fn = fileName.Replace('.', '/');
        if(fn.IndexOf("Lua/") == -1){
            fn = "Lua/" + fn;
        }
        if(fn.LastIndexOf(".lua") == -1){
            fn += ".lua";
        }
#if UNITY_EDITOR
        fileName = string.Format("{0}{1}",GameFile.m_dirData,fn);
        return GameFile.GetBytes4File(fileName);
#else
        fileName = GameFile.GetPath(fn);
        return GameFile.GetFileBytes(fn);;
#endif
    }

    public static implicit operator LuaEnv.CustomLoader(LuaFileLoader luaLoader)
    {
        return luaLoader.ReadFile;
    }
}