using UnityEngine;
using System.Collections;
using UnityEngine.UI;

/// <summary>
/// 类名 : UGUILocalize
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-06-27 16:37
/// 功能 : UGUI的文本本地化
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Text))]
[AddComponentMenu("UI/UGUILocalize")]
public class UGUILocalize : GobjLifeListener {
	// 取得对象
	static public new UGUILocalize Get(GameObject gobj,bool isAdd){
		UGUILocalize _r = gobj.GetComponent<UGUILocalize> ();
		if (isAdd && UtilityHelper.IsNull(_r)) {
			_r = gobj.AddComponent<UGUILocalize> ();
		}
		return _r;
	}

	static public new UGUILocalize Get(GameObject gobj){
		return Get(gobj,true);
	}

	public string m_key = "key";
	public Text m_text;
	bool m_isInit = false;
	object[] fmtPars = null;
	string _val = "";

	protected override void OnCall4Awake()
	{
		Init();
	}

	protected override void OnCall4Hide()
	{
		Localization.onLocalize -= OnLocalize;
	}	

	protected override void OnCall4Show()
	{
		Init ();
		OnLocalize();
		Localization.onLocalize += OnLocalize;
	}

	protected override void OnCall4Destroy()
	{
		Localization.onLocalize -= OnLocalize;
	}

	void Init()
	{
		if(m_isInit)
			return;
		m_isInit = true;
		m_text = gameObject.GetComponent<Text>();
	}

	void OnLocalize()
	{
		if(!m_text) return;
		if(fmtPars == null || fmtPars.Length <= 0) _val = Localization.Get(m_key);
		else _val = Localization.Format(m_key,fmtPars);
		_val =  (_val == null) ? ((m_key == null) ? "" : m_key) : _val;
		Debug.LogErrorFormat("===[{0}] = [{1}]",m_key,_val);
		m_text.text = _val;
	}

	public void SetText(string key){
		this.m_key = key;
		OnLocalize();
	}

	public void SetText(int key){
		SetText(key.ToString());
	}

	public void SetUText(string val){
		if(!m_text)
			return;
		val =  (val == null) ? "" : val;
		m_text.text = val;
	}

	public void Format(string key,object[] pars){
		this.m_key = key;
		this.fmtPars = pars;
		OnLocalize();
	}

	public void Format(int key,object[] pars){
		Format(key.ToString(),pars);
	}
}