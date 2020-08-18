using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

/// <summary>
/// 类名 : 烘培光照贴图 的 自定义Inspector界面
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2017-03-21 10:37
/// 功能 : 自定义Inspector界面
/// </summary>
[CustomEditor(typeof(LightMapEx))]
public class LightMapExInspector : Editor
{
    LightMapEx m_obj;

    //序列化对象
	SerializedObject m_serializedObject;

    //序列化属性
    SerializedProperty m_propertyList;

    void OnEnable()
    {
        m_obj = target as LightMapEx;

        m_serializedObject = new SerializedObject(this);
        m_propertyList = m_serializedObject.FindProperty("m_renderInfos");
    }
	
    public override void OnInspectorGUI()
    {
        base.DrawDefaultInspector();
        // _OnGUI_List();
    }

    protected void _OnGUI_List()
    {
        //更新
        m_serializedObject.Update();

        //开始检查是否有修改
        EditorGUI.BeginChangeCheck();
        //显示属性
        //第二个参数必须为true，否则无法显示子节点即List内容
        EditorGUILayout.PropertyField(m_propertyList, true);

        //结束检查是否有修改
        if (EditorGUI.EndChangeCheck())
        {
            //提交修改
            m_serializedObject.ApplyModifiedProperties();
        }
    }
}
