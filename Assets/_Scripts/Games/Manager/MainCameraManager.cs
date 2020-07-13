using UnityEngine;
using System.Collections;

/// <summary>
/// 类名 : 主摄像机管理脚本
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-07-12 20:29
/// 功能 : 
/// </summary>
public class MainCameraManager : MonoBehaviour
{
	// 取得对象
	static public MainCameraManager Get(GameObject gobj,bool isAdd){
		MainCameraManager _r = gobj.GetComponent<MainCameraManager> ();
		if (isAdd && UtilityHelper.IsNull(_r)) {
			_r = gobj.AddComponent<MainCameraManager> ();
		}
		return _r;
	}

	static public MainCameraManager Get(GameObject gobj){
		return Get(gobj,true);
	}
	
    public Transform m_target;
	public Camera m_camera;
	public SmoothFollower m_follower { get;private set; }
	
	void Awake(){
		GameObject.DontDestroyOnLoad(this.gameObject);
		if(m_camera){
			m_follower = SmoothFollower.Get(m_camera.gameObject);
			m_follower.target = m_target;
			m_follower.isUpByLate = true;
		}
	}
}
