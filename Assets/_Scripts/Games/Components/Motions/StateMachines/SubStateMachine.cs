using UnityEngine;
using Core.Kernel;

/// <summary>
/// 类名 : Animator Sub State Machine
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-08-22 08:33
/// 功能 : 
/// </summary>
public class SubStateMachine : BasicStateMachine
{
    override public void OnStateMachineEnter(Animator animator, int stateMachinePathHash){
        Messenger.Brocast<Animator,int>(MsgConst.Msg_OnSubSMEnter,animator,stateMachinePathHash);
    }

    override public void OnStateMachineExit(Animator animator, int stateMachinePathHash){
        Messenger.Brocast<Animator,int>(MsgConst.Msg_OnSubSMExit,animator,stateMachinePathHash);
    }
}
