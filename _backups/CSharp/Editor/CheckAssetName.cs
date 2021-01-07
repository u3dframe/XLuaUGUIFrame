using UnityEditor;
using UnityEngine;
 
 /// <summary>
/// 类名 : 导入所有资源的逻辑
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-04-10 11:53
/// 功能 : 
/// </summary>
public class ImportAllAssets : AssetPostprocessor
{
    static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
    {
        int nLens = 0;
        if(movedAssets != null) nLens = movedAssets.Length;
        if(nLens > 0) {
            bool isChg = false;
            foreach (string str in movedAssets) {
                if (str.Contains("textures/")) {
                    TextureImporter _tImpt = TextureImporter.GetAtPath(str) as TextureImporter;
                    if(_tImpt != null){
                        ImportTexture.ReTextureInfo(_tImpt,true);
                        _tImpt.SaveAndReimport();
                        isChg = true;
                    }
                }
            }
            
            if(isChg)
                AssetDatabase.SaveAssets();
        } 
    }
}