using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


[CustomEditor(typeof(CombineMesh))]
public class CombineMeshEditor:Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        CombineMesh combineMesh = (CombineMesh)target;
        if (GUILayout.Button("合并网格"))
        {
            combineMesh.Combine();
        }
    }
}

public class CombineMesh : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {

    }

    public string SavePath = "Assets/";
    public void Combine()
    {
        MeshFilter[] meshFilters = GetComponentsInChildren<MeshFilter>();
        CombineInstance[] combineInstances = new CombineInstance[meshFilters.Length];
        for (int i = 0; i < meshFilters.Length; i++)
        {
            combineInstances[i].mesh = meshFilters[i].sharedMesh;
            combineInstances[i].transform = meshFilters[i].transform.localToWorldMatrix;
        }
        Mesh mesh = new Mesh();
        mesh.name = gameObject.name;
        mesh.CombineMeshes(combineInstances);

        AssetDatabase.CreateAsset(mesh, SavePath + mesh.name + ".asset");
        AssetDatabase.SaveAssets();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
