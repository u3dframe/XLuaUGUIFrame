using UnityEngine;
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

	override protected void Update (){
		base.Update();
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
	}

	override protected void OnClear(){
		base.OnClear();
		this.m_c_ctrler = null;
	}

	public void SetRadiusAndHeight(float radius,float height){
		if(this.m_c_ctrler == null) return;
		this.m_c_ctrler.radius = radius;
		this.m_c_ctrler.height = height;
		float yCenter =  (height <=  2 * radius) ? radius : height / 2;
		this.m_c_ctrler.center = new Vector3(0,yCenter,0);
	}

	[ContextMenu("Re Def Radius Height")]
	public void ReRHeightDef(){
		SetRadiusAndHeight(0.5f,2f);
	}
}