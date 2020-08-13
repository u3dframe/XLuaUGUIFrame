using UnityEngine;
using System.Collections;
using UnityEngine.Networking;

namespace Core.Kernel
{
	/// <summary>
	/// 类名 : ut-unity 资源下载管理
	/// 作者 : Canyon
	/// 日期 : 2017-05-17 15:03
	/// 功能 : 2020-02-03 19:21 加入 UnityWebRequest 来替换 www 请求
	/// </summary>
	public class WWWMgr : MonoBehaviour
	{
		static WWWMgr _instance;
		static public WWWMgr instance{
			get{
				if (_instance == null) {
					GameObject _gobj = GameMgr.mgrGobj;
					_instance = _gobj.GetComponent<WWWMgr>();
					if (_instance == null)
					{
						_instance = _gobj.AddComponent<WWWMgr> ();
					}
				}
				return _instance;
			}
		}

#if !UNITY_2019
		IEnumerator wwwCoroutine(string url,System.Action<WWW,object> callSuccess,System.Action<WWW,object> callFail, object extPars){
			WWW www  = new WWW(url);
			yield return wwwCoroutine (www, callSuccess, callFail, extPars);
		}

		IEnumerator wwwCoroutine(string url,WWWForm form, System.Action<WWW,object> callSuccess,System.Action<WWW,object> callFail, object extPars){
			WWW www  = new WWW(url,form);
			yield return wwwCoroutine (www, callSuccess, callFail, extPars);
		}

		IEnumerator wwwCoroutine(WWW www, System.Action<WWW,object> callSuccess,System.Action<WWW,object> callFail, object extPars){
			yield return www;
         //  Debug.Log("www==" + www.text);
         //  Debug.Log("www.error==" + www.error);
            if (!string.IsNullOrEmpty(www.error)){
                //FlurryStatisticsGame.Guide_LoginError(0, "login", www.error);
				if(callFail != null)
					callFail(www,extPars);
			}else{
				if(callSuccess != null)
					callSuccess(www,extPars);
			}
			www.Dispose ();
			www = null;
		}

		public void StartWww(string url,System.Action<WWW,object> callSuccess,System.Action<WWW,object> callFail, object extPars = null){
			StartCoroutine(wwwCoroutine(url,callSuccess,callFail,extPars));
		}

		public void StartWwwPost(string url,WWWForm form, System.Action<WWW,object> callSuccess,System.Action<WWW,object> callFail, object extPars = null){
			StartCoroutine(wwwCoroutine(url,form,callSuccess,callFail,extPars));
		}
#else
		IEnumerator Get(string url,System.Action<UnityWebRequest,object> callSuccess,System.Action<UnityWebRequest,object> callFails,object pars = null){
			if (string.IsNullOrEmpty(url)) {
				yield break;
			}
			using (UnityWebRequest request = UnityWebRequest.Get(url)) {
				yield return UWRCoroutine(request,callSuccess,callFails,pars);
			}
		}

		IEnumerator PostForm(string url, WWWForm form,System.Action<UnityWebRequest,object> callSuccess,System.Action<UnityWebRequest,object> callFails,object pars = null){
			if (string.IsNullOrEmpty(url)) {
				yield break;
			}
			
			using (UnityWebRequest request = UnityWebRequest.Post(url, form)) {
				yield return UWRCoroutine(request,callSuccess,callFails,pars);
			}
		}

		private IEnumerator UWRCoroutine(UnityWebRequest request,System.Action<UnityWebRequest,object> callSuccess,System.Action<UnityWebRequest,object> callFails,object pars = null){
			//设置超时 链接超时返回 且isNetworkError为true
			request.timeout = 59;
			yield return request.SendWebRequest();
			//结果回传给具体实现
			if (request.isHttpError || request.isNetworkError) {
				if (callFails != null) {
					callFails(request,pars);
				}
			} else {
				// request.downloadHandler
				if (callSuccess != null) {
					callSuccess(request,pars);
				}
			}
		}

		public void StartUWR(string url,System.Action<UnityWebRequest,object> callSuccess,System.Action<UnityWebRequest,object> callFail, object extPars = null){
			StartCoroutine(Get(url,callSuccess,callFail,extPars));
		}

		public void StartUWRPost(string url,WWWForm form, System.Action<UnityWebRequest,object> callSuccess,System.Action<UnityWebRequest,object> callFail, object extPars = null){
			StartCoroutine(PostForm(url,form,callSuccess,callFail,extPars));
		}
#endif
	}
}