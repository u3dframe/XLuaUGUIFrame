using UnityEngine;
using System;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System.Collections.Generic;



public class PassableEvent : MonoBehaviour, IPointerClickHandler, IPointerDownHandler, IPointerUpHandler
{
    Action onClick;

    public void SetClickHandler(Action action)
    {
        onClick = action;
    }

    //监听按下
    public void OnPointerDown(PointerEventData eventData)
    {
        PassEvent(eventData, ExecuteEvents.pointerDownHandler);
    }

    //监听抬起
    public void OnPointerUp(PointerEventData eventData)
    {
        PassEvent(eventData, ExecuteEvents.pointerUpHandler);
    }

    //监听点击
    public void OnPointerClick(PointerEventData eventData)
    {
        onClick?.Invoke();
        PassEvent(eventData, ExecuteEvents.submitHandler);
        PassEvent(eventData, ExecuteEvents.pointerClickHandler);
    }


    //把事件透下去
    public void PassEvent<T>(PointerEventData data, ExecuteEvents.EventFunction<T> function)
        where T : IEventSystemHandler
    {
        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(data, results);
        GameObject current = data.pointerCurrentRaycast.gameObject;
        for (int i = 0; i < results.Count; i++)
        {
            if (current != results[i].gameObject)
            {
                var obj = results[i].gameObject;
                while (!ExecuteEvents.Execute(obj, data, function))
                {
                    if (obj.transform.parent == null)
                        break;
                    obj = obj.transform.parent.gameObject;
                }
                //只转发给第一个响应
                break;
            }
        }
    }


}