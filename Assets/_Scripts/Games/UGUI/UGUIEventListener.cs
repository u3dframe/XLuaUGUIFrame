using UnityEngine;
using UnityEngine.UI;
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

	static public float maxDistance = 70f;
	
	[HideInInspector] public DF_UGUIV2Bool onMouseEnter;

	[HideInInspector] public DF_UGUIPos onClick;
	
	[HideInInspector] public DF_UGUIPos onBegDrag;
	
	[HideInInspector] public DF_UGUI2V2 onDraging;
	
	[HideInInspector] public DF_UGUIPos onEndDrag;
	
	[HideInInspector] public DF_UGUIPos onDrop;

	[HideInInspector] public DF_UGUIV2Bool onPress;

	
	bool _isPressed = false,_isCanClick = false;

	float press_time = 0,diff_time = 0,dis_curr = 0,
	limit_time = 0.2f,limit_dis_min = 0.1f * 0.1f,limit_dis_max = 0;

	private Vector2 v2Start;
	ScrollRect _sclParent = null;

	ScrollRect GetScrollInParent(Transform trsf)
    {
		if(trsf == null) return null;
		ScrollRect ret = trsf.GetComponent<ScrollRect> ();
		if (ret != null) return ret;
		return GetScrollInParent(trsf.parent);
    }

	ScrollRect GetScrollInParent(GameObject gobj)
    {
		if(gobj == null) return null;
		return GetScrollInParent(gobj.transform);
    }
	
	void Awake(){
		this.limit_dis_max = maxDistance * maxDistance;
		_sclParent = GetScrollInParent(transform);
	}

	void OnDisable()
    {
		if (_isPressed && onPress != null) {
			onPress (gameObject, false, transform.position);
		}
        _isPressed = false;
    }

    void OnEnable()
    {
		_isPressed = false;
		press_time = 0;
		diff_time = 0;
		v2Start = Vector2.zero;
    }

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
		_isPressed = true;
		press_time = Time.realtimeSinceStartup;
		v2Start = eventData.position;
		if(_sclParent != null){
			_sclParent.OnBeginDrag(eventData);
		}
		if (onPress != null) {
			onPress (gameObject, _isPressed, eventData.position);
		}
	}

	// 抬起
	public override void OnPointerUp (PointerEventData eventData){
		_isPressed = false;
		if (press_time > 0) {
			diff_time = Time.realtimeSinceStartup - press_time;
			press_time = 0;
		}

		if(_sclParent != null){
			_sclParent.OnEndDrag(eventData);
		}

		if (onPress != null) {
			onPress (gameObject, _isPressed, eventData.position);
		}
	}

	// 单击
	public override void OnPointerClick (PointerEventData eventData){
		if (press_time > 0) {
			diff_time = Time.realtimeSinceStartup - press_time;
			press_time = 0;
		}
	
		dis_curr = (eventData.position - v2Start).sqrMagnitude;
		_isCanClick = dis_curr <= limit_dis_min;
		if (!_isCanClick) {
			_isCanClick = dis_curr <= limit_dis_max && diff_time <= limit_time;
		}
		
		if (!_isCanClick) return;
		v2Start = eventData.position;
		diff_time = 0;
		if (onClick != null) {
			onClick (gameObject, eventData.position);
		}
	}
	
    // 开始拖拽
    public override void OnBeginDrag(PointerEventData eventData)
    {
		if(_sclParent != null){
			_sclParent.OnBeginDrag(eventData);
		}
        if (onBegDrag != null) {
			onBegDrag (gameObject, eventData.position);
		}
    }
	
	// 推拽中
	public override void OnDrag (PointerEventData eventData){
		if(_sclParent != null){
			_sclParent.OnDrag(eventData);
		}
		if (onDraging != null) {
			onDraging (gameObject, eventData.position,eventData.delta);
		}
	}
	
	// 结束拖拽
    public override void OnEndDrag(PointerEventData eventData)
    {
		if(_sclParent != null){
			_sclParent.OnEndDrag(eventData);
		}
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
