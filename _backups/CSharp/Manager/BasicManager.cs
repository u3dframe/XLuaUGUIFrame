using UnityEngine;
/// <summary>
/// 类名 : Basic Manager - 管理父类
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2019-03-18 09:15
/// 功能 : 
/// 描述 : 
/// </summary>
namespace Core.Kernel
{
    public class BasicManager<T> : SingtonBasics<T> where T : BasicManager<T>
    {

        static public T BasicInitInstance(string gobjName)
        {
            T _ret = InitInstance(gobjName);
            _ret.OnInitInstance();
            return _ret;
        }

        static public T BasicInitInstance()
        {
            return BasicInitInstance("BasicManager");
        }

        /// <summary>
        /// 实例化的时候，进行初始化
        /// </summary>
        protected virtual void OnInitInstance()
        {
        }
    }
}