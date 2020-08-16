using System;
using System.Collections.Generic;
using UnityEditor;

// ShaderUtil 是 UnityEditor 模式下面的
public static class ShaderUtilInterface2
{
	static string[] GetCertainMaterialTexturePaths(Material _mat)
    {
        List<string> results = new List<string>();
 
        Shader shader = _mat.shader;
        for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); ++i)
        {
            if (ShaderUtil.GetPropertyType(shader, i) == ShaderUtil.ShaderPropertyType.TexEnv)
            {
                string propertyName = ShaderUtil.GetPropertyName(shader, i);
                Texture tex = _mat.GetTexture(propertyName);
                string texPath = AssetDatabase.GetAssetPath(tex.GetInstanceID());
                results.Add(texPath);
            }
        }
 
        return results.ToArray();
	}
}