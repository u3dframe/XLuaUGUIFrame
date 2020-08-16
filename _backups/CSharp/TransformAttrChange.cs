using UnityEngine;

/// <summary>
/// 类名 : Transform/RectTransform 属性变化记录
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-06-26 09:33
/// 功能 : 大部分处理这下是放在Update里面，避免更新太多先赋值最后放入到LateUpdate里面进行更新
/// postion,localpostion,localScale,eulerAngles,localEulerAngles,forward,right,up
/// anchoredPosition3D,anchoredPosition,pivot,sizeDelta
/// </summary>
public class TransformAttrChange {
    public Vector3 v3Attr = Vector3.zero;
    public bool isChanged = false;
    
    public void SetValByV3(Vector3 v3)
    {
        SetValue(v3.x,v3.y,v3.z);
    }

     public void SetValue(float x,float y,float z)
    {
        this.v3Attr.x = x;
        this.v3Attr.y = y;
        this.v3Attr.z = z;
        this.isChanged = true;
    }
}
