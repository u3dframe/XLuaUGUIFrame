﻿using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;

/// <summary>
/// 类名 : UGUIButton
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-07-07 10:37
/// 功能 : 控制按钮单击事件
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(UGUIEventListener))]
[AddComponentMenu("UI/UGUIButton")]
public class UGUIButton : GobjLifeListener {
	// 取得对象
	static public new UGUIButton Get(GameObject gobj,bool isAdd){
		UGUIButton _r = gobj.GetComponent<UGUIButton> ();
		if (isAdd && UtilityHelper.IsNull(_r)) {
			_r = gobj.AddComponent<UGUIButton> ();
		}
		return _r;
	}

	static public new UGUIButton Get(GameObject gobj){
		return Get(gobj,true);
	}

	static public bool isFreezedAll = false; // 冻结所有按钮
	static List<int> exceptInstanceIDs = new List<int>(); // 排除不被冻结的对象

	static public bool IsInExcept(int intasnceID){
		return exceptInstanceIDs.Contains(intasnceID);
	}

	static public void AddExcept(int intasnceID){
		if(IsInExcept(intasnceID)) return;
		exceptInstanceIDs.Add(intasnceID);
	}

	static public void RemoveExcept(int intasnceID){
		exceptInstanceIDs.Remove(intasnceID);
	}

	int _selfID = 0;
	Vector3 v3Scale;
	public bool m_isPress = true;
	[Range(0.5f,1.5f)]
    public float m_scale = 0.98f;

	UGUIEventListener m_evt = null;
	[HideInInspector] public DF_UGUIV2Bool m_onPress;
	[HideInInspector] public DF_UGUIPos m_onClick;

	protected override void OnCall4Awake()
    {
		this._selfID = m_gobj.GetInstanceID ();
        this.v3Scale = m_trsf.localScale;

        this.m_evt = UGUIEventListener.Get(m_gobj);
        this.m_evt.onPress = _OnPress;
        this.m_evt.onClick = _OnClick;
    }

	protected override void OnCall4Hide()
    {
        this.m_evt.enabled = false;
    }

    protected override void OnCall4Show()
    {
        this.m_evt.enabled = true;
    }

	void _OnPress(GameObject obj,bool isPress,Vector2 pos)
    {
		if (IsFreezedAll()) return;

        if (this.m_onPress != null) this.m_onPress(m_gobj,isPress,pos);

		if(!this.m_isPress) return;
		m_trsf.localScale =  isPress ? (v3Scale * m_scale) : v3Scale;
    }

	void _OnClick(GameObject obj,Vector2 pos)
    {
		if (IsFreezedAll()) return;

        if (this.m_onClick != null) this.m_onClick(m_gobj,pos);
    }

	bool IsFreezedAll(){
		return isFreezedAll && !IsInExcept(_selfID);
	}

	protected override void OnCall4Destroy(){
		this.m_onPress = null;
		this.m_onClick = null;
		this.m_evt = null;
		RemoveExcept(this._selfID);
	}
}