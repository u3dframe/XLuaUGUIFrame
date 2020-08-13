using UnityEngine;

/// <summary>
/// 类名 : 屏幕坐标射线对象
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-07-13 21:29
/// 功能 : 
/// </summary>
public class RayScreenPointInfo{
	// public long m_cursor = 0;
	public Vector2 m_pos = Vector2.zero;
	public LayerMask m_layMask = 0;
	public DF_InpRayHit m_call;
	public float m_rayDisctance = Mathf.Infinity;
	public bool m_isAllHit = false;
	
	public void ExcRayHit(Ray ray,RaycastHit hit){
		if(m_call != null){
			int hitLayer = hit.transform.gameObject.layer;
			m_call(ray,hit,hitLayer);
		}
		m_call = null;
	}

	public void Clear(){
		m_pos.x = 0;
		m_pos.y = 0;
		m_layMask = 0;
		m_rayDisctance = Mathf.Infinity;
		m_isAllHit = false;
		m_call = null;
	}
}