using UnityEngine;
using System.Collections;
using System.IO;

namespace Core.Kernel
{
    using UObject = UnityEngine.Object;
    using UResources = UnityEngine.Resources;

    /// <summary>
    /// 类名 : 读取 Resources 文件夹下面的资源
    /// 作者 : Canyon / 龚阳辉
    /// 日期 : 2017-03-07 09:29
    /// 功能 : 
    /// </summary>
    public partial class Resources : ReadWriteHelper
    {
        static public readonly System.Type tpGobj = typeof(GameObject);
        static public readonly System.Type tpTex2D = typeof(Texture2D);
        static public readonly System.Type tpSprite = typeof(Sprite);
        static public readonly System.Type tpCube = typeof(Cubemap);
        static public readonly System.Type tpFont = typeof(Font);
        static public readonly System.Type tpShader = typeof(Shader);
        static public readonly System.Type tpMat = typeof(Material);
        static public readonly System.Type tpAdoClip = typeof(AudioClip);
        static public readonly System.Type tpAnmClip = typeof(AnimationClip);
        static public readonly System.Type tpSVC = typeof(ShaderVariantCollection);
        static public readonly System.Type tpTimeline = typeof(UnityEngine.Timeline.TimelineAsset);

        static public readonly string m_strFnt = ".ab_fnt";
        static public readonly string m_strShader = ".ab_shader";
        static public readonly string m_strUI = ".ui";
        static public readonly string m_strFab = ".fab";
        static public readonly string m_strAtlas = ".tex_atlas";
        static public readonly string m_strTex2D = ".tex";
        static public readonly string m_strCube = ".tex_cub";
        static public readonly string m_strSVC = ".ab_svc";
        static public readonly string m_strTLine = ".pa";
        static public readonly string m_strFbx = ".ab_fbx";
        static public readonly string m_strAdoClip = ".ado";
        static public readonly string m_strMat = ".ab_mat";

        static public readonly string m_suffix_png = ".png";
        static public readonly string m_suffix_fab = ".prefab";

        /// <summary>
        /// 路径转为以 Assets/ 开头的
        /// </summary>
        static private string _AssetsStart(string fp)
        {
            // 去掉第一个Assets文件夹路径
            int index = fp.IndexOf(m_assets);
            if (index >= 0)
            {
                fp = fp.Substring(index + m_nAssests);
            }
            fp = "Assets/" + fp;
            return fp;
        }

#if UNITY_EDITOR
        static public string Path2AssetsStart(string fp)
        {
            fp = ReplaceSeparator(fp);
            if (fp.Contains(m_appAssetPath))
            {
                fp = _AssetsStart(fp);
            }
            return fp;
        }
		
		// AssetDatabase 取得的 Path 都是 AssetPath [以 Assets/ 开头路径]
        static public string GetPath(UObject obj)
        {
            return UnityEditor.AssetDatabase.GetAssetPath(obj);
        }

        static public T GetObject<T>(string assetPath,string suffix = "") where T : UObject
        {
             // 去掉第一个Assets文件夹路径
			assetPath = _AssetsStart(assetPath);
			string suffix2 = Path.GetExtension (assetPath);
			if (string.IsNullOrEmpty (suffix2) && !string.IsNullOrEmpty (suffix)) {
				assetPath += suffix;
			}
			return UnityEditor.AssetDatabase.LoadAssetAtPath<T>(assetPath);
        }

		static public UObject GetObject(string assetPath,string suffix = "")
        {
            // 去掉第一个Assets文件夹路径
			return GetObject<UObject>(assetPath,suffix);
        }

        static public T LoadInEditor<T>(string abName,string assetName) where T : UObject{
            if (string.IsNullOrEmpty (abName))
                return null;
            string _fp = m_appAssetPath;
            if(abName.Contains("/c_")){
                _fp  += "Characters/Builds/";
            }else if(abName.Contains("timeline/")){
                _fp  += "Characters/Builds/";
            }else if(abName.Contains("/maps/")){
                _fp  += "Scene/Builds/";
            }else if(abName.Contains("/effects/") || abName.Contains("/ef_")){
                _fp  += "Effects/Builds/";
            }else{
                _fp += "Builds/";
            }
            bool _isFab = abName.EndsWith(m_strUI) || abName.EndsWith(m_strFab);
            _fp += GetPathNoSuffix(abName);
            if(_isFab){
                return Load4Develop<T>(_fp,m_suffix_fab);
            }else if(abName.EndsWith(m_strAtlas)){
                _fp += GetPathNoSuffix(assetName);
                return Load4Develop<T>(_fp,m_suffix_png);
            }else if(abName.EndsWith(m_strTex2D)){
                return Load4Develop<T>(_fp,m_suffix_png);
            }
            return null;
        }
#endif

        static public T Load4Develop<T>(string path, string suffix) where T : UObject
        {
            T _ret_ = null;
            path = ReplaceSeparator(path);
#if UNITY_EDITOR
			int index = path.LastIndexOf (m_fnResources);
			if(index < 0){
				_ret_ = GetObject<T>(path,suffix);
			}
#endif

            if (_ret_ == null)
            {
                _ret_ = LoadInResources<T>(path);
            }
            return _ret_;
        }

        static public T LoadInResources<T>(string path) where T : UObject
        {
            // 去掉最后一个Resources文件夹路径
            int index = path.LastIndexOf(m_fnResources);
            if (index >= 0)
            {
                path = path.Substring(index + m_nResources);
            }

            // 去掉后缀名
            string suffix = Path.GetExtension(path);
            if (!string.IsNullOrEmpty(suffix))
            {
                path = path.Replace(suffix, "");
            }

            return UResources.Load(path,typeof(T)) as T;
        }

        /// <summary>
        /// Load the specified path.
        /// </summary>
        /// <param name="path">相对路径(有无后缀都可以处理)</param>
        static public UObject Load4Develop(string path, string suffix)
        {
            UObject ret = null;
            path = ReplaceSeparator(path);
#if UNITY_EDITOR
			int index = path.LastIndexOf (m_fnResources);
			if(index < 0){
				ret = GetObject(path,suffix);
			}
#endif

            if (ret == null)
            {
                ret = LoadInResources(path);
            }
            return ret;
        }

        static public UObject Load4Develop(string path)
        {
            return Load4Develop(path, null);
        }

        /// <summary>
        /// Loads the in resources.
        /// </summary>
        /// <returns>The in resources.</returns>
        /// <param name="path">路径</param>
        static public UObject LoadInResources(string path)
        {
            // 去掉最后一个Resources文件夹路径
            int index = path.LastIndexOf(m_fnResources);
            if (index >= 0)
            {
                path = path.Substring(index + m_nResources);
            }

            // 去掉后缀名
            string suffix = Path.GetExtension(path);
            if (!string.IsNullOrEmpty(suffix))
            {
                path = path.Replace(suffix, "");
            }

            return UResources.Load(path);
        }

        static public void UnLoadOne(UObject obj)
		{
			if(obj == null || !obj)
				return;
			
			if(obj.GetType() == tpGobj)
			{
				GameObject.DestroyImmediate(obj,true);
			}
			else
			{
				UResources.UnloadAsset(obj);
			}
		}

        static public bool IsShaderAB(string abName){
            if(string.IsNullOrEmpty(abName))
                return false;
            return abName.EndsWith(m_strShader);
        }

        static public bool IsMatAB(string abName){
            if(string.IsNullOrEmpty(abName))
                return false;
            return abName.EndsWith(m_strMat);
        }

        static public bool IsTex2dAB(string abName){
            if(string.IsNullOrEmpty(abName))
                return false;
            return abName.EndsWith(m_strTex2D) || abName.EndsWith(m_strCube);
        }
    }
}