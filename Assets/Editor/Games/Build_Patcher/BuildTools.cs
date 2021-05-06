﻿using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using Core.Kernel;
using System;


/// <summary>
/// 类名 : 资源导出工具脚本 
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-07 09:29
/// 功能 : 将protobuf 文件转为 lua 文件
/// 修改 : 2020-03-26 09:29
/// </summary>
public class BuildTools : BuildPatcher
{
    static string[] GenBuildScene()
    {
        string[] buildList = {
            "Assets/_Develop/Scene/Launcher.unity",
            "Assets/_Develop/Scene/Loading01.unity",
            "Assets/_Develop/Scene/Loading02.unity"
        };

        var settings = new List<EditorBuildSettingsScene>();
        var paths = new List<string>();
        foreach (EditorBuildSettingsScene setting in EditorBuildSettings.scenes)
        {
            bool enable = false;
            foreach (string name in buildList)
            {
                if (setting.path == name)
                {
                    paths.Add(name);
                    enable = true;
                }
            }
            setting.enabled = enable;
            settings.Add(setting);
        }
        EditorBuildSettings.scenes = settings.ToArray();
        return paths.ToArray();
    }

    static void InnerBuildAll(string []scenes, string outpath, BuildTargetGroup targetgroup, BuildTarget target, BuildOptions option)
    {
        EditorUtility.DisplayProgressBar("BuidPlayer", "Switch Targe Group", 0.1f);
        EditorUserBuildSettings.SwitchActiveBuildTargetAsync(targetgroup, target);
        option |= BuildOptions.CompressWithLz4;
        AssetDatabase.Refresh();

        FileUtil.DeleteFileOrDirectory(m_dirStreaming);
        AssetDatabase.Refresh();
        
        EditorUtility.DisplayProgressBar("BuidPlayer", "Compress Resource", 0.4f);
        Zip_Main();
        AssetDatabase.Refresh();

        EditorUtility.DisplayProgressBar("BuidPlayer", "Build Runtime", 0.5f);
        UnityEditor.Build.Reporting.BuildReport ret = BuildPipeline.BuildPlayer(scenes, outpath, target, option);

        EditorUtility.DisplayProgressBar("BuidPlayer", "Clean tmp files", 0.9f);
        AssetDatabase.Refresh();
        EditorUtility.ClearProgressBar();

        if (ret.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded)
        {
            var sb = new System.Text.StringBuilder();
            sb.Append("Build Failure:\n");
            foreach (UnityEditor.Build.Reporting.BuildStep step in ret.steps)
            {
                foreach (UnityEditor.Build.Reporting.BuildStepMessage msg in step.messages)
                {
                    sb.Append(step.name + ":" + msg.content + "\n");
                }
            }
            throw new Exception(sb.ToString());
        }
        else
        {
            Debug.Log("Build " + outpath);
        }
    }

    static string getOption( Dictionary<string,string> args, string key, string def){
        string o;
        return args.TryGetValue(key, out o) ? o : def; 
    }

    [MenuItem("Tools/CMD BuildAndroid")]
    static public void BuildAndroid()
    {
        Core.GameFile.CurrDirRes();
        string CommandLine = Environment.CommandLine;
        string[] CommandLineArgs = Environment.GetCommandLineArgs();
        var args = new Dictionary<string,string>();
        foreach(var c in CommandLineArgs) {
            string[] vals=c.Split(new char[]{'='}, StringSplitOptions.RemoveEmptyEntries);
            if(vals.Length==1) {
                args.Add(vals[0].Trim(), "true");
            }else{
                args.Add(vals[0].Trim(), vals[1].Trim());
            }
        }
        string choiceSvlist = getOption(args, "choiceSvlist","");
        CopySVList(choiceSvlist);
        
        AssetDatabase.Refresh();
        string directory = getOption(args, "targetDir", Path.Combine(Application.dataPath.Replace("/Assets", ""),"../build/"));
        directory = Path.Combine(directory, "android/");
        Directory.CreateDirectory(directory);
        //PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.IL2CPP);
        //PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.Mono2x);
        bool strip = getOption(args, "stripEngineCode", "false") == "true";
        PlayerSettings.stripEngineCode = strip;
        PlayerSettings.companyName = getOption(args, "companyName", "com.dianyuegame");
        PlayerSettings.productName = getOption(args, "productName", "kesulu");
        string ident = PlayerSettings.companyName + "." + PlayerSettings.productName;
        string bundleVersion = getOption(args, "bundleVersion", "1.0");
        string bundleVersionCode = getOption(args, "bundleVersionCode",null);
        LandscapePlatformSetting(BuildTarget.Android,ident,ref bundleVersion,ref bundleVersionCode);

        string pName = $"{getOption(args, "targetName", "kesulu")}_{System.DateTime.Now.ToString("MMdd_HHmm")}_ver{bundleVersion}_code{bundleVersionCode}";
        string targetDir = Path.Combine(directory, pName + ".apk");
        FileUtil.DeleteFileOrDirectory(targetDir);

        BuildOptions option = BuildOptions.None;
        bool development = getOption(args, "development", "false") == "true";
        EditorUserBuildSettings.development = development;
        if(development) {
            option |= BuildOptions.Development;
            option |= BuildOptions.ConnectWithProfiler;
            option |= BuildOptions.EnableDeepProfilingSupport;
            option |= BuildOptions.AllowDebugging;
        }
        string[] scenes = GenBuildScene();

        InnerBuildAll(scenes, targetDir, BuildTargetGroup.Android, BuildTarget.Android, option);
    }

    static public void CMD_ClearWrap(){
        CMD_ClearCSWrap();
        CMD_GenCSWrap();
    }

    static public void CMD_ClearCSWrap(){
        CSObjectWrapEditor.Generator.ClearAll();
        AssetDatabase.Refresh();
    }

    static public void CMD_GenCSWrap(){
        CSObjectWrapEditor.Generator.GenAll();
        AssetDatabase.Refresh();
    }

    static public void CMD_BuildResource(){ // async
        BuildAllResource();
    }

    static public void SaveDefaultCfgVersion(){
        CfgVersion.instance.LoadDefault4EDT();
        CfgVersion.instance.SaveDefault();
    }

    static public void Zip_Main(){
        SaveDefaultCfgVersion();
        // Net_2_Out();
        ZipMain();
    }

    static public void CopySVList(string suff = ""){
        string _fname = "severlist";
        if((!string.IsNullOrEmpty(suff)) && (!"default".Equals(suff) && !"def".Equals(suff)))
            _fname = string.Concat(_fname,suff);
        string _fp = string.Format("{0}/../_svlists/{1}.lua", Application.dataPath,_fname);
        string _fpDest = string.Format("{0}/Lua/games/net/severlist.lua", Application.dataPath);
        FileInfo fInfo = new FileInfo(_fp);
        fInfo.CopyTo(_fpDest, true);
    }

    // change net 2 out(切为外网)
    // change net 2 in(切为内网)
    [MenuItem("Tools/切为内网",false,50)]
    static void Net2In(){
        CopySVList("");
    }

    [MenuItem("Tools/切为外网(152.136.147.141)",false,50)]
    static void Net2Out152_141(){
        CopySVList("_sdk173");
    }
}