using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public delegate void DF_UGUIPos(GameObject gameObject,Vector2 pos);
public delegate void DF_UGUI2V2(GameObject gameObject,Vector2 pos,Vector2 delta);
public delegate void DF_UGUIV2Bool(GameObject gameObject,bool isBl,Vector2 pos);

/// <summary>
/// 类名 : UGUIEventListener
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-08 16:37
/// 功能 : 处理UGUI界面上事件
/// </summary>
public class UGUIEventListener : EventTrigger {
	static public UGUIEventListener Get(GameObject gobj,bool isAdd){
		return UtilityHelper.Get<UGUIEventListener>(gobj,isAdd);
	}

	static public UGUIEventListener Get(GameObject gobj){
		return Get(gobj,true);
	}

	[HideInInspector] public DF_UGUIV2Bool onMouseEnter;

	[HideInInspector] public DF_UGUIPos onClick;
	
	[HideInInspector] public DF_UGUIPos onBegDrag;
	
	[HideInInspector] public DF_UGUI2V2 onDraging;
	
	[HideInInspector] public DF_UGUIPos onEndDrag;
	
	[HideInInspector] public DF_UGUIPos onDrop;

	[HideInInspector] public DF_UGUIV2Bool onPress;

	// 移入
	public override void OnPointerEnter (PointerEventData eventData){
		if (onMouseEnter != null) {
			onMouseEnter (gameObject,true,eventData.position);
		}
	}

	// 移出
	public override void OnPointerExit (PointerEventData eventData){
		if (onMouseEnter != null) {
			onMouseEnter (gameObject,false, eventData.position);
		}
	}

	// 按下
	public override void OnPointerDown (PointerEventData eventData){
		if (onPress != null) {
			onPress (gameObject, true, eventData.position);
		}
	}

	// 抬起
	public override void OnPointerUp (PointerEventData eventData){
		if (onPress != null) {
			onPress (gameObject, false, eventData.position);
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
