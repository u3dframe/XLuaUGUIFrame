using System.Collections;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using Core;
using Core.Kernel;

public class Launcher : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GameFile.InitFirst();
#if Use_Zipper
        StartCoroutine(InitData(Entry));
#else
        _StartUpdateProcess();
#endif
    }

    void _StartUpdateProcess()
    {
        bool isUnZip = !GameFile.isEditor;
        bool isValidVer = !GameFile.isEditor;
        isValidVer = false;
        UpdateProcess updateProcess = new UpdateProcess().Init(Entry, _OnCallState, null,isUnZip, isValidVer);
        updateProcess.Start();
    }

#if Use_Zipper
    static IEnumerator InitBaseFolder(string zip, string tgtDir)
    {
        if (!Directory.Exists(tgtDir))
            Directory.CreateDirectory(tgtDir);

        using (var req = UnityWebRequest.Get(zip))
        {
            yield return req.SendWebRequest();
            SharpZipLib.Zipper.DeCompress(req.downloadHandler.data, tgtDir);
        }
    }

    IEnumerator InitData(System.Action cfEnd)
    {
#if !UNITY_EDITOR
        var inited = Path.Combine(Application.persistentDataPath, "__inited");
        if (!File.Exists(inited))
        {
            var zip = Path.Combine(Application.streamingAssetsPath,"base.zip");
            var disDir = Path.Combine(Application.persistentDataPath, "_resRoot");
            yield return InitBaseFolder(zip, disDir);
            var stream = File.Open(inited, FileMode.CreateNew);
            var d = System.Text.Encoding.UTF8.GetBytes(System.DateTime.Now.ToString());
            stream.Write(d,0,d.Length);
            stream.Close();
        }
#endif
        if (cfEnd != null)
        {
            cfEnd();
        }
        yield break;
    }
#endif

    void Entry()
    {
        InputMgr.instance.Init();
        AssetBundleManager.instance.isDebug = true;
        LuaManager.instance.Init();
    }

    void _OnCallState(int state)
    {
        EM_Process emp = (EM_Process)state;
        Debug.LogFormat("=== state = [{0}] , [{1}] ", state, emp);
    }
}
