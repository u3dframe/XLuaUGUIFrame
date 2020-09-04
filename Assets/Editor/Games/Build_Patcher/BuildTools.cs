using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using Core;
using Core.Kernel;

/// <summary>
/// 类名 : 资源导出工具脚本 
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-07 09:29
/// 功能 : 将protobuf 文件转为 lua 文件
/// 修改 : 2020-03-26 09:29
/// </summary>
public class BuildTools : Core.EditorGameFile
{
    const string _fnSharder = "shaders.ab_shader";

    public static void ClearBuild()
    {
        MgrABDataDependence.ClearDeps();
    }

    // 分析文件夹 - 得到所有文件的依赖关系
    public static void AnalyseDir4Deps(Object obj)
    {
        if (obj == null)
            return;

        string strObjPath = GetPath(obj);
#if Shader2OneAB
		if (IsShader(strObjPath)) {
			SetABInfo(strObjPath,_fnSharder);
			return;
		}
#endif
        EL_Path.Init(strObjPath);
        float count = EL_Path.files.Count;
        int curr = 0;
        string _tmp = "";
        EditorUtility.DisplayProgressBar("Analysis Dependence Init", strObjPath, 0.00f);

        foreach (var item in EL_Path.files)
        {
            _tmp = Path2AssetsStart(item);
            AnalyseFile4Deps(Load4Develop(_tmp));
            curr++;
            EditorUtility.DisplayProgressBar(string.Format("{0} - ({1}/{2})", strObjPath, curr, count), _tmp, (curr / count));
        }
        EditorUtility.ClearProgressBar();
    }

    // 分析文件的依赖关系
    public static void AnalyseFile4Deps(Object obj)
    {
        string strObjPath = GetPath(obj);
        bool isMust = false;
        if (!IsInBuild(strObjPath, ref isMust))
            return;

        MgrABDataDependence.Init(obj, isMust);
    }

    static public void ClearObjABName(string abname)
    {
        string[] _arrs = AssetDatabase.GetAssetPathsFromAssetBundle(abname);
        if(_arrs == null || _arrs.Length <= 0)
            return;
        
        foreach (string assetPath in _arrs){
            SetABInfo(assetPath);
        }
    }

    static int _CheckABName()
    {
        EditorUtility.DisplayProgressBar("DoBuild", "CheckABName ...", 0.0f);
        AssetDatabase.RemoveUnusedAssetBundleNames();
        string[] strABNames = AssetDatabase.GetAllAssetBundleNames();
        float count = strABNames.Length;
        int curr = 0;
        foreach (string abName in strABNames)
        {
            curr++;
            EditorUtility.DisplayProgressBar(string.Format("CheckABName - ({0}/{1})", curr, count), abName, (curr / count));
            if (abName.EndsWith("error"))
            {
                ClearObjABName(abName);
                AssetDatabase.RemoveAssetBundleName(abName, true);
                Debug.LogFormat("=Error ABName = [{0}]", abName);
            }
        }
        AssetDatabase.RemoveUnusedAssetBundleNames();
        EditorUtility.DisplayProgressBar("DoBuild", "RemoveUnusedAssetBundleNames ...", 0.1f);
        strABNames = AssetDatabase.GetAllAssetBundleNames();
        return strABNames.Length;
    }

    static public void ClearAllABNames(bool isClearBuild = true)
    {
        EditorUtility.DisplayProgressBar("Clear", "ClearABName ...", 0.0f);
        AssetDatabase.RemoveUnusedAssetBundleNames();
        string[] arrs = AssetDatabase.GetAllAssetBundleNames();
        float count = arrs.Length;
        int curr = 0;
        foreach (string abName in arrs)
        {
            ClearObjABName(abName);
            AssetDatabase.RemoveAssetBundleName(abName, true);
            curr++;
            EditorUtility.DisplayProgressBar(string.Format("ClearABName - ({0}/{1})", curr, count), abName, (curr / count));
        }
        AssetDatabase.RemoveUnusedAssetBundleNames();
        AssetDatabase.Refresh();
        EditorUtility.ClearProgressBar();

        if(isClearBuild){
            DelABFolders();
            ClearBuild();
        }
    }

    static void _ReBindABName(string objAssetPath)
    {
        Object obj = Load4Develop(objAssetPath);
        if (obj == null)
            return;
        _ReBindABName(obj);
    }

    static void _HandlerEmpty(Object obj)
    {
        if (obj is GameObject)
        {
            GameObject gobj = obj as GameObject;
            if (gobj.name.StartsWith("tl_") != true)//Timeline预制资源都不移除Animator
            {
                Animator[] arrsAnit = gobj.GetComponentsInChildren<Animator>(true);
                foreach (var item in arrsAnit)
                {
                    if (item != null && item.runtimeAnimatorController == null)
                    {
                        GameObject.DestroyImmediate(item, true);
                    }
                }
            }
            
            Animation[] arrsAnim = gobj.GetComponentsInChildren<Animation>(true);
            foreach (var item in arrsAnim)
            {
                if (item != null && item.GetClipCount() <= 0)
                {
                    GameObject.DestroyImmediate(item, true);
                }
            }
            CleanupMissingScripts(gobj);

            // 加上这句，才会保存修改后的prefab
            if(IsPrefabInstance(gobj,false)){
                PrefabUtility.SavePrefabAsset(gobj);
            }
        }
    }

    /// <summary>
    /// 判断Object是否是预制体资源。
    /// </summary>
    /// <param name="includePrefabInstance">是否将预制体资源的Scene实例视为预制体资源？</param>
    /// <returns>如果是则返回 `true` ，如果不是则返回 `false` 。</returns>
    static public bool IsPrefabAsset(UnityEngine.Object obj, bool includePrefabInstance)
    {
        if (!obj)
        {
            return false;
        }

        var type = PrefabUtility.GetPrefabAssetType(obj);
        if (type == PrefabAssetType.NotAPrefab)
        {
            return false;
        }

        var status = PrefabUtility.GetPrefabInstanceStatus(obj);
        if (status != PrefabInstanceStatus.NotAPrefab && !includePrefabInstance)
        {
            return false;
        }

        return true;
    }

    /// <summary>
    /// 判断GameObject是否是预制体资源的实例。
    /// </summary>
    /// <param name="includeMissingAsset">是否将丢失预制体关联的GameObject视为预制体实例？</param>
    /// <returns>如果是则返回 `true` ，如果不是则返回 `false` 。</returns>
    static public bool IsPrefabInstance(UnityEngine.GameObject gobj, bool includeMissingAsset)
    {
        if (!gobj)
        {
            return false;
        }

        var type = PrefabUtility.GetPrefabAssetType(gobj);
        if (type == PrefabAssetType.NotAPrefab || (!includeMissingAsset && type == PrefabAssetType.MissingAsset))
        {
            return false;
        }

        var status = PrefabUtility.GetPrefabInstanceStatus(gobj);
        if (status == PrefabInstanceStatus.NotAPrefab)
        {
            return false;
        }
        return true;
    }

    [MenuItem("Tools/Cleanup Missing Scripts")]
    [MenuItem("Assets/Tools/Cleanup Missing Scripts")]
    static void CleanupMissingScripts()
    {
        for (int i = 0; i < Selection.gameObjects.Length; i++)
        {
            CleanupMissingScripts(Selection.gameObjects[i]);
        }
    }

    static void CleanupMissingScripts(GameObject gObj)
    {
        // We must use the GetComponents array to actually detect missing components
        var components = gObj.GetComponents<Component>();

        // Create a serialized object so that we can edit the component list
        var serializedObject = new SerializedObject(gObj);
        // Find the component list property
        var prop = serializedObject.FindProperty("m_Component");

        // Track how many components we've removed
        int r = 0;
        // Iterate over all components
        for (int j = 0; j < components.Length; j++)
        {
            // Check if the ref is null
            if (components[j] == null)
            {
                // If so, remove from the serialized component array
                prop.DeleteArrayElementAtIndex(j - r);
                // Increment removed count
                r++;
            }
        }

        // Apply our changes to the game object
        serializedObject.ApplyModifiedProperties();
        //这一行一定要加！！！
        EditorUtility.SetDirty(gObj);
    }

    static void _ReBindABName(Object obj)
    {
        _HandlerEmpty(obj);
        string _abSuffix = null;
        string _abName = GetAbName(obj, ref _abSuffix);
        bool _isError = _abName.EndsWith("error");
        if (_isError)
        {
            _abName = null;
            _abSuffix = null;
            SetABInfo(obj);
        }
        else
        {
            SetABInfo(obj, _abName, _abSuffix);
        }

        var _abEn = MgrABDataDependence.GetData(obj);
        _abEn.ReAB(_abName, _abSuffix);
    }

    public static void BuildNow(bool isBuildAB = true)
    {
        // EditorUtility.DisplayProgressBar("BuildNow", "XLua/Clear Code ...", 0.01f);
        // CSObjectWrapEditor.Generator.ClearAll();

        // EditorUtility.DisplayProgressBar("BuildNow", "XLua/Generate Code ...", 0.02f);
        // CSObjectWrapEditor.Generator.GenAll();

        EditorUtility.DisplayProgressBar("BuildNow", "Start BuildNow ...", 0.05f);
        float count = MgrABDataDependence.instance.m_dic.Count;
        int curr = 0;
        foreach (var item in MgrABDataDependence.instance.m_dic.Values)
        {
            curr++;
            if (item.GetBeUsedCount() > 1)
            {
                EditorUtility.DisplayProgressBar(string.Format("ReBindABName m_dic - ({0}/{1})", curr, count), item.m_res, (curr / count));
                _ReBindABName(item.m_res);
            }
        }

        AssetDatabase.RemoveUnusedAssetBundleNames();

        if (isBuildAB)
            DoBuild();

        AssetDatabase.Refresh();
        EditorUtility.ClearProgressBar();
        if (!isBuildAB)
            EditorUtility.DisplayDialog("提示", "资源重新绑定abname完成!!!", "确定");
    }

    [MenuItem("Tools/Re - AB")]
    static public void DoBuild()
    {
        DoBuild(true);
    }
    
    static public void DoBuild(bool isCheckABSpace)
    {
        if(isCheckABSpace && IsHasSpace()){
            EditorUtility.ClearProgressBar();
            EditorUtility.DisplayDialog("提示", "[原始资源]名有空格，请查看输出打印!!!", "确定");
            return;
        }

        EditorUtility.DisplayProgressBar("DoBuild", "Start DoBuild ...", 0.0f);
        int _lensAb = _CheckABName();
        bool _isMakeAB = (_lensAb > 0);
        EditorUtility.DisplayProgressBar("DoBuild", "BuildAssetBundles ...", 0.2f);
        // BuildAssetBundleOptions.None : 使用LZMA算法压缩，压缩的包更小，但是加载时间更长，需要解压全部。
        // BuildAssetBundleOptions.ChunkBasedCompression : 使用LZ4压缩，压缩率没有LZMA高，但是我们可以加载指定资源而不用解压全部。
        if (_isMakeAB)
        {
            CreateFolder(m_dirRes);
            BuildPipeline.BuildAssetBundles(m_dirRes, BuildAssetBundleOptions.ChunkBasedCompression, GetBuildTarget());
            EditorUtility.DisplayProgressBar("DoBuild", "ClearBuild ...", 0.3f);
            EditorUtility.ClearProgressBar();
            MgrABDataDependence.SaveDeps();
            EditorUtility.DisplayDialog("提示", "[ab资源] - 打包完成!!!", "确定");
        }
        else
        {
            EditorUtility.ClearProgressBar();
            EditorUtility.DisplayDialog("提示", "没有[原始资源]设置了AssetBundleName , 即资源的abname都为None!!!", "确定");
        }
    }

    static public BuildTarget m_buildTarget = BuildTarget.NoTarget;
    static BuildTarget GetBuildTarget()
    {
        if (m_buildTarget == BuildTarget.NoTarget)
        {
            switch (EditorUserBuildSettings.activeBuildTarget)
            {
                case BuildTarget.iOS:
                    return BuildTarget.iOS;
                default:
                    return BuildTarget.Android;
            }
        }
        return m_buildTarget;
    }

    [MenuItem("Assets/Tools/导出 - 选中的Object")]
    static void BuildSelectPrefab()
    {
        Object[] _arrs = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        for (int i = 0; i < _arrs.Length; ++i)
        {
            AnalyseFile4Deps(_arrs[i]);
        }
        BuildNow(true);
    }

    [MenuItem("Assets/Tools/清除 - 选中的AssetBundleName")]
    static void ClearABName4Select()
    {
        Object[] _arrs = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);
        for (int i = 0; i < _arrs.Length; ++i)
        {
            SetABInfo(_arrs[i]);
        }
        EditorUtility.DisplayDialog("提示", "已清除选中的所有文件(files)及文件夹(folders)的abname!!!", "确定");
    }

    [MenuItem("Tools/Delete ABFolders")]
    static void _DelABFolders()
    {
        DelABFolders(true);
    }
    static bool _IsContains(string[] src, string cur)
    {
        foreach (var item in src)
        {
            if (cur.Contains(item))
                return true;
        }
        return false;
    }

    static public void DelABFolders(bool isTip = false)
    {
        EditorUtility.DisplayProgressBar("DeleteABFolders", " rm folder where is ab_resources inside ...", 0.0f);
        EL_Path _ep = EL_Path.builder.DoInit(m_dirRes);

        // "audios/","fnts/","materials/","prefabs/","shaders/","textures/","ui/"        
        string[] arrs = new string[]{
            "configs/","protos/",
        };

        int curr = 0;
        float count = _ep.m_folders.Count;
        string _fd = null;
        foreach (string _fn in _ep.m_folders)
        {
            curr++;
            _fd = ReFnPath(_fn);
            EditorUtility.DisplayProgressBar(string.Format("DeleteABFolders rm file - ({0}/{1})", curr, count), _fd, (curr / count));
            if (_fd.EndsWith(m_assetRelativePath) || _IsContains(arrs, _fd))
                continue;
            DelFolder(_fd);
        }

        EditorUtility.ClearProgressBar();
        if (isTip)
            EditorUtility.DisplayDialog("提示", "已删除指定文件夹ABFolders!", "确定");
    }

    [MenuItem("Tools/Delete Same Material")]
    static void DeleteSameMaterial()
    {
        // 这个是遍历当前场景的对象(不是全部资源对象)有思路，未实现
        Dictionary<string, string> dicMaterial = new Dictionary<string, string>();
        MeshRenderer[] _arrs = UnityEngine.Resources.FindObjectsOfTypeAll<MeshRenderer>();
        string rootPath = Directory.GetCurrentDirectory();
        int _lens = _arrs.Length,_lens2 = 0;
        for (int i = 0; i < _lens; i++)
        {
            MeshRenderer meshRender = _arrs[i];
            _lens2 = meshRender.sharedMaterials.Length;
            Material[] newMaterials = new Material[_lens2];
            for (int j = 0; j < _lens2; j++)
            {
                Material m = meshRender.sharedMaterials[j];
                string mPath = GetPath(m);
                if (!string.IsNullOrEmpty(mPath) && mPath.Contains("Assets/"))
                {
                    string fullPath = Path.Combine(rootPath, mPath);
                    Debug.Log("fullPath = " + fullPath);
                    string text = File.ReadAllText(fullPath).Replace(" m_Name: " + m.name, "");
                    string change;
                     Debug.Log("text = " + text);
                    if (!dicMaterial.TryGetValue(text, out change))
                    {
                        dicMaterial[text] = mPath;
                        change = mPath;
                    }
                    newMaterials[j] = Load4Develop(change) as Material;
                }
            }
            meshRender.sharedMaterials = newMaterials;
        }
        EditorSceneManager.MarkAllScenesDirty();
    }

    [MenuItem("Tools/Check Has Space ABName")]
    static public bool IsHasSpace(){
        AssetDatabase.RemoveUnusedAssetBundleNames();
        string[] arrs = AssetDatabase.GetAllAssetBundleNames();
        int count = arrs.Length;
        string strName = null;
        bool _isRet = false;
        for(int i = 0; i < count; i++){
            strName = arrs[i];
            if(strName.Contains(" ")){
                _isRet = true;
                Debug.LogErrorFormat("==== this has space,ab name = [{0}]",strName);
            }
        }
        return _isRet;
    }
}