using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestCControllerEx : MonoBehaviour
{
    public CharacterControllerEx m_c;
    public float m_mv_speed = 1.5f;

    public RendererMatProperty m_rmp;
    public float m_alpha = 1;
    MaterialPropertyBlock m_mpb;

    // Start is called before the first frame update
    void Start()
    {
        if(!m_c){
            m_c = this.gameObject.GetComponent<CharacterControllerEx>();
        }
        m_mpb = new MaterialPropertyBlock();
        m_rmp = RendererMatProperty.Get(this.gameObject);
    }

    // Update is called once per frame
    void Update()
    {
        _OnUpdateMouse();
    }

    void _OnUpdateMouse(){
		if(Input.GetKey(KeyCode.UpArrow)){
            m_c.SetAction(2);
            Vector3 pos2 = Vector3.down * m_mv_speed * Time.deltaTime;
            m_c.Move(pos2.x,0,pos2.y);
		}

        if(Input.GetKey(KeyCode.DownArrow)){
            m_c.SetAction(2);
            Vector3 pos2 = Vector3.up * m_mv_speed * Time.deltaTime;
            m_c.Move(pos2.x,0,pos2.y);
		}

        if(Input.GetKey(KeyCode.LeftArrow)){
            m_c.SetAction(2);
            Vector3 pos2 = Vector3.right * m_mv_speed * Time.deltaTime;
            m_c.Move(pos2.x,0,pos2.y);
		}

        if(Input.GetKey(KeyCode.RightArrow)){
            m_c.SetAction(2);
            Vector3 pos2 = Vector3.left * m_mv_speed * Time.deltaTime;
            m_c.Move(pos2.x,0,pos2.y);
		}
		
		if(Input.GetKeyUp(KeyCode.UpArrow) || Input.GetKeyUp(KeyCode.DownArrow) || Input.GetKeyUp(KeyCode.LeftArrow) || Input.GetKeyUp(KeyCode.RightArrow)){
			m_c.SetAction(0);
		}

        if(Input.GetKeyUp(KeyCode.Keypad0)){
            m_rmp.SetColor("_Color",1,1,1,this.m_alpha);
        }

        if(Input.GetKeyUp(KeyCode.Keypad1)){
            m_rmp.SetColor("_Color2",1,1,1,this.m_alpha);
        }

        if(Input.GetKeyUp(KeyCode.Keypad2)){
            m_rmp.SetFloat("_Alpha",this.m_alpha);
        }

        if(Input.GetKeyUp(KeyCode.Keypad3)){
            foreach (var item in m_rmp.m_renderers)
            {
                item.ReAlpha(this.m_alpha);
            }
        }

        if(Input.GetKeyUp(KeyCode.Keypad4)){
            foreach (var item in m_rmp.m_renderers)
            {
                item.GetPropertyBlock(m_mpb);
                m_mpb.SetColor("_Color2", new Color(1,1,1,m_alpha));
                item.SetPropertyBlock(m_mpb);
            }
        }

        if(Input.GetKeyUp(KeyCode.Keypad5)){
            foreach (var item in m_rmp.m_renderers)
            {
                item.GetPropertyBlock(m_mpb);
                m_mpb.SetColor("_Color", new Color(1,1,1,m_alpha));
                item.SetPropertyBlock(m_mpb);
            }
        }

        if(Input.GetKeyUp(KeyCode.Keypad6)){
            m_rmp.SetInt("_CCType",0);
        }

        if(Input.GetKeyUp(KeyCode.Keypad7)){
            m_rmp.SetInt("_CCType",1);
        }

        if(Input.GetKeyUp(KeyCode.Keypad8)){
            var gobj = GameMgr.instance.m_gobj;
            Core.GameFile.bLoadOrg4Editor = false;
            System.Type tp = null;
            Core.AssetBundleManager.instance.LoadAB("shaders/posteffect/bloom/mobilebloom.ab_shader",(obj) => {
                Core.ABInfo aInfo = obj as Core.ABInfo;
                string[] anames = aInfo.m_ab.GetAllAssetNames();
                Debug.Log("=============================1 = " + Time.time);
                string fname = null;
                foreach (string item in anames)
                {
                    fname = Core.GameFile.GetFileName(item);
                    Debug.LogFormat("==== name ===[{0}] = [{1}]",item,fname);
                    Core.AssetInfo asInfo = aInfo.GetAssetAndCount(item,tp);
                    asInfo.m_onLoadedAsset = (_obj)=>{
                        Debug.LogError(asInfo);
                    };
                    asInfo.StartUpdate();
                }
                // aInfo.m_ab.LoadAllAssetsAsync();
                Debug.Log("=============================2");
            });
        }
	}
}
