using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Core;

public class AudioManager : MonoBehaviour {
	public AudioSource m_bgAudio;
	public AudioSource m_uiAudio;
	[Range(0f,1f)] public float bgSceneVolume = 1; // 场景背景音乐大小
	[Range(0f,1f)] public float bgUIVolume = 1; // UI背景音乐大小
	[Range(0f,1f)] protected float soundVolume = 0.1f; // 短声音的大小
	
	Dictionary<string,AssetInfo> m_clips = new Dictionary<string,AssetInfo>();
}


