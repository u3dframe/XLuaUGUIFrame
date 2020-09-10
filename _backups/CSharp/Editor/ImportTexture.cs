//#define UI_SPRITE_ATLAS
using System.IO;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using System.Linq;
#if UI_SPRITE_ATLAS
using UnityEditor.U2D;
using UnityEngine.U2D;
#endif

/// <summary>
/// 类名 : 图片导入设置
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-04-10 11:06
/// 功能 : 参考 雨松MOMO https://www.xuanyusong.com/archives/4663
/// </summary>
public class ImportTexture : AssetPostprocessor
{
    static int m_nReset = 0;

    void OnPreprocessTexture()
    {
        TextureImporter importer = assetImporter as TextureImporter;
        if (importer != null)
        {
            if(!BuildTools.IsInDevelop(importer.assetPath) || !BuildTools.IsTexture(importer.assetPath))
                return;

            int width = 0, height = 0;
            if (IsFirstImport(importer, ref width, ref height) || m_nReset > 0)
            {
                m_nReset--;

#if UNITY_2019
                TextureImporterFormat curFmt;
#else
                TextureImporterFormat fmtAlpha, fmtNotAlpha, curFmt;
#endif

                TextureImporterPlatformSettings settings;
                settings = importer.GetPlatformTextureSettings("iPhone");
#if UNITY_2019
                curFmt = TextureImporterFormat.ASTC_6x6;
#else
                //2的整数次幂
                // bool isPowerOfTwo = (width == height) && (width > 0) && ((width & (width - 1)) == 0);
                bool isPowerOfTwo = IsPowerTwo(width) && IsPowerTwo(height);
                fmtAlpha = isPowerOfTwo ? TextureImporterFormat.PVRTC_RGBA4 : TextureImporterFormat.ASTC_RGBA_4x4;
                fmtNotAlpha = isPowerOfTwo ? TextureImporterFormat.PVRTC_RGB4 : TextureImporterFormat.ASTC_RGB_6x6;
                curFmt = importer.DoesSourceTextureHaveAlpha() ? fmtAlpha : fmtNotAlpha;
#endif
                settings.overridden = true;
                settings.maxTextureSize = 1024;
                settings.format = curFmt;
                importer.SetPlatformTextureSettings(settings);

                settings = importer.GetPlatformTextureSettings("Android");
#if UNITY_2019
                curFmt = TextureImporterFormat.ETC2_RGBA8;
                settings.androidETC2FallbackOverride = AndroidETC2FallbackOverride.Quality32Bit;
#else
                //被4整除
                bool divisible4 = (width % 4 == 0 && height % 4 == 0);
                fmtAlpha = divisible4 ? TextureImporterFormat.ETC2_RGBA8Crunched : TextureImporterFormat.ASTC_RGBA_4x4;
                fmtNotAlpha = divisible4 ? TextureImporterFormat.ETC_RGB4Crunched : TextureImporterFormat.ASTC_RGB_6x6;
                curFmt = importer.DoesSourceTextureHaveAlpha() ? fmtAlpha : fmtNotAlpha;
#endif
                settings.overridden = true;
                // settings.allowsAlphaSplitting = false;
                settings.maxTextureSize = 1024;
                settings.format = curFmt;
                importer.SetPlatformTextureSettings(settings);
                
                importer.sRGBTexture = true;
                // importer.mipmapEnabled = false;
                // importer.alphaIsTransparency = false;
                importer.textureCompression = TextureImporterCompression.Compressed;
                importer.crunchedCompression = true;
                importer.compressionQuality = 60;
                importer.npotScale = TextureImporterNPOTScale.None;
                // importer.wrapMode = TextureWrapMode.Clamp;
                
                ReTextureInfo(importer);
                importer.SaveAndReimport();
                // AssetDatabase.Refresh();
            }
        }
    }

    [MenuItem("Assets/Tools/重置所有图片的AB")]
    [MenuItem("Tools/重置所有图片的AB")]
    static public void ReTextureAll()
    {
        string _fd = Application.dataPath;
        string[] files = null;
        
        files = Directory.GetFiles(_fd, "*.png", SearchOption.AllDirectories);
        
        // files = Directory.GetFiles(_fd, "*.*", SearchOption.AllDirectories)
        //     .Where(s => s.ToLower().EndsWith(".png") || s.ToLower().EndsWith(".jpg")).ToArray();
        
        Object obj = null;
        string fpAsset = "";
        TextureImporter _tai;
        for (int i = 0; i < files.Length; i++)
        {
            fpAsset = files[i];
            obj = BuildTools.Load4Develop(fpAsset);
            if (obj == null)
                continue;
            fpAsset = BuildTools.GetPath(obj);
            _tai = AssetImporter.GetAtPath(fpAsset) as TextureImporter;
            ReTextureInfo(_tai,true);
        }
    }

    // 处理图片
    static public void ReTextureInfo(TextureImporter importer,bool isMust = false)
    {
        string fp = importer.assetPath;
        if(!BuildTools.IsInDevelop(fp))
            return;

        if(!BuildTools.IsTexture(fp))
            return;

        bool _isUIImag = BuildTools.IsUITexture(fp);
        bool _isSpr = importer.textureType == TextureImporterType.Sprite;
        if (_isUIImag)
        {
            if (isMust || !_isSpr)
            {
                if(!_isSpr) importer.textureType = TextureImporterType.Sprite;
                // if(importer.alphaIsTransparency) importer.alphaIsTransparency = false;
                if(importer.spritePackingTag != null) importer.spritePackingTag = null;
                BuildTools.ReBindAB4SngOrAtlas(importer);
            }
        }
        else
        {
            if (isMust || _isSpr)
            {
                if(_isSpr) importer.textureType = TextureImporterType.Default;
                // if(importer.mipmapEnabled) importer.mipmapEnabled = false;
                if(importer.spritePackingTag != null) importer.spritePackingTag = null;
                BuildTools.ReBindAB4SngOrAtlas(importer);
            }
        }
        
    }

    // 2的整数次幂
    private bool IsPowerTwo(int num)
    {
        if (num < 1) return false;
        return (num & num - 1) == 0;
    }

    //贴图不存在、meta文件不存在、图片尺寸发生修改需要重新导入
    bool IsFirstImport(TextureImporter importer, ref int width, ref int height)
    {
        string fp = assetPath;
        string _assetMt = AssetDatabase.GetTextMetaFilePathFromAssetPath(fp);
        bool hasMeta = BuildTools.IsExistsInAssets(_assetMt);
        bool _isChg = !hasMeta;
        (width, height) = GetTextureImporterSize(importer);
        string _v = importer.userData;
        string _v2 = string.Format("{0},{1}", width, height);

        if (!_isChg)
        {
            _isChg = string.IsNullOrEmpty(_v);
            if (!_isChg)
            {
                string[] _arr = BuildTools.SplitComma(_v);
                _isChg = _arr.Length < 2;
                if (!_isChg)
                {
                    int _w = 0, _h = 0;
                    int.TryParse(_arr[0], out _w);
                    int.TryParse(_arr[1], out _h);
                    _isChg = (_w != width && _h != height);

                    _arr[0] = width.ToString();
                    _arr[1] = height.ToString();
                    _v2 = string.Join(",", _arr);
                    importer.userData = _v2;
                }
            }
        }
        return _isChg;
    }

    //获取导入图片的宽高
    (int, int) GetTextureImporterSize(TextureImporter importer)
    {
        if (importer != null)
        {
            object[] args = new object[2];
            MethodInfo mi = typeof(TextureImporter).GetMethod("GetWidthAndHeight", BindingFlags.NonPublic | BindingFlags.Instance);
            mi.Invoke(importer, args);
            return ((int)args[0], (int)args[1]);
        }
        return (0, 0);
    }

    [MenuItem("Assets/Tools/Re-ImportTexture")]
    static void ReTexutes()
    {
        Object[] _arrs = Selection.GetFiltered(typeof(Texture2D), SelectionMode.DeepAssets);
        Object _one = null;
        string _assetPath = null;
        m_nReset = _arrs.Length;
        for (int i = 0; i < _arrs.Length; ++i)
        {
            _one = _arrs[i];
            if (_one is Texture2D)
            {
                _assetPath = BuildTools.GetPath(_one);
                AssetDatabase.ImportAsset(_assetPath);
            }
        }
    }

    [MenuItem("Assets/Tools/Re - Import All Texutes")]
    static void ReImportAllTexutes()
    {
        string _fd = Application.dataPath;
        string[] _arrs = Directory.GetFiles(_fd, "*.png", SearchOption.AllDirectories);
        Object obj = null;
        string fpAsset = "";
        for (int i = 0; i < _arrs.Length; i++)
        {
            fpAsset = _arrs[i];
            obj = BuildTools.Load4Develop(fpAsset);
            if (obj == null)
                continue;
            fpAsset = BuildTools.GetPath(obj);
            AssetDatabase.ImportAsset(fpAsset);
        }
    }

#if UI_SPRITE_ATLAS
    [MenuItem("Assets/Tools/Delete - SpriteAtlas")]
    static void DeleteSpriteAtlas()
    {
        Object[] _arrs = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
        if(_arrs.Length > 0)
        {
            DeleteSpriteAtlas(_arrs[0]);
        }
    }

     static void DeleteSpriteAtlas(Object _objFolder)
    {
        string _assetPath = BuildTools.GetPath(_objFolder);
        string _fp = BuildTools.GetFullPath4Ed(_assetPath);
        string _fd = _fp;
        if (_fp.Contains("."))
        {
            _fd = BuildTools.GetFolder(_fp);
        }
        string _fn = Core.Kernel.PathEx.GetFileNameNoSuffix(_fd);
        string _fpSA = string.Format("{0}/{1}.spriteatlas", _fd, _fn);
        BuildTools.DelFile(_fpSA);
    }

    [MenuItem("Assets/Tools/Re - SpriteAtlas")]
    static void ReSpriteAtlas()
    {
        Object[] _arrs = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
        for (int i = 0; i < _arrs.Length; ++i)
        {
            ReSpriteAtlas(_arrs[i]);
        }
    }

    static void ReSpriteAtlas(Object _objFolder)
    {
        string _assetPath = BuildTools.GetPath(_objFolder);
        string _fp = BuildTools.GetFullPath4Ed(_assetPath);
        string _fd = _fp;
        if (_fp.Contains("."))
        {
            _fd = BuildTools.GetFolder(_fp);
        }
        string _fn = Core.Kernel.PathEx.GetFileNameNoSuffix(_fd);
        string[] _arrs = Directory.GetFiles(_fd, "*.png", SearchOption.TopDirectoryOnly);
        if (_arrs.Length <= 0)
            return;
        string _fpSA = string.Format("{0}/{1}.spriteatlas", _fd, _fn);
        BuildTools.DelFile(_fpSA);
        string _assetPathSA = BuildTools.Path2AssetsStart(_fpSA);
        SpriteAtlas atlas = new SpriteAtlas();
        // 设置参数 可根据项目具体情况进行设置
        SpriteAtlasPackingSettings packSetting = new SpriteAtlasPackingSettings()
        {
            blockOffset = 1,
            enableRotation = false,
            enableTightPacking = false,
            padding = 2,
        };
        atlas.SetPackingSettings(packSetting);

        SpriteAtlasTextureSettings textureSetting = new SpriteAtlasTextureSettings()
        {
            readable = false,
            generateMipMaps = false,
            sRGB = true,
            filterMode = FilterMode.Bilinear,
        };
        atlas.SetTextureSettings(textureSetting);

        TextureImporterPlatformSettings platformSetting = new TextureImporterPlatformSettings()
        {
            maxTextureSize = 2048,
            format = TextureImporterFormat.Automatic,
            crunchedCompression = true,
            textureCompression = TextureImporterCompression.Compressed,
            compressionQuality = 50,
        };
        atlas.SetPlatformSettings(platformSetting);

        AssetDatabase.CreateAsset(atlas, _assetPathSA);

        // atlas.Add(new[] { _objFolder });
        Object obj = null;
        string fpAsset = null;
        for (int i = 0; i < _arrs.Length; i++)
        {
            fpAsset = _arrs[i];
            obj = BuildTools.Load4Develop(fpAsset);
            if (obj == null)
                continue;
            atlas.Add(new[] { obj });
        }
        AssetDatabase.SaveAssets();
    }
#endif

}