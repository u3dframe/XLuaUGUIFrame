using UnityEngine;
using UnityEngine.EventSystems;
using System.Collections;
using System.Collections.Generic;

public delegate void DF_InpKeyState(string key, int state);
public delegate void DF_InpScale(bool isBig, float val);
public delegate void DF_InpVec2(Vector2 val);
public delegate void DF_InpRayHit(Ray ray,RaycastHit hit,int layer);

/// <summary>
/// 类名 : Input 管理脚本
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-07-13 21:29
/// 功能 : 
/// </summary>
public class InputMgr : GobjLifeListener {
	static InputMgr _instance;
	static public InputMgr instance{
		get{
			if (IsNull(_instance)) {
				GameObject _gobj = GameMgr.mgrGobj;
				_instance = UtilityHelper.Get<InputMgr>(_gobj,true);
			}
			return _instance;
		}
	}

#if UNITY_EDITOR
	static private System.Type _tpKeyCode = typeof(KeyCode);
	static private Dictionary<KeyCode, DF_InpKeyState> m_diCalls;
	static private void OnUpdate()
	{
		if (m_diCalls == null || m_diCalls.Count <= 0)
			return;
		var e = m_diCalls.GetEnumerator();
		while (e.MoveNext())
		{
			var current = e.Current;
			if (Input.GetKeyDown(current.Key))
			{
				// 按键按下的第一帧返回true
				current.Value(current.Key.ToString(), 1);
			}
			else if (Input.GetKeyUp(current.Key))
			{
				// 按键松开的第一帧返回true
				current.Value(current.Key.ToString(), 2);
			}
			else if (Input.GetKey(current.Key))
			{
				// 按键按下期间返回true
				current.Value(current.Key.ToString(), 3);
			}
		}
	}

	static private void RegKeyCode(string key, DF_InpKeyState callBack,bool isAppend)
	{
		if (m_diCalls == null) m_diCalls = new Dictionary<KeyCode, DF_InpKeyState>();

		KeyCode _code = EnumEx.Str2Enum<KeyCode>(_tpKeyCode,key);
		DF_InpKeyState _val;
		if (m_diCalls.ContainsKey(_code)) {
			if(isAppend){
				_val = m_diCalls[_code] + callBack;
				m_diCalls[_code] = _val;
			}
		}else{
			m_diCalls.Add(_code, callBack);
		}
	}
#endif

	static public void RegKeyCode(string key, DF_InpKeyState callBack){
#if UNITY_EDITOR
		RegKeyCode(key,callBack,false);
#endif
	}
	
	private EventSystem _currEvt;
	// 单击到了UI上面
	public bool IsClickInUI{
		get{
			_currEvt = EventSystem.current;
			if(_currEvt == null) return false;
			if(Input.touchCount > 0) return _currEvt.IsPointerOverGameObject(Input.GetTouch(0).fingerId);
			return _currEvt.IsPointerOverGameObject();
		}
	}
	
    public bool m_isRunning = true;
	public int m_nCanRay = 0;
	public float m_minScaleDis = 5;
	public float m_minSlideDis = 5;
	public DF_InpScale m_lfScale = null; // 缩放
	public DF_InpVec2 m_lfRotate = null; // 旋转
	public DF_InpVec2 m_lfSlide = null; // 滑动
	public DF_InpRayHit m_lfRayHit = null; // 单击到物体
	
	bool m_isRay = false;
	float m_rayDisctance = Mathf.Infinity;
	Ray _ray;
	LayerMask _lay_mask = 1 << 0 | 1 << 1 | 1 << 4;
	
	float maxDistance = 0;
	bool isSingleFinger = false;
	int count = 0;
	Touch _t1,_t2;
	bool _isSlide = false;
	bool _isClick = false;
	Vector2 _v2T1,_v2T2;
	float _f1,_f2,_f3;
	
	protected override void OnCall4Awake(){
		this.maxDistance = Screen.height > Screen.width ? Screen.height : Screen.width;
		this.csAlias = "InpMgr";
	}
	protected override void OnClear() {
#if UNITY_EDITOR
		if(m_diCalls != null) m_diCalls.Clear();
#endif
		m_lfScale = null;
		m_lfRotate = null;
		m_lfSlide = null;
		m_lfRayHit = null;
	}
	
    void Update () {
#if UNITY_EDITOR
		OnUpdate();
#endif
        if ( !m_isRunning )
            return;
		
		if ( !IsClickInUI ){
            return;
		}
		
		if(Input.touchSupported){
			_OnUpdateTouch();
		}else{
			_OnUpdateMouse();
		}
    }
	
	void FixedUpdate()
    {
		if(this.m_isRay){
			this.m_isRay = false;
			RaycastHit hit;
			if(Physics.Raycast(_ray,out hit,this.m_rayDisctance,_lay_mask)){
				// 返回第一个被碰撞到的对象
				_ExcLFRayHit(_ray,hit,hit.transform.gameObject.layer);
			}
		}
	}
	
	public void Init(){}
	
	public void SetLayerMask(LayerMask lmask){
		this._lay_mask = lmask;
	}

	LayerMask GetLayerMask(params string[] layerNames){
		return LayerMask.GetMask(layerNames);
	}
	public void SetLayerMaskBy(string nmLayer){
		SetLayerMask(GetLayerMask(nmLayer));
	}

	public void SetLayerMaskBy(string nmLayer,string nmLayer2){
		SetLayerMask(GetLayerMask(nmLayer,nmLayer2));
	}

	public void SetLayerMaskBy(string nmLayer,string nmLayer2,string nmLayer3){
		SetLayerMask(GetLayerMask(nmLayer,nmLayer2,nmLayer3));
	}

	public void SetLayerMaskBy(string nmLayer,string nmLayer2,string nmLayer3,string nmLayer4){
		SetLayerMask(GetLayerMask(nmLayer,nmLayer2,nmLayer3,nmLayer4));
	}

	public void SetLayerMaskBy(string nmLayer,string nmLayer2,string nmLayer3,string nmLayer4,string nmLayer5){
		SetLayerMask(GetLayerMask(nmLayer,nmLayer2,nmLayer3,nmLayer4,nmLayer5));
	}

	public void SetLayerMaskBy(string nmLayer,string nmLayer2,string nmLayer3,string nmLayer4,string nmLayer5,string nmLayer6){
		SetLayerMask(GetLayerMask(nmLayer,nmLayer2,nmLayer3,nmLayer4,nmLayer5,nmLayer6));
	}

	public void SetLayerMaskMore(params string[] layerNames){
		SetLayerMask(GetLayerMask(layerNames));
	}

	void _ExcLFScroll(bool isBig,float val){
		if(m_lfScale != null){
			m_lfScale(isBig,val);
		}
	}
	
	void _ExcLFRotate(Vector2 val){
		if(m_lfRotate != null){
			m_lfRotate(val);
		}
	}
	
	void _ExcLFSlide(Vector2 val){
		if(m_lfSlide != null){
			m_lfSlide(val);
		}
	}
	
	void _ExcLFRayHit(Ray ray,RaycastHit hit,int hitLayer){
		if(m_lfRayHit != null){
			m_lfRayHit(ray,hit,hitLayer);
		}
	}
	
	void _JugdeClick(Vector2 newPos){
		if((!isSingleFinger) || (!_isClick && !_isSlide))
			return;
						
		_v2T2 = newPos - _v2T1;
		_isSlide = (_v2T2.sqrMagnitude >= (m_minSlideDis * m_minSlideDis));
		_isClick = !_isSlide;
		
		if(_isSlide) {
			_isSlide = false;
			// left = 0, right = 1, up = 2, down = 3;
			// if (Mathf.Abs(_v2T2.y) <= Mathf.Abs(_v2T2.x)) {
			// 	_userInput = _v2T2.x < 0 ? 0 : 1;
			// } else {
			// 	_userInput = _v2T2.y > 0 ? 2 : 3;
			// }
			_ExcLFSlide(_v2T2);
		} else if (_isClick) {
			_isClick = false;
			if(m_nCanRay > 0){
				m_nCanRay--;
				return;
			}
			_ray = Camera.main.ScreenPointToRay(newPos);
			m_isRay = true;
		}
	}
	
	void _OnUpdateTouch(){
		count = Input.touchCount;
		if(count <= 0) return;
		_t1 = Input.GetTouch(0);
		switch(count){
			case 1:
				isSingleFinger = true;
				switch (_t1.phase)
				{
					case TouchPhase.Began:
						_isClick = true;
						_isSlide = true;
						_v2T1 = _t1.position;
						break;
					case TouchPhase.Canceled:
						_isClick = false;
						_isSlide = false;
						break;
					case TouchPhase.Moved:
						_isClick = false;
						_isSlide = true;
						break;
					case TouchPhase.Ended:
						_JugdeClick(_t1.position);
						break;
				}
			break;
			case 2:
				_isClick = false;
				_isSlide = false;
				_t2 = Input.GetTouch(0);
				if ((isSingleFinger) || (_t1.phase == TouchPhase.Began || _t2.phase == TouchPhase.Began)){
					_v2T1 = _t1.position;
					_v2T2 = _t2.position;
					isSingleFinger = false;
				}
				if (_t1.phase == TouchPhase.Ended || _t2.phase == TouchPhase.Ended){
					_v2T1 = _v2T2 - _v2T1;
					_v2T2 = _t2.position - _t1.position;
					_f1 = _v2T1.sqrMagnitude;
					_f2 = _v2T2.sqrMagnitude;
					_f3 = (_f2 - _f1);
					_v2T1 = _v2T2 - _v2T1;
					_f2 = m_minScaleDis * m_minScaleDis;
					if(_f3 >= _f2){
						// 变大了
						_f1 = (_v2T1.magnitude / this.maxDistance);
						_ExcLFScroll(true,_f1);
					}else if(_f3 < -1 * _f2){
						// 缩小了
						_f1 = (_v2T1.magnitude / this.maxDistance);
						_ExcLFScroll(false,_f1);
					}else{
						// 旋转角度差值 _v2T1
						_ExcLFRotate(_v2T1);
					}
					_v2T1 = _t1.position;
					_v2T2 = _t2.position;
				}
			break;
		}
	}
	
	void _OnUpdateMouse(){
		if (Input.GetMouseButtonDown(0)){
			_isClick = true;
			_isSlide = true;
			isSingleFinger = true;
			_v2T1 = Input.mousePosition;
		}

		if (Input.GetMouseButtonDown(1) || Input.GetMouseButtonDown(2)){
			isSingleFinger = false;
			_isClick = false;
			_isSlide = false;
		}
		
		if(_isSlide && Input.GetMouseButton(0)){
			_isClick = false;
		}
		
		if(Input.GetMouseButtonUp(0)){
			_JugdeClick(Input.mousePosition);
		}
	}
}