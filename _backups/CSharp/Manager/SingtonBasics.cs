using UnityEngine;

/// <summary>
/// 类名 : mono 单例对象
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2018-09-21 10:15
/// 功能 : 
/// 描述 : MonoBehaviour 生命周期可以抽出一个父对象
/// </summary>
namespace Core.Kernel
{
    public class SingtonBasics<T> : MonoBehaviour where T : MonoBehaviour
    {
        static protected object _lock = new object();
        static protected string NM_Gobj = "SingtonBasics";
        static private T _shareT;
        static public T shareInstance
        {
            get
            {
                lock (_lock)
                {
                    if (_shareT == null)
                    {
                        GameObject gobj = GameObject.Find(NM_Gobj);
                        if (!gobj)
                        {
                            gobj = new GameObject(NM_Gobj, typeof(T));
                        }
                        _shareT = gobj.GetComponent<T>();
                        if (_shareT == null)
                        {
                            _shareT = gobj.AddComponent<T>();
                        }
                        GameObject.DontDestroyOnLoad(gobj);
                    }
                    return _shareT;
                }
            }
        }

        static public T sharedInstance { get { return shareInstance; } }

        static protected bool _initInstace = false;

        static public T InitInstance(string gobjName)
        {
            bool _isEmt = string.IsNullOrEmpty(gobjName);
            if (!_isEmt)
                NM_Gobj = gobjName;

            T _ret = shareInstance;
            if (!_isEmt)
            {
                GameObject gobj = _ret.gameObject;
                if (!gobj.name.Equals(gobjName))
                    gobj.name = gobjName;
            }

            _initInstace = true;
            return _ret;
        }

        static public T InitInstance()
        {
            return InitInstance(null);
        }

        protected bool _isAppQuit = false;

        void OnApplicationQuit(){
            this._isAppQuit = true;
        }

        void OnDestroy(){
            if (this._isAppQuit) {
                return;
            }
            _shareT = null;
            CFOnDestroy();
        }

        protected virtual void CFOnDestroy(){}
    }
}