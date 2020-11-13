using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Launcher : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        InitPars();
        Entry();
    }

    void InitPars(){
        GHelper.Is_App_Quit = false;
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
        Application.targetFrameRate = 60;
        Application.runInBackground = true;
    }

    void Entry(){
        GameMgr.instance.InitAll();
        LuaManager.instance.Init();
    }
}
