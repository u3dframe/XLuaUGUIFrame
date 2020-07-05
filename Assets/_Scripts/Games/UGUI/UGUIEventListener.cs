using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

/// <summary>
/// 类名 : UGUIEventListener
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-08 16:37
/// 功能 : 处理UGUI界面上事件
/// </summary>
public class UGUIEventListener : EventTrigger {
	static public UGUIEventListener Get(GameObject gobj,bool isAdd){
		UGUIEventListener _r = gobj.GetComponent<UGUIEventListener> ();
		if (isAdd && UtilityHelper.IsNull(_r)) {
			_r = gobj.AddComponent<UGUIEventListener> ();
		}
		return _r;
	}

	static public UGUIEventListener Get(GameObject gobj){
		return Get(gobj,true);
	}

	[System.NonSerialized]
	public System.Action<GameObject,Vector2> onMouseEnter;

	[System.NonSerialized]
	public System.Action<GameObject,Vector2> onMouseExit;

	[System.NonSerialized]
	public System.Action<GameObject,Vector2> onClick;
	
	[System.NonSerialized]
	public System.Action<GameObject,Vector2> onBegDrag;
	
	[System.NonSerialized]
	public System.Action<GameObject,Vector2,Vector2> onDraging;
	
	[System.NonSerialized]
	public System.Action<GameObject,Vector2> onEndDrag;
	
	[System.NonSerialized]
	public System.Action<GameObject,Vector2> onDrop;

	// 移入
	public override void OnPointerEnter (PointerEventData eventData){
		if (onMouseEnter != null) {
			onMouseEnter (gameObject, eventData.position);
		}
	}

	// 移出
	public override void OnPointerExit (PointerEventData eventData){
		if (onMouseExit != null) {
			onMouseExit (gameObject, eventData.position);
		}
	}

	// 单击
	public override void OnPointerClick (PointerEventData eventData){
		if (onClick != null) {
			onClick (gameObject, eventData.position);
		}
	}
	
    // 开始拖拽
    public override void OnBeginDrag(PointerEventData eventData)
    {
        if (onBegDrag != null) {
			onBegDrag (gameObject, eventData.position);
		}
    }
	
	// 推拽中
	public override void OnDrag (PointerEventData eventData){
		if (onDraging != null) {
			onDraging (gameObject, eventData.position,eventData.delta);
		}
	}
	
	// 结束拖拽
    public override void OnEndDrag(PointerEventData eventData)
    {
        if (onEndDrag != null) {
			onEndDrag (gameObject, eventData.position);
		}
    }
	
	// 将元素拖拽到另外一个元素下面执行
    public override void OnDrop(PointerEventData eventData)
    {
        if (onDrop != null) {
			onDrop (gameObject,eventData.position);
		}
    }
}
