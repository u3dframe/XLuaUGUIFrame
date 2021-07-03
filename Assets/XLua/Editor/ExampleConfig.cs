/*
 * Tencent is pleased to support the open source community by making xLua available.
 * Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

using System.Collections.Generic;
using System;
using UnityEngine;
using XLua;
using Core;
using Core.Kernel;
using Core.Kernel.Beans;
#if UNITY_2019
using UnityEngine.Networking;
using UnityEngine.Rendering.PostProcessing;
#endif
using UnityEngine.UI;
using UnityEngine.EventSystems;

using System.Reflection;
using System.Linq;

//配置的详细介绍请看Doc下《XLua的配置.doc》
public static class ExampleConfig
{
     //lua中要使用到C#库的配置，比如C#标准库，或者Unity API，第三方库等。
    [LuaCallCSharp]
    public static List<Type> LuaCallCSharp = new List<Type>() {
                typeof(System.Object),
                typeof(UnityEngine.Object),
                typeof(Vector2),
                typeof(Vector3),
                typeof(Vector4),
                typeof(Quaternion),
                typeof(Color),
                typeof(Ray),
                typeof(Bounds),
                typeof(Ray2D),
                typeof(Time),
                typeof(GameObject),
                typeof(Component),
                typeof(Behaviour),
                typeof(Transform),
                typeof(UnityEngine.Resources),
                typeof(TextAsset),
                typeof(Keyframe),
                typeof(AnimationCurve),
                typeof(AnimationClip),
                typeof(MonoBehaviour),
                typeof(ParticleSystem),
                typeof(SkinnedMeshRenderer),
                typeof(Renderer),
                // typeof(WWW),
                typeof(Light),
                typeof(Mathf),
                typeof(System.Collections.Generic.List<int>),
                typeof(Action<string>),
                typeof(UnityEngine.Debug),

                //------------------------ u3d --------------------------------
                // typeof(string[]),
                typeof(PlayerPrefs),
                typeof(Animation),
                typeof(Animator),
                typeof(AnimatorStateInfo),
                typeof(Camera),
                typeof(RenderSettings),
                typeof(LightmapSettings),
                typeof(WaitForSeconds),
                typeof(UnityWebRequest),
                typeof(DownloadHandler),
                typeof(DownloadHandlerBuffer),
                typeof(CertificateHandler),
                typeof(AudioClip),
                typeof(AudioSource),
                typeof(LayerMask),
                typeof(RaycastHit),
                typeof(PostProcessLayer),
                typeof(Application),
                typeof(Screen),
                typeof(CharacterController),
                typeof(Skybox),
                typeof(Shader),
                typeof(Material),
                //------------------------ ugui --------------------------------
                typeof(RectTransform),
                typeof(UIBehaviour),
                typeof(Graphic),
                typeof(MaskableGraphic),
                typeof(Text),
                typeof(Image),
                typeof(Scrollbar),
                typeof(ScrollRect),
                // typeof(Image.Type), // 枚举不用到wrap文件
                typeof(Toggle),
                typeof(Slider),
                typeof(CanvasGroup),
                //typeof(Slider.SliderEvent),
                typeof(UnityEngine.Events.UnityEventBase),
                typeof(RawImage),
                typeof(InputField),
                typeof(EventTrigger), // UGUIEventListener 的 父类
                //------------------------ 类1 ---------------------
                typeof(LoopListView3),
                typeof(GuideController),
                typeof(Conversation),
                typeof(TMPro.TMP_InputField),
                //------------------------ 类2 ---------------------
#if USE_DOTWEEN
                typeof(DG.Tweening.AutoPlay),
                typeof(DG.Tweening.AxisConstraint),
                typeof(DG.Tweening.Ease),
                typeof(DG.Tweening.LogBehaviour),
                typeof(DG.Tweening.LoopType),
                typeof(DG.Tweening.PathMode),
                typeof(DG.Tweening.PathType),
                typeof(DG.Tweening.RotateMode),
                typeof(DG.Tweening.ScrambleMode),
                typeof(DG.Tweening.TweenType),
                typeof(DG.Tweening.UpdateType),

                typeof(DG.Tweening.DOTween),
                typeof(DG.Tweening.DOVirtual),
                typeof(DG.Tweening.EaseFactory),
                typeof(DG.Tweening.Tweener),
                typeof(DG.Tweening.Tween),
                typeof(DG.Tweening.Sequence),
                typeof(DG.Tweening.TweenParams),
                typeof(DG.Tweening.Core.ABSSequentiable),

                typeof(DG.Tweening.Core.TweenerCore<Vector3, Vector3, DG.Tweening.Plugins.Options.VectorOptions>),

                typeof(DG.Tweening.TweenCallback),
                typeof(DG.Tweening.TweenExtensions),
                typeof(DG.Tweening.TweenSettingsExtensions),
                typeof(DG.Tweening.ShortcutExtensions),
            
                //dotween pro 的功能
                // typeof(DG.Tweening.DOTweenAnimation),
                // typeof(DG.Tweening.DOTweenPath),
                // typeof(DG.Tweening.DOTweenVisualManager),
#endif
                //------------------------ 类3 ---------------------
                typeof(UnityStandardAssets.ImageEffects.PostEffectsBase),
                typeof(UnityStandardAssets.ImageEffects.GlobalFog),
                //------------------------ 类4 ---------------------
                typeof(ED_Basic),
                typeof(EU_Basic),
                typeof(ED_Comp),
                typeof(ED_UIImg),
                typeof(ED_UIItem),
                typeof(ED_Camera),
                typeof(ED_UIEffect),
                typeof(ED_UISpine),
                typeof(CanvasEx),
                typeof(MemDisplay),
                typeof(TimelineUtil),
                typeof(CardUtil),
                typeof(EU_Bridge),
                typeof(ObjEx),
                typeof(StrEx),
                typeof(PathEx),
                typeof(FileEx),
                typeof(ReadWriteHelper),
                typeof(UGameRes),
                typeof(UGameFile),
                typeof(Core.Kernel.Resources),
                typeof(GameFile),
                typeof(TNet.ByteBuffer),
                typeof(GobjLifeListener),
                typeof(GameMgr),
                typeof(TNet.NetworkManager),
                typeof(WWWMgr),
                typeof(GameLanguage),
                typeof(GHelper),
                typeof(UtilityHelper),
                typeof(LuaHelper),
                typeof(UGUICanvasAdaptive),
                typeof(UGUIEventListener),
                typeof(UGUIEventSystem),
                typeof(PrefabBasic),
                typeof(PrefabElement),
                typeof(VideoEx),
                typeof(Localization),
                typeof(UGUILocalize),
                typeof(UGUIGray),
                typeof(UGUIButton),
                typeof(UGUIModel),
                typeof(AssetBase),
                typeof(AssetInfo),
                typeof(ABInfo),
                // typeof(AssetBundleManager),
                typeof(ResourceManager),
                typeof(MgrLoadScene),
                // typeof(MgrDownload),
                typeof(LuaManager),
                typeof(SmoothLookAt),
                typeof(SmoothFollower),
                typeof(CtrlCamera),
                typeof(MainCameraManager),
                typeof(RayScreenPointInfo),
                typeof(InputBaseMgr),
                typeof(InputMgr),
                typeof(AnimatorEx),                
                typeof(CharacterControllerEx),
                typeof(RendererMatData),
                typeof(RendererSortOrder),
                typeof(ParticleEvent),
                typeof(ParticleSystemEx),
                typeof(RendererMatProperty),
                typeof(CurveBase),
                typeof(CurveEx),
                typeof(LogToNetHelper),
                typeof(CfgVersion),
                typeof(RenderSettingsEx),
                typeof(WebVerifyCert),
                typeof(SceneMapEx),
                typeof(CRCClass),
                typeof(CoatingLight),
                //------------------------ ljson ---------------------
                typeof(LitJson.JsonData),
                typeof(LJsonHelper),
                //---------------------------------------------------------------  
            };

    //C#静态调用Lua的配置（包括事件的原型），仅可以配delegate，interface
    [CSharpCallLua]
    public static List<Type> CSharpCallLua = new List<Type>() {
                typeof(Action),
                typeof(Func<double, double, double>),
                typeof(Action<int>),
                typeof(Action<string>),
                typeof(Action<double>),
                typeof(Action<float>),
                typeof(UnityEngine.Events.UnityAction),
                typeof(System.Collections.IEnumerator),
              
                typeof(DF_UWR),

                typeof(LoopListView3.DF_GetItemName),
                typeof(LoopListView3.DF_OnItemCreated),
                typeof(LoopListView3.DF_SetItemData),
                typeof(LoopListView3.DF_OnIndexChanged),
                typeof(LoopListView3.DF_OnValueChanged),

                typeof(DF_LoadedAsset),
                typeof(DF_LoadedFab),
                typeof(DF_LoadedTex2D),
                typeof(DF_ToLoadTex2D),
                typeof(DF_LoadedCube),
                typeof(DF_ToLoadCube),
                typeof(DF_LoadedSprite),
                typeof(DF_LoadedAnimator),
                typeof(DF_LoadedAnimationClip),
                typeof(DF_LoadedAdoClip),
                typeof(DF_ToLoadAdoClip),
                typeof(DF_LoadedTimelineAsset),
                typeof(DF_LoadedMaterial),
                typeof(DF_LoadedPPFile),
                typeof(DF_OnBool),
                typeof(DF_OnInt),
                typeof(DF_OnStr),
                typeof(DF_OnUpdate),
                typeof(DF_OnSceneChange),
                typeof(DF_OnNotifyDestry),

                typeof(DF_UGUIPos),
                typeof(DF_UGUI2V2),
                typeof(DF_UGUIV2Bool),

                typeof(DF_InpKeyState),
                typeof(DF_InpScale),
                typeof(DF_InpVec2),
                typeof(DF_InpRayHit),

                typeof(DF_ElementForeach),

                typeof(DF_ASM_MotionLife),
                typeof(DF_ASM_SubLife),
            };

    //黑名单
    [BlackList]
    public static List<List<string>> BlackList = new List<List<string>>()  {
                new List<string>(){"System.Xml.XmlNodeList", "ItemOf"},
                new List<string>(){"UnityEngine.WWW", "movie"},
    #if UNITY_WEBGL
                new List<string>(){"UnityEngine.WWW", "threadPriority"},
    #endif
                new List<string>(){"UnityEngine.Texture2D", "alphaIsTransparency"},
                new List<string>(){"UnityEngine.Security", "GetChainOfTrustValue"},
                new List<string>(){"UnityEngine.CanvasRenderer", "onRequestRebuild"},
                new List<string>(){"UnityEngine.Light", "areaSize"},
                new List<string>(){"UnityEngine.Light", "lightmapBakeType"},
                new List<string>(){"UnityEngine.Light", "SetLightDirty"},
                new List<string>(){"UnityEngine.Light", "shadowRadius"},
                new List<string>(){"UnityEngine.Light", "shadowAngle"},
                new List<string>(){"UnityEngine.UI.Graphic", "OnRebuildRequested"},
                new List<string>(){"UnityEngine.UI.Text", "OnRebuildRequested"},
                new List<string>(){"UnityEngine.WWW", "MovieTexture"},
                new List<string>(){"UnityEngine.WWW", "GetMovieTexture"},
                new List<string>(){"UnityEngine.AnimatorOverrideController", "PerformOverrideClipListCleanup"},
    #if !UNITY_WEBPLAYER
                new List<string>(){"UnityEngine.Application", "ExternalEval"},
    #endif
                new List<string>(){"UnityEngine.GameObject", "networkView"}, //4.6.2 not support
                new List<string>(){"UnityEngine.Component", "networkView"},  //4.6.2 not support
                new List<string>(){"System.IO.FileInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections"},
                new List<string>(){"System.IO.FileInfo", "SetAccessControl", "System.Security.AccessControl.FileSecurity"},
                new List<string>(){"System.IO.DirectoryInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections"},
                new List<string>(){"System.IO.DirectoryInfo", "SetAccessControl", "System.Security.AccessControl.DirectorySecurity"},
                new List<string>(){"System.IO.DirectoryInfo", "CreateSubdirectory", "System.String", "System.Security.AccessControl.DirectorySecurity"},
                new List<string>(){"System.IO.DirectoryInfo", "Create", "System.Security.AccessControl.DirectorySecurity"},
                new List<string>(){"UnityEngine.MonoBehaviour", "runInEditMode"},

                new List<string>(){ "Core.Kernel.Resources", "Path2AssetsStart","System.String"},
                new List<string>(){ "Core.Kernel.Resources", "GetPath","UnityEngine.Object"},
                new List<string>(){ "Core.Kernel.Resources", "GetObject","System.String","System.String"},
                new List<string>(){ "Core.Kernel.Resources", "LoadInEditor","System.String","System.String"},
                // new List<string>(){ "PrefabElement", "SetChildGobjs","UnityEngine.GameObject[]"},
                new List<string>(){ "Core.GameFile", "CreateFab","UnityEngine.GameObject","System.String","System.Boolean"},
                new List<string>(){ "Core.GameFile", "m_url_editor"},
            };
    
#if UNITY_2018_1_OR_NEWER
    [BlackList]
    public static Func<MemberInfo, bool> MethodFilter = (memberInfo) =>
    {
        if (memberInfo.DeclaringType.IsGenericType && memberInfo.DeclaringType.GetGenericTypeDefinition() == typeof(Dictionary<,>))
        {
            if (memberInfo.MemberType == MemberTypes.Constructor)
            {
                ConstructorInfo constructorInfo = memberInfo as ConstructorInfo;
                var parameterInfos = constructorInfo.GetParameters();
                if (parameterInfos.Length > 0)
                {
                    if (typeof(System.Collections.IEnumerable).IsAssignableFrom(parameterInfos[0].ParameterType))
                    {
                        return true;
                    }
                }
            }
            else if (memberInfo.MemberType == MemberTypes.Method)
            {
                var methodInfo = memberInfo as MethodInfo;
                if (methodInfo.Name == "TryAdd" || methodInfo.Name == "Remove" && methodInfo.GetParameters().Length == 2)
                {
                    return true;
                }
            }
        }
        return false;
    };
#endif
}
