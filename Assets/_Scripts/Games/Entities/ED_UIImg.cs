using UnityEngine;
using System;
using Core;
using UnityEngine.UI;

/// <summary>
/// 类名 : UIImage 数据脚本
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2020-12-18 14:03
/// 功能 : 数据加载逻辑
/// </summary>
public class ED_UIImg : ED_Animator
{
    static public new ED_UIImg Builder(UnityEngine.Object uobj)
    {
        return Builder<ED_UIImg>(uobj);
    }

    static public ED_UIImg Builder(Image image)
    {
        if (image == null || !image)
            return null;
        ED_UIImg _it = Builder(image.gameObject);
        _it.InitComp(image,null,null,null);
        return _it;
    }
    
    public string m_sAtals { get; private set; }
    public string m_sImg { get; private set; }
    public Image m_img { get; private set; }
    public AssetInfo m_asset { get; private set; }
    public bool m_isNativeSize { get; private set; }
    public bool m_isCheckSame = true;

    public ED_UIImg() : base()
    {
    }
    
    override public void InitComp(string strComp,Core.DF_OnInt cfLife)
    {
        base.InitComp(strComp,cfLife);
    }

    override public void InitComp(Component comp,Core.DF_OnInt cfLife)
    {
        base.InitComp(comp,cfLife);
    }
    
    override public void InitComp(Component comp, Action cfDestroy, Action cfShow, Action cfHide)
    {
        base.InitComp(comp, cfDestroy, cfShow, cfHide);
        this.m_img = this.m_comp as Image;
    }

    override protected void On_Destroy(GobjLifeListener obj)
    {
        this.m_img = null;
        this.OnUnLoadAsset();
        this.m_isNativeSize = false;
        base.On_Destroy(obj);
    }

    public void OnUnLoadAsset()
    {
        AssetInfo _asset = this.m_asset;
        this.m_asset = null;
        if(_asset != null)
            _asset.UnloadAsset();
        
        this.m_sAtals = null;
        this.m_sImg = null;
    }

    public string ReAtals(int nType,string sAtals)
    {
        switch (nType)
        {
            case 1:
            sAtals = GameFile.ReSBegEnd( sAtals,"textures/ui_sngs/icons/",".tex" );
            break;
            case 2:
            sAtals = GameFile.ReSBegEnd( sAtals,"textures/ui_sngs/bgs/",".tex" );
            break;
            case 3:
            sAtals = GameFile.ReSBegEnd( sAtals,"textures/ui_sngs/minihead/",".tex" );
            break;
            case 4:
            sAtals = GameFile.ReSBegEnd( sAtals,"textures/ui_sngs/halfbody/",".tex" );
            break;
            case 5:
            sAtals = GameFile.ReSBegEnd( sAtals,"textures/ui_sngs/fullbody/",".tex" );
            break;
            case 6:
            sAtals = GameFile.ReSBegEnd( sAtals,"textures/ui_sngs/",".tex" );
            break;
            default:
            sAtals = GameFile.ReSBegEnd( sAtals,"textures/ui_atlas/",".tex_atlas" );
            break;
        }
        return sAtals;
    }

    public string RePng(string sImg)
    {
        var _arrs = GameFile.Split(sImg,"/".ToCharArray(),true);
        sImg = _arrs[_arrs.Length - 1];
        return GameFile.ReSEnd(sImg,".png");
    }

    public void SetImage(int nType,string sAtals,string sImg,bool isNativeSize,bool isNdReRes = true)
    {
        if(!this.m_img)
        {
            this.SLog("ED_UIImg SetImage","m_img is null",sAtals,sImg);
            return;
        }
            
        this.m_isNativeSize = isNativeSize;
        if(isNdReRes == true)
        {
            sAtals = this.ReAtals(nType,sAtals);
            sImg =  this.RePng(sImg);
        }

        if(m_isCheckSame)
        {
            bool isSameAB = string.Equals(this.m_sAtals,sAtals);
            bool isSameAsset = string.Equals(this.m_sImg,sImg);
            if(isSameAB && isSameAsset)
            {
                this.SLog("ED_UIImg SetImage","Is Same",sAtals,sImg);
                return;
            }
        }
        
        this.OnUnLoadAsset();
        this.m_sAtals = sAtals;
        this.m_sImg = sImg;
        this.SLog("ED_UIImg SetImage","Loading",this.m_sAtals,this.m_sImg);
        this.m_asset = ResourceManager.LoadSprite(sAtals,sImg,_OnLoadSprite);
    }

    void _OnLoadSprite(Sprite sprite)
    {
        if(!this.m_img)
        {
            this.SLog("ED_UIImg _OnLoadSprite","m_img is null",this.m_sAtals,this.m_sImg);
            this.OnUnLoadAsset();
            return;
        }

        if(!sprite)
        {
            if(this.m_asset != null)
                this.SLogError("ED_UIImg _OnLoadSprite","Load Err",this.m_asset.GetAssetBundleInfo(),this.m_asset);
            else
                this.SLogError("ED_UIImg _OnLoadSprite","Load Err",this.m_sAtals,this.m_sImg);
            return;
        }
        
        this.SLog("ED_UIImg _OnLoadSprite",this.m_sAtals,this.m_sImg,sprite);

        this.m_img.sprite = sprite;
        if(this.m_isNativeSize)
            this.SetNativeSize();
    }

    public void SetIcon(string icon,bool isNativeSize)
    {
        this.SetImage( 1,icon,icon,isNativeSize );
    }

    public void SetBg(string icon,bool isNativeSize)
    {
        this.SetImage( 2,icon,icon,isNativeSize );
    }

    public void SetImgHead(string icon,bool isNativeSize)
    {
        this.SetImage( 3,icon,icon,isNativeSize );
    }

    public void SetImgHalfBody(string icon,bool isNativeSize)
    {
        this.SetImage( 4,icon,icon,isNativeSize );
    }

    public void SetImgBody(string icon,bool isNativeSize)
    {
        this.SetImage( 5,icon,icon,isNativeSize );
    }

    public void SetImgSng(string icon,bool isNativeSize)
    {
        this.SetImage( 6,icon,icon,isNativeSize );
    }

    public void SetFillAmount(float val,float max = 0)
    {
        if(!this.m_img)
            return;
        float amount = (max > 0) ? (val / max) : val;
        this.m_img.fillAmount = amount;
    }

    public void VwImgColor(float r, float g, float b, float a = 1)
    {
        if(!this.m_img)
            return;
        this.m_img.color = LuaHelper.ToColor(r, g, b, a);
    }

    public void SetImgType(int type)
    {
        if(!this.m_img)
            return;
        Image.Type itp = (Image.Type) type;
        this.SetImgType(itp);
    }

    public void SetImgType(Image.Type type)
    {
        if(!this.m_img)
            return;
        this.m_img.type = type;
    }

    public void SetImgFillMethod(int fillMethod,int fillOrigin = 0)
    {
        if(!this.m_img)
            return;
        Image.FillMethod ifm = (Image.FillMethod) fillMethod;
        this.SetImgFillMethod(ifm,fillOrigin);
    }

    public void SetImgFillMethod(Image.FillMethod fillMethod,int fillOrigin = 0)
    {
        if(!this.m_img)
            return;
        this.m_img.fillMethod = fillMethod;
        this.m_img.fillOrigin = 0;
    }

    public void SetNativeSize()
    {
        if(!this.m_img)
            return;
        this.m_img.SetNativeSize();
    }

    public void SetNativeSizeASync()
    {
        this.m_isNativeSize = true;
        this.SetNativeSize();
    }
}