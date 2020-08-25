using UnityEngine;
using Core;
using Core.Kernel;

/// <summary>
/// 类名 : CharacterController 扩展脚本
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-08-23 19:17
/// 功能 : 
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(CharacterController))]
public class CharacterControllerEx : AnimatorEx
{
	static public new CharacterControllerEx Get(GameObject gobj,bool isAdd){
		return UtilityHelper.Get<CharacterControllerEx>(gobj,isAdd);
	}

	static public new CharacterControllerEx Get(GameObject gobj){
		return Get(gobj,true);
	}

	public CharacterController m_c_ctrler;
	public event DF_OnUpdate m_cf_OnUpdate;
	private Vector3 m_v3Scale = Vector3.one;

	override protected void Update (){
		base.Update();

		if(this.m_cf_OnUpdate != null){
			this.m_cf_OnUpdate(Time.deltaTime,Time.unscaledDeltaTime);
		}
	}

	void OnControllerColliderHit(ControllerColliderHit hit) {
        // Rigidbody body = hit.collider.attachedRigidbody;
        // if (body == null || body.isKinematic)
        //     return;
        
        // if (hit.moveDirection.y < -0.3F)
        //     return;
        
        // Vector3 pushDir = new Vector3(hit.moveDirection.x, 0, hit.moveDirection.z);
        // body.velocity = pushDir * 2;
    }

	override protected void OnCall4Awake(){
		base.OnCall4Awake();
		this.csAlias = "CCtrler_Ex";
		if(this.m_c_ctrler == null){
			this.m_c_ctrler = this.m_gobj.GetComponentInChildren<CharacterController>(true);
		}
		
		_ReCalcSetOffset();
	}

	override protected void OnCall4Show(){
		base.OnCall4Show();
		_ReCalcSetOffset();
	}

	override protected void OnClear(){
		base.OnClear();
		this.m_c_ctrler = null;
		this.m_cf_OnUpdate = null;
	}

	private void _ReCalcSetOffset(){
		if(this.m_c_ctrler){
			var _diff = this.m_v3Scale - this.m_trsf.lossyScale;
			if(_diff.sqrMagnitude < 0.000001f) return;
			this.m_v3Scale = this.m_trsf.lossyScale;
			float _sOff = this.m_c_ctrler.height * this.m_v3Scale.y + this.m_c_ctrler.radius * 2 * this.m_v3Scale.x;
			_sOff = _sOff > 0.3f ? 0.3f : _sOff;
			this.m_c_ctrler.stepOffset =  _sOff;
		}
	}
	public void SetRadiusAndHeight(float radius,float height){
		if(this.m_c_ctrler == null) return;
		this.m_c_ctrler.radius = radius;
		this.m_c_ctrler.height = height;
		float yCenter =  (height <=  2 * radius) ? radius : height / 2;
		this.m_c_ctrler.center = new Vector3(0,yCenter,0);

		_ReCalcSetOffset();
	}

	[ContextMenu("Re Def Radius Height")]
	public void ReRHeightDef(){
		SetRadiusAndHeight(0.5f,2f);
	}

	public CharacterControllerEx InitCCEx(DF_OnUpdate on_up,DF_ASM_MotionLife on_a_enter,DF_ASM_MotionLife on_a_up,DF_ASM_MotionLife on_a_exit){
		this.m_cf_OnUpdate += on_up;
		this.m_evt_smEnter += on_a_enter;
		this.m_evt_smUpdate += on_a_up;
		this.m_evt_smExit += on_a_exit;
		return this;
	}
}