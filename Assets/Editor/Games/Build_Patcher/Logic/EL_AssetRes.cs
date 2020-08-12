using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using Core.Kernel;

/// <summary>
/// 类名 : 编译 资源
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-07 09:29
/// 功能 : abname = 资源文件路径截取了相对文件夹[m_rootRelative]后,并去掉了后缀名的部分 (小写)
///        abExtension  = 资源文件后缀名(小写)
/// modify 2020-03-26 09:29
/// </summary>
public class EL_AssetRes
{
    //序列化对象
    SerializedObject m_Object;
    //序列化属性
    SerializedProperty m_Property;
    List<UnityEngine.Object> m_list = null;
    bool m_isIntroduce = true;
    GUIStyle style = new GUIStyle();
    GUIStyle styleRed = new GUIStyle();
    bool _isInited = false;

    Vector2 _v2Srl;
    int _nLensList = 0;
    float _calcListY = 0;
    private void Init()
    {
        if (_isInited)
            return;
        _isInited = true;
        style.normal.textColor = Color.yellow;
        styleRed.normal.textColor = Color.red;
    }

    public float DrawView(SerializedObject obj, SerializedProperty field, List<UnityEngine.Object> list)
    {
        Init();

        this.m_Object = obj;
        this.m_Property = field;
        this.m_list = list;
        float _ret = EG_Helper.h30;

        if (m_Object == null)
        {
            return _ret;
        }

        m_Object.Update();

        EG_Helper.FEG_BeginVArea();

        EG_Helper.FEG_HeadTitMid("Build Resources", Color.magenta);

        BuildTools.m_buildTarget = (BuildTarget)EditorGUILayout.EnumPopup("平台 : ", BuildTools.m_buildTarget);
        EG_Helper.FG_Space(10);

        EG_Helper.FEG_BeginH();
        {
            BuildTools.m_rootRelative = EditorGUILayout.TextField("相对目录 : ", BuildTools.m_rootRelative);
            EditorGUILayout.LabelField("(资源文件夹节点里必须有个[相对目录]，不然不会Build！！！)", styleRed);
        }
        EG_Helper.FEG_EndH();

        EG_Helper.FEG_ToggleRed("是否显示打包资源的详细介绍", ref m_isIntroduce);
        if (m_isIntroduce)
        {
            EG_Helper.FEG_BeginVArea();
            {
                string _v = "需要打包的资源文件，需要满足以下几个条件，不然不会Build！！！";
                EditorGUILayout.LabelField(_v);
                EG_Helper.FG_Space(10);
                _v = string.Format("1.必须在[{0}/...(省略)/{1}]目录下面\n", BuildTools.m_edtAssetPath, BuildTools.m_rootRelative);
                EditorGUILayout.LabelField(_v, styleRed);
            }
            EG_Helper.FEG_EndV();
        }

        _nLensList = list.Count;
        _calcListY = ((_nLensList > 20 ? 20 : _nLensList) + 1) * EG_Helper.h18 + EG_Helper.h30 * 1f;
        EG_Helper.FEG_BeginScroll(ref _v2Srl, _calcListY);
        {
            //开始检查是否有修改
            EditorGUI.BeginChangeCheck();

            //显示属性
            //第二个参数必须为true，否则无法显示子节点即List内容
            EditorGUILayout.PropertyField(m_Property, new GUIContent("资源文件夹 : "), true);

            //结束检查是否有修改
            if (EditorGUI.EndChangeCheck())
            {
                //提交修改
                m_Object.ApplyModifiedProperties();
            }
        }
        EG_Helper.FEG_EndScroll();

        EG_Helper.FEG_BeginVArea();
        {
            EG_Helper.FEG_Head("清除，删除等按钮集合");
            EG_Helper.FEG_BeginH();
            {
                if (GUILayout.Button("删除 - 所有ab资源文件夹"))
                {
                    BuildTools.DelABFolders(true);
                }
                if (GUILayout.Button("清除 - 所有ab资源名"))
                {
                    _ClearABName(true);
                }
                if (GUILayout.Button("清除 - 资源文件夹"))
                {
                    _ClearDirs(true);
                }
            }
            EG_Helper.FEG_EndH();
        }
        EG_Helper.FEG_EndV();

        EG_Helper.FEG_BeginVArea();
        {
            EG_Helper.FEG_Head("打包操作按钮");
            EG_Helper.FEG_BeginH();
            {
                if (GUILayout.Button("Re-LoadFolders"))
                {
                    _ReLoadFolders(true);
                }
                if (GUILayout.Button("Re-AB"))
                {
                    _ReAB();
                }
                if (GUILayout.Button("BuildFolders"))
                {
                    _DoMake();
                }
                if (GUILayout.Button("Re-BuildAll"))
                {
                    _ReBuildAll();
                }
            }
            EG_Helper.FEG_EndH();
        }
        EG_Helper.FEG_EndV();

        EG_Helper.FEG_EndV();
        _ret = EG_Helper.h30 * 8f + _calcListY + 10;
        return m_isIntroduce ? _ret + 60 : _ret;
    }

     void _ClearABName(bool isTip = false)
    {
        BuildTools.ClearAllABNames();
        if (isTip)
            EditorUtility.DisplayDialog("提示", "资源名清除完成!", "确定");
    }

    void _ClearDirs(bool isTip = false)
    {
        this.m_list.Clear();
        if (isTip)
            EditorUtility.DisplayDialog("提示", "已清除选定文件夹!", "确定");
    }

    void _ReLoadFolders(bool isTip = false)
    {
        _ClearDirs();
        string[] _dirs = BuildTools.GetFns4Folders(BuildTools.m_appAssetPath);
        if (_dirs == null)
        {
            if (isTip)
                EditorUtility.DisplayDialog("提示", "没有可进行Load的文件夹!", "确定");
            return;
        }
        EditorUtility.DisplayProgressBar("ReLoad", "Reload folders for develops ...", 0.0f);
        UnityEngine.Object _one = null;
        int curr = 0;
        float count = _dirs.Length;
        foreach (var item in _dirs)
        {
            _one = BuildTools.Load4Develop(item);
            if (_one != null)
            {
                this.m_list.Add(_one);
            }
            curr++;
            EditorUtility.DisplayProgressBar(string.Format("ReLoad - ({0}/{1})", curr, count), item, (curr / count));
        }
        EditorUtility.ClearProgressBar();
        if (isTip)
            EditorUtility.DisplayDialog("提示", "已重新加载文件夹!", "确定");
    }

    void _ReAB()
    {
        BuildTools.DoBuild();
    }

    void _DoMake()
    {
        // BuildAssetBundleOptions.None = 使用LZMA算法压缩，压缩的包更小，但是加载时间更长，需要解压全部。
        // BuildAssetBundleOptions.ChunkBasedCompression = 使用LZ4压缩，压缩率没有LZMA高，但是我们可以加载指定资源而不用解压全部。
        // BuildPipeline.BuildAssetBundles (outputPath, BuildAssetBundleOptions.ChunkBasedCompression, m_buildTarget);
        int lens = m_Property.arraySize;
        if (lens <= 0)
        {
            EditorUtility.DisplayDialog("Tips", "请选择来源文件夹!!!", "Okey");
            return;
        }
        
        EditorUtility.DisplayProgressBar("DoMake", "Ready Analyse ...", 0.0f);
        for (int i = 0; i < lens; i++)
        {
            _AnalyseFolder(m_list[i]);
        }
        EditorUtility.ClearProgressBar();
        BuildTools.BuildNow();
    }

    void _AnalyseFolder(UnityEngine.Object one)
    {
        if (one == null)
            return;

        System.Type typeFolder = typeof(UnityEditor.DefaultAsset);
        System.Type typeOrg = one.GetType();
        if (typeOrg != typeFolder)
        {
            EditorUtility.DisplayDialog("Tips", string.Format("来源文件不是文件夹!!!,name=[{0}]", BuildTools.GetPath(one)), "Okey");
            return;
        }
        BuildTools.AnalyseDir4Deps(one);
    }

    void _ReBuildAll()
    {
        _ClearABName();
        _ReLoadFolders();
        m_Object.Update();
        _DoMake();
    }
}