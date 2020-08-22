using UnityEngine;
using Core.Kernel;

/// <summary>
/// 类名 : Animator State Machine
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-08-22 08:33
/// 功能 : Motions 动画片段回调
/// </summary>
public class ClipStateMachine : BasicStateMachine
{
    // OnStateEnter is called when a transition starts and the state machine starts to evaluate this state
    override public void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        Messenger.Brocast<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMEnter,animator,stateInfo,layerIndex);
    }

    // OnStateUpdate is called on each Update frame between OnStateEnter and OnStateExit callbacks
    override public void OnStateUpdate(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        Messenger.Brocast<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMUpdate,animator,stateInfo,layerIndex);
    }

    // OnStateExit is called when a transition ends and the state machine finishes evaluating this state
    override public void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        Messenger.Brocast<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMExit,animator,stateInfo,layerIndex);
    }

    // OnStateMove is called right after Animator.OnAnimatorMove()
    override public void OnStateMove(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
       // Implement code that processes and affects root motion  --  实现处理和影响根运动的代码
       Messenger.Brocast<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSMMove,animator,stateInfo,layerIndex);
    }

    // OnStateIK is called right after Animator.OnAnimatorIK()
    override public void OnStateIK(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
       // Implement code that sets up animation IK (inverse kinematics)  --  实现设置动画IK（反向运动学）的代码
       Messenger.Brocast<Animator,AnimatorStateInfo,int>(MsgConst.Msg_OnSM_IK,animator,stateInfo,layerIndex);
    }
}
