using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Launcher : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GHelper.Is_App_Quit = false;
        GameMgr.instance.Init();
    }
}
