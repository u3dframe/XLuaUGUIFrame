using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenCaptureEx : MonoBehaviour
{
    public string CaptureScreenName = "截图";
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.F12))
        {
            CaptureScreen();
        }
    }


    /// <summary>
    /// 截取全屏的方法包括UI
    /// </summary>
    public void CaptureScreen()
    {
        ScreenCapture.CaptureScreenshot(CaptureScreenName + ".png");
        Debug.Log(1);
    }

}
