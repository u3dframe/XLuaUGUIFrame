using UnityEngine;
using Core.Kernel;

/// <summary>
/// 类名 : 控制动作Alpha变化的
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-08-23 20:13
/// 功能 : 
/// </summary>
public class ClipStateMachineAlpha : ClipStateMachine
{
    /// <summary>
    /// 时间(0~1)曲线 - 控制alpha值(0~1)
    /// </summary>
    public AnimationCurve m_ac_alpha;

    private Material m_mat;
    private Color m_mat_color = Color.white;
    
    override public void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnStateEnter(animator,stateInfo,layerIndex);

        Renderer _rder = animator.GetComponentInChildren<Renderer>();
        if(_rder != null){
            m_mat = _rder.materials[0];
            if(m_mat != null){
                m_mat_color = m_mat.color;
            }
        }
    }

    override public void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        base.OnStateUpdate(animator,stateInfo,layerIndex);

        if (stateInfo.normalizedTime < 0 || stateInfo.normalizedTime > 1 || m_mat == null) return;

        float _alpha = m_ac_alpha.Evaluate(stateInfo.normalizedTime);
        m_mat_color.a = _alpha;
        m_mat.color = m_mat_color;
    }

}
