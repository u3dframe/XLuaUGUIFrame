using UnityEngine;
using System.Collections.Generic;
using Core;


/// <summary>
/// 类名 : 本地话
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-06-27 16:37
/// 功能 : key值对应相应的语言
/// </summary>
static public class Localization
{
	static Dictionary<string, Dictionary<string, string>> mDicLgs = new Dictionary<string,Dictionary<string, string>>();
	static string mLanguage = null;
	static Dictionary<string, string> mCurr = null,mCTemp = null;
	static public System.Action onLocalize; // 语言改变时候的通知
	
	/// <summary>
	/// Name of the currently active language.
	/// </summary>
	static public string language
	{
		get
		{
			if (string.IsNullOrEmpty(mLanguage))
			{
				LoadAndSelect(mLanguage);
			}
			return mLanguage;
		}
		set
		{
			if (mLanguage != value)
			{
				mLanguage = value;
				LoadAndSelect(mLanguage);
			}
		}
	}

	static private Dictionary<string, string> GetCurrDict (string language)
	{
		if(mDicLgs.ContainsKey(language))
		{
			return mDicLgs[language];
		}
		return null;
	}
	
	static public bool ReLoad (string language,bool isCsv)
	{
		string fn = null;
		if (isCsv) fn = string.Format("lanuage/{0}.csv",language);
		else  fn = string.Format("lanuage/{0}.properties",language);
		string val = GameFile.GetText(fn).Trim();
		return ReLoad(language,val,isCsv);
	}
	
	static public bool ReLoad (string language,string val,bool isCsv)
	{
		if (string.IsNullOrEmpty(val)) return false;
		string[] _rows = GameFile.SplitRow(val);
		if (GameFile.IsNullOrEmpty(_rows)) return false;
		mCTemp = GetCurrDict(language);
		if(mCTemp == null)
			mCTemp = new Dictionary<string, string>();
		mCTemp.Clear();
		
		int lens = _rows.Length;
		char[] spt = isCsv ? GameFile.m_cSpComma : GameFile.m_cSpEqual;
		string[] _cols;
		string _k,_v;
		for(int i = 0; i < lens; i++){
			_cols = GameFile.Split(_rows[i],spt,true);
			if(_cols == null || _cols.Length <= 1)
				continue;
			_k = _cols[0];
			_v = _cols[1].Replace("\\n","\n");
			// 判断下
			if(mCTemp.ContainsKey(_k))
				Debug.LogErrorFormat("==== has same key = [{0}],val = [{1}] ",_k,_v);
			else
				mCTemp.Add(_k, _v);
		}
		lens = mCTemp.Count;
		if(lens > 0)
		{
			mDicLgs[language] = mCTemp; 
		}
		return lens > 0;
	}
	
	static bool Load (ref string val,bool isCsv)
	{
		if (string.IsNullOrEmpty(val)) val = GameLanguage.strCurLanguage;
		if(mDicLgs.ContainsKey(val))
		{
			return true;
		}
		return ReLoad(val,isCsv);
	}
	
	static void ReLangueInfo (string val)
	{
		if(mDicLgs.ContainsKey(val))
		{
			mCurr = mDicLgs[val];
			mLanguage = val;
			if (onLocalize != null) onLocalize();
		}
	}

	static public bool LoadAndSelect (string val,bool isCsv = true)
	{
		mCurr = null;
		string vRef = val;
		if(Load(ref vRef,isCsv))
		{
			ReLangueInfo(vRef);
			return true;
		}
		Debug.LogErrorFormat("==== Localization not has language = [{0}],SrcLanuage = [{1}] ",vRef,val);
		return false;
	}

	static public bool Exists (string key)
	{
		return mCurr != null && mCurr.ContainsKey(key);
	}
	
	static public string Get (string key)
	{
		if (string.IsNullOrEmpty(key)) return null;

		if (mLanguage == null)
		{
			mLanguage = language;
		}
		
		if (mLanguage == null)
		{
			Debug.LogError("No localization data present");
			return null;
		}
		
		if(Exists(key))
			return mCurr[key];
		return key;
	}
	
	static public string Format (string key, params object[] parameters) {
		if(Exists(key))
			return string.Format(Get(key), parameters); 
		return null;
	}
}
