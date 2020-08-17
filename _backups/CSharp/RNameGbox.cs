using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

[ExecuteInEditMode]
public class RNameGbox : MonoBehaviour
{
    [ContextMenu("Excute_Rnamebox")]
    void Excute_Rnamebox()
    {
        List<Transform> list = new List<Transform>();
        int len = this.transform.childCount;
        Transform _it;
        for (int i = 0; i < len; i++)
        {
            _it = this.transform.GetChild(i);
            list.Add(_it);
        }

        list.Sort((x,y) =>{
            if(x.position.x < y.position.x) return -1;
            else if(x.position.x > y.position.x) return 1;
            float d = x.position.x - y.position.x;
            if(d < 0.1){
                if(x.position.z < y.position.z) return 1;
                else if(x.position.z > y.position.z) return -1;
            }
            return 0;
        });

        for (int i = 0; i < len; i++)
        {
            _it = list[i];
            _it.SetSiblingIndex(i);
            _it.name = (i+1).ToString();
        }
    }

}
