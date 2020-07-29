/// <summary>
/// 类名 : Updateable 可更新实体类 - 父类
/// 作者 : Canyon
/// 日期 : 2020-06-27 20:37
/// 功能 : 
/// </summary>
public class Updateable : IUpdate {
	public bool m_isOnUpdate = true;
	public bool IsOnUpdate(){ return this.m_isOnUpdate;} 
    public virtual void OnUpdate(float dt,float unscaledDt) {}
}
