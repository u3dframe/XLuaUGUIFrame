﻿using UnityEngine;
using System;
using System.Collections.Generic;

/// <summary>
/// 类名 : Animator 数据脚本
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2021-01-08 12:33
/// 功能 : 
/// </summary>
public class ED_Animator : Core.Kernel.Beans.ED_Comp
{
    static public new ED_Animator Builder(UnityEngine.Object uobj)
    {
        return Builder<ED_Animator>(uobj);
    }

    public bool m_isSLog { get;set; }
    public bool m_isSLogError = true;
    public Animator m_curAni { get; set; }
    protected AnimationClip[] m_clips = null;
    private Dictionary<string,bool> m_dic = null;
    public string m_nameParent { get{if(this.m_parent) return this.m_parent.name; return "";} }
    private Core.DF_OnInt _m_cfAnimEvent = null;
    private Core.DF_OnInt _m_cfOnLife = null;
    protected SceneInfoEx m_curSInfo { get; private set; }
    
    public ED_Animator() : base()
    {
    }

    override public void InitComp(string strComp)
    {
        base.InitComp(strComp);
    }

    override public void InitComp(Component comp)
    {
        base.InitComp(comp);
    }

    override public void InitComp(string strComp, Action cfDestroy, Action cfShow, Action cfHide)
    {
        base.InitComp(strComp, cfDestroy, cfShow, cfHide);
    }

    override public void InitComp(Component comp, Action cfDestroy, Action cfShow, Action cfHide)
    {
         if(comp == null)
            comp = PrefabElement.Get(this.m_gobj,false);
        base.InitComp(comp, cfDestroy, cfShow, cfHide);
        this.m_curAni = this.m_gobj.GetComponent<Animator>();
        this.m_curSInfo = this.m_gobj.GetComponentInChildren<SceneInfoEx>(true);

        if(this.m_curAni)
        {
            RuntimeAnimatorController run = this.m_curAni.runtimeAnimatorController;
            if(run)
                this.m_clips = run.animationClips;
        }
    }

    virtual public void InitComp(string strComp,Core.DF_OnInt cfLife)
    {
        this._m_cfOnLife = cfLife;
        base.InitComp(strComp);
    }

    virtual public void InitComp(Component comp,Core.DF_OnInt cfLife)
    {
        this._m_cfOnLife = cfLife;
        base.InitComp(comp);
    }

    override protected void On_Destroy(GobjLifeListener obj)
    {
        this.m_curAni = null;
        this.m_dic = null;
        this._m_cfAnimEvent = null;
        var _call_ = this._m_cfOnLife;
        this._m_cfOnLife = null;
        this.m_curSInfo = null;
        this.CleanAllEvent(true);
        base.On_Destroy(obj);
        
        if(_call_ != null)
            _call_(2);
    }

    override protected void On_Hide()
    {
        base.On_Hide();
        this._OnCallOnLife(0);
    }

    override protected void On_Show()
    {
        base.On_Show();
        this._OnCallOnLife(1);
    }

    void _OnCallOnLife(int val)
    {
        if(_m_cfOnLife != null)
            _m_cfOnLife(val);
    }

    public void SLog(object title,object msg1,object msg2 = null,object msg3 = null)
    {
        if(this.m_isSLog)
            Debug.LogFormat( "=== {0} , [{1}] , [{2}] , [{3}] , [{4}]",title,this.m_gobjID,msg1,msg2,msg3);
    }

    public void SLogError(object title,object msg1,object msg2 = null,object msg3 = null)
    {
        if(this.m_isSLogError)
            Debug.LogErrorFormat( "=== {0} , [{1}] , [{2}] , [{3}] , [{4}]",title,this.m_gobjID,msg1,msg2,msg3);
    }

    private void CleanAllEvent(bool isDiscard)
    {
        if(LuaHelper.IsNullOrEmpty(this.m_clips))
            return;

        AnimationClip _clip = null;
        for (int i = 0; i < this.m_clips.Length; i++)
        {
            _clip = this.m_clips[i];
            if(_clip != null)
                _clip.events = default;
        }

        if(isDiscard)
            this.m_clips = null;
    }

    private bool IsInEvents(AnimationClip clip,string key,float normarl)
    {
        if(clip == null)
            return true;
        AnimationEvent[] events = clip.events;
        if(string.IsNullOrEmpty(key))
            return true;
        
        if(LuaHelper.IsNullOrEmpty(events))
            return false;
        
        AnimationEvent _evt = null;
        string _cur_key = null;
        float _cur_normarl = 1;
        for (int i = 0; i < events.Length; i++)
        {
            _evt = events[i];
            if(_evt == null)
                continue;
            _cur_key = string.Format("[{0}]_[{1}]_[{2}]",clip.name,_evt.functionName,_evt.intParameter);
            if(key.StartsWith(_cur_key))
            {
                _cur_normarl = _evt.time - normarl;
                if(Mathf.Abs(_cur_normarl) <= 0.01f)
                    return true;
            }
        }
        return false;
    }

    /// <summary>
    /// 添加动画事件
    /// </summary>
    public void AddAnimationEvent(string clipName,float normarl,string func,int pval)
    {
        if(LuaHelper.IsNullOrEmpty(this.m_clips) || string.IsNullOrEmpty(clipName))
            return;

        normarl = Mathf.Clamp01(normarl);

        string _key = string.Format("[{0}]_[{1}]_[{2}]_[{3}]",clipName,func,pval,normarl);
        if(this.m_dic == null)
            this.m_dic = new Dictionary<string, bool>();
        if(this.m_dic.ContainsKey(_key))
            return;
        this.m_dic.Add(_key,true);

        AnimationClip[] _clips = this.m_clips;
        AnimationClip _clip = null;
        for (int i = 0; i < _clips.Length; i++)
        {
            _clip = _clips[i];
            if(_clip == null)
                continue;

            if (_clip.name.Equals(clipName,StringComparison.OrdinalIgnoreCase))
            {
                normarl = normarl * _clip.length;
                if(IsInEvents(_clip,_key,normarl))
                    continue;

                AnimationEvent _event = new AnimationEvent();
                _event.functionName = func;
                _event.intParameter = pval;
                _event.time = normarl;
                _clip.AddEvent(_event);
                break;
            }
        }
        this.m_curAni.Rebind();
    }

    public void AddAnimationEvent(string clipName,float normarl,int pval)
    {
        this.AddAnimationEvent(clipName,normarl,"OnCallAnimEvent",pval);
    }

    public void RmvAnimationEvent(string clipName)
    {
        if(LuaHelper.IsNullOrEmpty(this.m_clips) || string.IsNullOrEmpty(clipName))
            return;

        bool _isHasKey = false;
        if(this.m_dic != null)
        {
            List<string> _keys = new List<string>(this.m_dic.Keys);
            string _key =  null;
            for (int i = 0; i < _keys.Count; i++)
            {
                _key = _keys[i];
                if(_key.Contains(clipName))
                {
                    this.m_dic.Remove(_key);
                    _isHasKey = true;
                }
            }
        }

        if(!_isHasKey)
            return;
        
        AnimationClip[] _clips = this.m_clips;
        AnimationClip _clip = null;
        for (int i = 0; i < _clips.Length; i++)
        {
            _clip = _clips[i];
            if(_clip == null)
                continue;

            if (_clip.name.Equals(clipName,StringComparison.OrdinalIgnoreCase))
            {
                _clip.events = default;
            }
        }
        this.m_curAni.Rebind();
    }

    public void RmvAllRmvAnimationEvent()
    {
        if(this.m_dic != null)
            this.m_dic.Clear();
        this.CleanAllEvent(false);
        if(this.m_curAni)
            this.m_curAni.Rebind();
    }

    public void PlayAnimator(string stateName,bool isOrder,float speed,int unique,Core.DF_OnInt cfAnimEvent)
    {
        if(LuaHelper.IsNullOrEmpty(this.m_clips) || string.IsNullOrEmpty(stateName))
            return;
        
        _m_cfAnimEvent = cfAnimEvent;
        this.AddAnimationEvent(stateName,1f,unique);
        this.m_compGLife.ReCFAnimEvent(_OnCallAnimEvent,true);
        if(!isOrder)
            this.m_curAni.StartPlayback();
        this.m_curAni.speed = (isOrder ? 1 : -1) * speed;
        this.m_curAni.Play(stateName,-1,isOrder ? 0 : 1);
        // this.m_curAni.StopPlayback();
    }

    public void ReAnimator()
    {
        if(!this.m_curAni || !this.m_curAni.isActiveAndEnabled)
            return;
        this.m_curAni.Play("None");
    }

    void _OnCallAnimEvent(int val)
    {
        if(_m_cfAnimEvent != null)
            _m_cfAnimEvent(val);
    }

    public void ReSInfo()
    {
        if(this.m_curSInfo != null)
            this.m_curSInfo.LoadInfos();
    }
}
