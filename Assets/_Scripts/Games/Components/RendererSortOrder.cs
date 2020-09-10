using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 类名 : Render 渲染 排序控制
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-09-10 19:33
/// 功能 : 
/// </summary>
public class RendererSortOrder : MonoBehaviour
{
    public bool m_isUseSLayer = false;
    public string m_nmLayer = "Default";
    bool m_isNameInSLayer = true;

    public bool m_isAddValue = true;
    public int m_value = 0;

    Renderer[] renderers;
    void Start()
    {
        renderers = this.GetComponentsInChildren<Renderer>(true);
        ReRenderSorting();
    }

    void _CheckSortName(){
        this.m_isNameInSLayer = false;
        if(string.IsNullOrEmpty(this.m_nmLayer)){
            return;
        }
        SortingLayer[] _layers = SortingLayer.layers;
        int lens = _layers.Length;
        SortingLayer _sLayer;
        for (int i = 0; i < lens; i++)
        {
            _sLayer = _layers[i];
            if(_sLayer.name.Equals(this.m_nmLayer)){
                this.m_isNameInSLayer = true;
                return;
            }
        }
    }

    public void ReRenderSorting(){
        if(renderers == null || renderers.Length <= 0)
            return;
        
        _CheckSortName();

        int lens = renderers.Length;
        Renderer _rer_;
        for (int i = 0; i < lens; i++)
        {
            _rer_ = renderers[i];
            if(m_isUseSLayer && m_isNameInSLayer){
                _rer_.sortingLayerName = this.m_nmLayer;
            }

            if(m_isAddValue){
                _rer_.AddSortingOrder(this.m_value);
            }else{
                _rer_.ReSortingOrder(this.m_value);
            }
        }
    }
}
