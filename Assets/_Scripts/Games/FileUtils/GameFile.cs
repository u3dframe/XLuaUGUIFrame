using UnityEngine;
using System.Collections;
using System.IO;

namespace Core
{
	/// <summary>
	/// 类名 : 游戏 路径
	/// 作者 : Canyon / 龚阳辉
	/// 日期 : 2020-03-26 09:29
	/// 功能 : 
	/// </summary>
	public class GameFile : Kernel.Resources
	{
		// zip 压缩文件列表(将文件分包体大小来压缩,减小解压时所需内存)
		static public readonly string m_fpZipList = string.Concat (m_appContentPath,"ziplist.txt");
		static public readonly string m_fmtZip = string.Concat (m_appContentPath,"resource{0}.zip");
				
		static public readonly char[] m_cSpRow = "\r\n\t".ToCharArray();
		static public readonly char[] m_cSpComma = ",".ToCharArray();
		static public readonly char[] m_cSpEqual = "=".ToCharArray();

		// 编辑模式
		static public bool isEditor{
			get{
				#if UNITY_EDITOR
				return true;
				#else
				return false;
				#endif
			}
		}

		static public void AppQuit(){
			#if UNITY_EDITOR
			UnityEditor.EditorApplication.isPlaying = false;
			#else
			Application.Quit ();
			#endif
		}
		
		// 取得路径
		static public string GetFilePath(string fn){
			return string.Concat (m_dirRes, fn);
		}

		static public string GetStreamingFilePath(string fn){
			return string.Concat (m_appContentPath, fn);
		}

		static public string GetPath(string fn){
			string _fp = GetFilePath (fn);
			if (File.Exists (_fp)) {
				return _fp;
			}

			return GetStreamingFilePath (fn);
		}

		static public void DeleteFile(string fn,bool isFilePath){
			string _fp = isFilePath ? fn : GetFilePath (fn);
			DelFile(_fp);
		}

		static public void DeleteFile(string fn){
			DeleteFile (fn, false);
		}

		static private bool IsTextInCT(string fn){
			return fn.EndsWith(".csv") || fn.IndexOf("protos/") != -1;
		}

		// 取得文本内容
		static public string GetText(string fn){
			string _fp = GetPath (fn);
#if UNITY_EDITOR
		if(IsTextInCT(fn)){
			_fp = string.Format("{0}CsvTxts/{1}",m_appAssetPath,fn);
		}
#endif
			if (File.Exists (_fp)) {
				return File.ReadAllText (_fp);
			}

			string _suffix = Path.GetExtension (fn);
			string _fnNoSuffix = fn.Substring(0, fn.LastIndexOf(_suffix));
			TextAsset txtAsset = Resources.Load<TextAsset> (_fnNoSuffix); // 可以不用考虑释放txtAsset
			string _ret = "";
			if (txtAsset){
				_ret = txtAsset.text;
				Resources.UnloadAsset(txtAsset);
			}
			return _ret;
		}

		// 文件是否存在可读写文件里
		static public bool IsExistsFile(string fn,bool isFilePath){
			string _fp = isFilePath ? fn : GetFilePath (fn);
			return File.Exists (_fp);
		}

		// 取得文件流
		static public byte[] GetFileBytes(string fn){
			string _fp = GetPath (fn);
			if (File.Exists (_fp)) {
				return File.ReadAllBytes (_fp);
			}

			string _suffix = Path.GetExtension (fn);
			string _fnNoSuffix = fn.Substring(0, fn.LastIndexOf(_suffix));
			TextAsset txtAsset = Resources.Load<TextAsset> (_fnNoSuffix); // 可以不用考虑释放txtAsset
			byte[] _bts = null;
			if (txtAsset){
				_bts = txtAsset.bytes;
				UnLoadOne(txtAsset);
			}
			return _bts;
		}

		static public string ReUrlEnd(string url){
			int _index = url.LastIndexOf("/");
			if (_index == url.Length - 1) {
				return url;
			}
			return string.Concat (url, "/");
		}

		static public string ReUrlTime(string url){
			return string.Concat (url, "?time=", System.DateTime.Now.Ticks);
		}

		static public string ReUrlTime(string url,string fn){
			url = ReUrlEnd (url);
			return string.Concat (url,fn,"?time=", System.DateTime.Now.Ticks);
		}

		static public string ReUrlTime(string url,string proj,string fn){
			if (!string.IsNullOrEmpty (proj)) {
				url = ReUrlEnd (url);
				url = string.Concat (url, proj);
			}
			return ReUrlTime (url, fn);
		}

		static public string[] Split(string val,char[] spt,bool isRmEmpty){
			if(string.IsNullOrEmpty(val) || spt == null || spt.Length <= 0)
				return null;
			System.StringSplitOptions _sp = System.StringSplitOptions.None;
			if(isRmEmpty) _sp = System.StringSplitOptions.RemoveEmptyEntries;
			return val.Split(spt,_sp);
		}

		static public string[] SplitRow(string val){
			return Split(val,m_cSpRow,true);
		}

		static public string[] SplitComma(string val){
			return Split(val,m_cSpComma,false);
		}

		static public bool IsNullOrEmpty(string[] arrs){
			if(arrs == null || arrs.Length <= 0)
				return true;
			return false;
		}

		/// <summary>
        /// manifest的路径
        /// </summary>
        static public string m_fpABManifest{
            get{
                return GetPath(m_curPlatform);
            }
        }
	}
}