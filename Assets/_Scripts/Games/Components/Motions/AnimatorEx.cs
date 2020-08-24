using UnityEngine;
using Core.Kernel;

public delegate void DF_ASM_MotionLife(Animator animator, AnimatorStateInfo stateInfo, int layerIndex);
public delegate void DF_ASM_SubLife(Animator animator, int stateMachinePathHash);

/// <summary>
/// 类名 : Amimator 扩展脚本
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-08-22 22:17
/// 功能 : 
/// </summary>
[ExecuteInEditMode]
public class AnimatorEx : PrefabElement
{
	static public new AnimatorEx Get(GameObject gobj,bool isAdd){
		return UtilityHelper.Get<AnimatorEx>(gobj,isAdd);
	}

	static public new AnimatorEx Get(GameObject gobj){
		return Get(gobj,true);
	}

	public Animator m_animator;
	public string m_kActionState = "ation_state";
	public int m_actionState = 0;
	private int _pre_aState = -1;
	[Range(0f,5f)] public float m_actionSpeed = 1;
	private float _pre_aSpeed = -1;

	public event DF_ASM_MotionLife m_evt_smEnter;
	public event DF_ASM_MotionLife m_evt_smUpdate;
	public event DF_ASM_MotionLife m_evt_smExit;
	public event DF_ASM_MotionLife m_evt_smMove;
	public event DF_ASM_MotionLife m_evt_smIK;

	public event DF_ASM_SubLife m_evt_subEnter;
	public event DF_ASM_SubLife m_evt_subExit;

	override protected void OnCall4Awake(){
		this.csAlias = "ANI_Ex";
		if(this.m_animator == null){
			this.m_animator = this.m_gobj.GetComponentInChildren<Animator>(true);
		}
		if(this.m_animator == null){
			Debug.LogErrorFormat("=== this animator is null, gobj name = [{0}]",this.m_gobj.name);
		}

		Messenger.AddListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMEnter,_CF_SM_Enter);
		Messenger.AddListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMUpdate,_CF_SM_Update);
		Messenger.AddListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMExit,_CF_SM_Exit);
		Messenger.AddListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMMove,_CF_SM_Move);
		Messenger.AddListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSM_IK,_CF_SM_IK);

		Messenger.AddListener<Animator,int>(MsgConst.Msg_OnSubSMEnter,_CF_Sub_Enter);
		Messenger.AddListener<Animator,int>(MsgConst.Msg_OnSubSMExit,_CF_Sub_Exit);
	}

	override protected void OnClear(){
		m_animator = null;

		Messenger.RemoveListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMEnter,_CF_SM_Enter);
		Messenger.RemoveListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMUpdate,_CF_SM_Update);
		Messenger.RemoveListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMExit,_CF_SM_Exit);
		Messenger.RemoveListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMMove,_CF_SM_Move);
		Messenger.RemoveListener<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSM_IK,_CF_SM_IK);

		Messenger.RemoveListener<Animator,int>(MsgConst.Msg_OnSubSMEnter,_CF_Sub_Enter);
		Messenger.RemoveListener<Animator,int>(MsgConst.Msg_OnSubSMExit,_CF_Sub_Exit);
	}

	virtual protected void Update (){
		if(this.m_animator){
			if(this.m_actionState != this._pre_aState){
				SetAction(this.m_actionState);
			}

			if(this.m_actionSpeed != this._pre_aSpeed){
				SetSpeed(this.m_actionSpeed);
			}
		}
	}

	void _Exc_SM_Call(DF_ASM_MotionLife cfunc,Animator animator, AnimatorStateInfo stateInfo, int layerIndex) {
		if(cfunc != null)
			cfunc(animator,stateInfo,layerIndex);
	}

	void _Exc_Sub_Call(DF_ASM_SubLife cfunc,Animator animator , int stateMachinePathHash) {
		if(cfunc != null)
			cfunc(animator,stateMachinePathHash);
	}

	void _CF_SM_Enter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex){
		if(animator != m_animator) return;
		_Exc_SM_Call(m_evt_smEnter,animator,stateInfo,layerIndex);
	}

	void _CF_SM_Update(Animator animator, AnimatorStateInfo stateInfo, int layerIndex){
		if(animator != m_animator) return;
		_Exc_SM_Call(m_evt_smUpdate,animator,stateInfo,layerIndex);
	}

	void _CF_SM_Exit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex){
		if(animator != m_animator) return;
		_Exc_SM_Call(m_evt_smExit,animator,stateInfo,layerIndex);
	}

	void _CF_SM_Move(Animator animator, AnimatorStateInfo stateInfo, int layerIndex){
		if(animator != m_animator) return;
		_Exc_SM_Call(m_evt_smMove,animator,stateInfo,layerIndex);
	}

	void _CF_SM_IK(Animator animator, AnimatorStateInfo stateInfo, int layerIndex){
		if(animator != m_animator) return;
		_Exc_SM_Call(m_evt_smIK,animator,stateInfo,layerIndex);
	}

	void _CF_Sub_Enter(Animator animator, int stateMachinePathHash){
		if(animator != m_animator) return;
		_Exc_Sub_Call(m_evt_subEnter,animator,stateMachinePathHash);
	}

	void _CF_Sub_Exit(Animator animator, int stateMachinePathHash){
		if(animator != m_animator) return;
		_Exc_Sub_Call(m_evt_subExit,animator,stateMachinePathHash);
	}

	public void SetSpeed(float value){
		if(this._pre_aSpeed == this.m_actionSpeed) return;
		this._pre_aSpeed = this.m_actionSpeed;
		this.m_actionSpeed = value;

		if(this.m_animator == null) return;
		this.m_animator.speed = this.m_actionSpeed;
	}

	public void SetParameter4Int(string key,int value){
		if(this.m_animator == null) return;
		this.m_animator.SetInteger(key,value);
	}

	public void SetAction(int value){
		if(this._pre_aState == this.m_actionState) return;
		this._pre_aState = this.m_actionState;
		this.m_actionState = value;

		SetParameter4Int(this.m_kActionState,this.m_actionState);
	}

	public void PlayAction(int state){
		this.m_actionState = state;
	}

	public void PlayAction(string stateName,int layer,float normalizedTime){
		if(this.m_animator == null) return;
		this.m_animator.Play(stateName,layer,normalizedTime);
	}

	public void PlayAction(string stateName){
		if(this.m_animator == null) return;
		this.m_animator.Play(stateName,0,0);
	}
}