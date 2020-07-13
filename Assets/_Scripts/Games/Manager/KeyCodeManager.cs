using System;
using UnityEngine;
using System.Collections.Generic;
public delegate void DF_KeyState(string key, int state);

#if UNITY_EDITOR
public class KeyCodeManager
{

	static Dictionary<KeyCode, DF_KeyState> m_diCalls;

	static public void RegKeyCode(string key, DF_KeyState callBack)
	{
		if (m_diCalls == null)
			m_diCalls = new Dictionary<KeyCode, DF_KeyState>();
		KeyCode code = (KeyCode)Enum.Parse(typeof(KeyCode), key);
		if (!m_diCalls.ContainsKey(code))
		{
			m_diCalls.Add(code, callBack);
		}
	}

	static public void OnUpdate(float dt)
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
}
#endif