using UnityEngine;

namespace SuperScrollView
{

    public class LoopListViewItem2 : MonoBehaviour
    {
        int muuid = -1;
        int mItemIndex = -1;
        int mItemId = -1;
        LoopListView2 mParentListView = null;
        bool mIsInitHandlerCalled = false;
        string mItemPrefabName;
        RectTransform mCachedRectTransform;
        float mPadding;
        float mDistanceWithViewPortSnapCenter = 0;
        int mItemCreatedCheckFrameCount = 0;
        float mStartPosOffset = 0;

        object mUserObjectData = null;
        int mUserIntData1 = 0;
        int mUserIntData2 = 0;
        string mUserStringData1 = null;
        string mUserStringData2 = null;

        public object UserObjectData
        {
            get { return mUserObjectData; }
            set { mUserObjectData = value; }
        }
        public int UserIntData1
        {
            get { return mUserIntData1; }
            set { mUserIntData1 = value; }
        }
        public int UserIntData2
        {
            get { return mUserIntData2; }
            set { mUserIntData2 = value; }
        }
        public string UserStringData1
        {
            get { return mUserStringData1; }
            set { mUserStringData1 = value; }
        }
        public string UserStringData2
        {
            get { return mUserStringData2; }
            set { mUserStringData2 = value; }
        }

        public float DistanceWithViewPortSnapCenter
        {
            get { return mDistanceWithViewPortSnapCenter; }
            set { mDistanceWithViewPortSnapCenter = value; }
        }

        public float StartPosOffset
        {
            get { return mStartPosOffset; }
            set { mStartPosOffset = value; }
        }

        public int ItemCreatedCheckFrameCount
        {
            get { return mItemCreatedCheckFrameCount; }
            set { mItemCreatedCheckFrameCount = value; }
        }

        public float Padding
        {
            get { return mPadding; }
            set { mPadding = value; }
        }

        public int UUID
        {
            get { return muuid; }
            set { muuid = value; }
        }


        public RectTransform CachedRectTransform
        {
            get
            {
                if (mCachedRectTransform == null)
                {
                    mCachedRectTransform = gameObject.GetComponent<RectTransform>();
                }
                return mCachedRectTransform;
            }
        }

        public string ItemPrefabName
        {
            get
            {
                return mItemPrefabName;
            }
            set
            {
                mItemPrefabName = value;
            }
        }

        public int ItemIndex
        {
            get
            {
                return mItemIndex;
            }
            set
            {
                mItemIndex = value;
            }
        }
        public int ItemId
        {
            get
            {
                return mItemId;
            }
            set
            {
                mItemId = value;
            }
        }


        public bool IsInitHandlerCalled
        {
            get
            {
                return mIsInitHandlerCalled;
            }
            set
            {
                mIsInitHandlerCalled = value;
            }
        }

        public LoopListView2 ParentListView
        {
            get
            {
                return mParentListView;
            }
            set
            {
                mParentListView = value;
            }
        }

        public float TopY
        {
            get
            {
                ListItemArrangeType arrageType = ParentListView.ArrangeType;
                if (arrageType == ListItemArrangeType.TopToBottom)
                {
                    return CachedRectTransform.localPosition.y;
                }
                else if(arrageType == ListItemArrangeType.BottomToTop)
                {
                    return CachedRectTransform.localPosition.y + CachedRectTransform.rect.height;
                }
                return 0;
            }
        }

        public float BottomY
        {
            get
            {
                ListItemArrangeType arrageType = ParentListView.ArrangeType;
                if (arrageType == ListItemArrangeType.TopToBottom)
                {
                    return CachedRectTransform.localPosition.y - CachedRectTransform.rect.height;
                }
                else if (arrageType == ListItemArrangeType.BottomToTop)
                {
                    return CachedRectTransform.localPosition.y;
                }
                return 0;
            }
        }


        public float LeftX
        {
            get
            {
                ListItemArrangeType arrageType = ParentListView.ArrangeType;
                if (arrageType == ListItemArrangeType.LeftToRight)
                {
                    return CachedRectTransform.localPosition.x;
                }
                else if (arrageType == ListItemArrangeType.RightToLeft)
                {
                    return CachedRectTransform.localPosition.x - CachedRectTransform.rect.width;
                }
                return 0;
            }
        }

        public float RightX
        {
            get
            {
                ListItemArrangeType arrageType = ParentListView.ArrangeType;
                if (arrageType == ListItemArrangeType.LeftToRight)
                {
                    return CachedRectTransform.localPosition.x + CachedRectTransform.rect.width;
                }
                else if (arrageType == ListItemArrangeType.RightToLeft)
                {
                    return CachedRectTransform.localPosition.x;
                }
                return 0;
            }
        }

        public float ItemSize
        {
            get
            {
                if (ParentListView.IsVertList)
                {
                    return  CachedRectTransform.rect.height;
                }
                else
                {
                    return CachedRectTransform.rect.width;
                }
            }
        }

        public float ItemSizeWithPadding
        {
            get
            {
                return ItemSize + mPadding;
            }
        }

        DF_OnUpItem m_onClickNotify = null;
        public void SetClickEvent(DF_OnUpItem callback)
        {
            this.m_onClickNotify = callback;
            ClickEventListener listener = ClickEventListener.Get(this.gameObject);
            listener.SetClickEventHandler(_ExcuteClick);
        }
        void _ExcuteClick(GameObject gobj){
            if(m_onClickNotify != null)
                m_onClickNotify( UUID,ItemIndex );
        }

        public float m_divisor = 0f; // 被除数 为 0 时就默认 = ItemSizeWithPadding
        public Transform m_trsfScale = null;

        public bool m_isScale = true;
        public float m_minScale = 0.8f; // 缩放最小值
        [Range(0.1f,1f)] public float m_maxScale = 1f; // 缩放最大值

        public bool m_isAlpha = true;
        [Range(0f,1f)] public float m_minAlpha = 0.1f; // 透明最大值
        [Range(0f,1f)] public float m_maxAlpha = 1.0f; // 透明最大值

        CanvasGroup _cavGrp = null;
        public CanvasGroup m_cavGroup {
            get{
                if(_cavGrp == null){
                    _cavGrp = this.gameObject.GetComponent<CanvasGroup>();
                    if(_cavGrp == null){
                        _cavGrp = this.gameObject.AddComponent<CanvasGroup>();
                    }
                }
                return _cavGrp;
            }
        }

        public bool m_isInMiddle{get; private set;} // 判断是否在中间位置

        public void UpdateAlphaScale()
        {
            if(!m_isScale && !m_isAlpha)
                return;

            if(m_divisor == 0)
                m_divisor = this.ItemSizeWithPadding;

            if(m_divisor < 0)
                return;
            
            float quotient = 1 - Mathf.Abs(this.DistanceWithViewPortSnapCenter) / m_divisor;
            float _min,_max;
            if(m_isAlpha && m_minAlpha >= 0 && m_maxAlpha > 0){
                _min = Mathf.Min(m_minAlpha,m_maxAlpha);
                _max = (_min == m_minAlpha) ? m_maxAlpha : m_minAlpha;
                float alpha = Mathf.Clamp(quotient,_min,_max);
                this.m_cavGroup.alpha = alpha;
                this.m_isInMiddle = (alpha > _min) && (_max - alpha) <= 0.03f;
            }

            if(m_isScale && m_minScale >= 0 && m_maxScale > 0){
                Transform _trsf = this.m_trsfScale;
                if(_trsf == null)
                    _trsf = this.CachedRectTransform;
                
                _min = Mathf.Min(m_minScale,m_maxScale);
                _max = (_min == m_minScale) ? m_maxScale : m_minScale;
                float scale = Mathf.Clamp(quotient,_min,_max);
                _trsf.localScale = new Vector3(scale, scale, 1);
                this.m_isInMiddle = (scale > _min) && (_max - scale) <= 0.03f;
            }
        }

    }
}
