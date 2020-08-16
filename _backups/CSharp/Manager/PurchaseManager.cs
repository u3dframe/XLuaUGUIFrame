using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
using System.IO;
// using PlayerPrefs = PreviewLabs.PlayerPrefs;

/// <summary>
/// 类名 : Purchase Manager 支付管理
/// 作者 : Canyon / 龚阳辉
/// 日期 : 2019-03-16 13:15
/// 功能 : 
/// 描述 : 
/// </summary>
public class PurchaseManager<T> : BasicManager<T> where T : PurchaseManager<T> {
	/// <summary>
	/// 支付回调
	/// </summary>
	/// bool - true:成功,false:失败
	/// 第1个string - itemid
	/// 第2个string - 参数:失败时为原因 code,成功时返回 receipt 或者其他
	static protected System.Action<bool,string,string> _callPay;
	
	// 购买完成返回 - 为 Unibiller 插件函数
	// static protected System.Action<string,string,string> _callPayCompleted;

	static protected string user_id {
		get{ return JinxServiceFactory.SharedJinxServiceFactory().GetJinxUserInfoService().GetJinxUserId(); } 
	}
	
	static protected long sv_ms {
		get{ return JinxServerTimeServiceImpl.SharedJinxServerTimeService.GetCurSvTimebyms(); } 
	}

	static protected string _id_ms{
        get
        {
            return (string.Format("{0}_{1}", user_id, sv_ms));
        }
	}

	static public T InitInstance(string gobjName,System.Action<bool,string,string> callFunc)
    {
		_callPay = callFunc;
        return BasicInitInstance(gobjName);;
    }

	static public T InitInstance(System.Action<bool,string,string> callFunc){
		return InitInstance ("SDKPurchase", callFunc);
	}
	
	static protected void ExcuteCall(bool isSuccess,string itemid,string msg) {
		try {
			if(!"-999".Equals(msg)){
				BuyRecordsOpt.instance.RemoveBy(itemid);
			}
			
			if(_callPay != null){
				_callPay(isSuccess,itemid,msg);
			}
			
			if(isSuccess){
				int price = JinxBillingService.SharedJinxBillingService.GetPriceForServicePay(itemid);
                int TotalChongzhi = JinxServiceFactory.SharedJinxServiceFactory().GetJinxUserInfoService().GetUserChongzhi();
                if (TotalChongzhi == 0)
                {
                    SDKADJust.SharedInstance.LogEvent("wyo548");
                }

                updataTotleChongzhiForAdjust( TotalChongzhi + price, TotalChongzhi);
                JinxServiceFactory.SharedJinxServiceFactory().GetJinxUserInfoService().SaveUserMoney(price);
                
            
            }
		} catch(System.Exception ex){
			Debug.LogError("= ExcuteCall =" + ex);
		}
	}
		
	static public IEnumerator validPayCoroutine(string _receipt, string _itemId,string _transactionId) {
          BuyRecordsOpt.instance.NewRecord(_itemId,_transactionId,_receipt);
        string paymentType = "sungame";
#if UNITY_IOS
		paymentType= "IOS";
#elif GGPlay
		paymentType= "GGPLAY";
#endif
        FlurryStatisticsGame.RecordOnChargeRequest(_transactionId, GetGoodNameByGoodCode(_itemId), (Double)(GetLocalPriceByGoodCode(_itemId)), GetIsoCurrencyByGoodCode(_itemId), 0, paymentType);
#if UNITY_IOS
		yield return _validPayIOS(_receipt,_itemId,_transactionId);
#elif GGPlay
		yield return _validPayGGPlay(_receipt,_itemId,_transactionId);
#endif
        yield return null;
	}

	static IEnumerator _validPayIOS(string _receipt, string _itemId,string _transactionId) {
		//苹果服务器验证地址https://buy.itunes.apple.com/verifyReceipt
		//苹果服务器沙箱验证地址https://sandbox.itunes.apple.com/verifyReceipt
		// string josnstring = string.Concat("{\"receipt-data\":\"",_receipt,"\"}");
		// Debug.LogFormat("== validIOS json == [{0}]",josnstring);
		WWWForm post = new WWWForm();
		post.AddField("receipt", SecretKeyFactory.DESEnCode(_receipt));
		post.AddField("item_id", _itemId);
		post.AddField("transaction_id", _transactionId);
		string times_ms = sv_ms.ToString();
        post.AddField("time_ms", times_ms);
		WWW www = new WWW(EncryptServiceImpl.sharedInstance.urlValidationIp, post);
		yield return www;
		if (!string.IsNullOrEmpty (www.error)) {
			// Debug.Log ("== validation error ==" + www.error);
			ExcuteCall(false,_itemId,"-999");
		} else {
			string strVal = www.text;
			// Debug.LogFormat ("== valid IOS == [{0}]", strVal);
			if ("-1".Equals (strVal) || "-2".Equals (strVal) || "-3".Equals (strVal)) {
				ExcuteCall(false,_itemId,"-2");
			} else {
				LitJson.JsonData jsonData = null;
				try {
					jsonData = LitJson.JsonMapper.ToObject (strVal);
				} catch {
				}

				if (jsonData == null || jsonData ["status"] == null) {
					ExcuteCall(false,_itemId,"-3");
				} else {
					string status = jsonData ["status"].ToString ();
					bool _vSuccess = "0".Equals (status);
                    if (_vSuccess)
                    {
                        FlurryStatisticsGame.RecordOnChargeSuccess(_transactionId);
                    }
                    ExcuteCall(_vSuccess,_itemId,_vSuccess ? _receipt : "-4");
                    
				}
			}
		}
		www.Dispose ();
		www = null;
	}
	
	// 验证 ggplay 充值
	static IEnumerator _validPayGGPlay(string _receipt, string _itemId,string _transactionId) {
		string times_ms = sv_ms.ToString();
		string _user_id = user_id;
		WWWForm post = new WWWForm();
		post.AddField("cmd", "10002");
		post.AddField("user_id", _user_id);
		post.AddField("receipt", SecretKeyFactory.DESEnCode(_receipt));
		post.AddField("item_id", _itemId);
		post.AddField("transaction_id", _transactionId);
		post.AddField("pay_platform", "ggplay_pay");
        post.AddField("time_ms", times_ms);
		WWW www = new WWW(EncryptServiceImpl.sharedInstance.urlJinxGame, post);
		yield return www;
		if (!string.IsNullOrEmpty (www.error)) {
			ExcuteCall(false,_itemId,"-999");
		} else {
			string strVal = www.text;
			// Debug.LogFormat ("== valid ggplay == [{0}]", strVal);
			if ("-1".Equals (strVal) || "-2".Equals (strVal) || "-3".Equals (strVal)) {
				ExcuteCall(false,_itemId,"-2");
			} else {
				LitJson.JsonData jsonData = null;
				try {
					jsonData = LitJson.JsonMapper.ToObject (strVal);
				} catch {
				}
				if (jsonData == null || jsonData ["status"] == null) {
					ExcuteCall(false,_itemId,"-3");
				} else {
					string status = jsonData ["status"].ToString ();
					bool _vSuccess = "0".Equals (status); 
					ExcuteCall(_vSuccess,_itemId,_vSuccess ? _receipt : "-4");
				}
			}
		}
		www.Dispose ();
		www = null;
	}

	static public IEnumerator dayNumInMonth(System.Action<string> callBack) {
		WWWForm post = new WWWForm();
		post.AddField("cmd", "10001");
		string times_ms = sv_ms.ToString();
        post.AddField("time_ms", times_ms);
		WWW www = new WWW(EncryptServiceImpl.sharedInstance.urlJinxGame, post);
		yield return www;
		string _str = "0";
		if (string.IsNullOrEmpty (www.error)) {
			_str = www.text;
		}
		
		if (callBack != null){
			callBack (_str);
		}
		
		www.Dispose ();
		www = null;
	}

	// 如果是月份，day就传0
	static public IEnumerator validRenewal(string _user_id, string _itemId,int _day,System.Action<string,string> callBack) {
		string _platform = "";
#if UNITY_IOS
		_platform = "ios"; // 验证 ios 订阅续费
#elif GGPlay
		_platform = "ggplay_renewal"; // 验证 ggplay 订阅续费
#endif
		if(string.IsNullOrEmpty(_platform)){
			if (callBack != null)
				callBack ("-99",_itemId);
			yield break;
		}

		string times_ms = sv_ms.ToString();
		WWWForm post = new WWWForm();
		post.AddField("cmd", "10002");
		post.AddField("user_id", _user_id);
		post.AddField("item_id", _itemId);
		post.AddField("day", _day);
		post.AddField("pay_platform", _platform);
        post.AddField("time_ms", times_ms);
		WWW www = new WWW(EncryptServiceImpl.sharedInstance.urlJinxGame, post);
		yield return www;
		if (!string.IsNullOrEmpty (www.error)) {
			if (callBack != null)
				callBack ("-99",_itemId);
		} else {
			if (callBack != null)
				callBack (www.text,_itemId);
		}
		www.Dispose ();
		www = null;
	}

	static public LocDBFeeCharging GetFee(string goodsType){ 
		return LocDBFeeChargingOpt.instance.getFee (goodsType);
	}

    static public LocDBFeeCharging GetFeeByGoodCode(string GoodCode)
    {
        return LocDBFeeChargingOpt.instance.getFeeByGoodsCode(GoodCode);
    }

    static public string GetGoodNameByGoodCode(string GoodCode, string defVal = "unknow")
    {
        LocDBFeeCharging fee = GetFeeByGoodCode(GoodCode);
        if (fee == null)
            return defVal;

        string _str = fee.goodsName;
        return _str;
    }

        // 购买
        static public void DoPurchase(string goodsType){
		LocDBFeeCharging fee = GetFee (goodsType);
		string _itemId = goodsType;
		if(_initInstace){
			if (fee != null) {
				shareInstance.Purchase (fee.goodsCode);
				return;
			}
		}
		
		ExcuteCall(false,_itemId,"-100");
	}
	
	// 续订验证
	static public void DoValidRenewal(string _user_id, string _itemId,int _day,System.Action<string,string> callBack) {
		shareInstance.StartCoroutine(validRenewal(_user_id,_itemId,_day,callBack));
	}

	// GetLocalizedPriceString
	static public string GetLocalPriceStr(string goodsType,string defVal = "0")
	{
		LocDBFeeCharging fee = GetFee (goodsType);
		if (fee == null)
			return defVal;

		string _str = shareInstance.LocalPriceStr (fee.goodsCode);

		#if GGPlay
		if(string.IsNullOrEmpty(_str) || "0".Equals(_str))
		{
			return JinxServiceFactory.SharedJinxServiceFactory().GetJinxGameDataService().GetLanguage("GGplay_no_login_price_tips");
		}
		#endif

		return _str;
	}
	
	static public decimal GetLocalPrice(string goodsType,decimal defVal = 0m){
		string _str = GetLocalPriceStr(goodsType);
		if(string.IsNullOrEmpty(_str) || "0".Equals(_str)){
			return defVal;
		}
		decimal.TryParse(_str,out defVal);
		return defVal;
	}
	
	static public decimal GetLocalPrice2(string goodsType,decimal defVal = 0m){
		LocDBFeeCharging fee = GetFee (goodsType);
		if (fee == null)
			return defVal;

		decimal _ret = shareInstance.LocalPrice2 (fee.goodsCode);
		if(_ret <= -1)
			return defVal;
		return _ret;
	}

    static public decimal GetLocalPriceByGoodCode(string GoodCode, decimal defVal = 0m)
    {
     
        decimal _ret = shareInstance.LocalPrice2(GoodCode);
        if (_ret <= -1)
            return defVal;
        return _ret;
    }

    static public string GetIsoCurrency(string goodsType, string defVal = "0")
	{
		LocDBFeeCharging fee = GetFee(goodsType);
		if(fee == null)
			return defVal;
		
		string _str = shareInstance.IsoCurrency (fee.goodsCode);
		if(string.IsNullOrEmpty(_str)){
			return defVal;
		}
		return _str;
	}

    static public string GetIsoCurrencyByGoodCode(string GoodCode, string defVal = "0")
    {
      

        string _str = shareInstance.IsoCurrency(GoodCode);
        if (string.IsNullOrEmpty(_str))
        {
            return defVal;
        }
        return _str;
    }

    protected void ExcValidPay(string itemid,string tid,string receipt) {
		StartCoroutine (validPayCoroutine (receipt, itemid, tid));
	}
	
	protected virtual void Purchase(string itemid){
	}

	protected virtual string LocalPriceStr(string itemid){
		return "";
	}
	
	protected virtual decimal LocalPrice2(string itemid){
		return 0m;
	}
	
	protected virtual string IsoCurrency(string itemid){
		return "";
	}


     static void updataTotleChongzhiForAdjust(int NowTotleChongzhi, int BeforeChongzhi)
    {
        if (NowTotleChongzhi >= 5 && BeforeChongzhi < 5)
        {
            SDKADJust.SharedInstance.LogEvent("ikd11f");
        }

        if (NowTotleChongzhi >= 10 && BeforeChongzhi < 10)
        {
            SDKADJust.SharedInstance.LogEvent("eoff3u");
        }

        if (NowTotleChongzhi >= 50 && BeforeChongzhi < 50)
        {
            SDKADJust.SharedInstance.LogEvent("1m0p9b");
        }

        if (NowTotleChongzhi >= 100 && BeforeChongzhi < 100)
        {
            SDKADJust.SharedInstance.LogEvent("bb1nib");
        }

        if (NowTotleChongzhi >= 500 && BeforeChongzhi < 500)
        {
            SDKADJust.SharedInstance.LogEvent("m1vroy");
        }

        if (NowTotleChongzhi >= 1000 && BeforeChongzhi < 1000)
        {
            SDKADJust.SharedInstance.LogEvent("gyy9lz");
        }
    }
}
