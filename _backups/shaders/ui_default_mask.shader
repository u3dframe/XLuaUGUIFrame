// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// canyon / 龚阳辉 2018-00-30 20:09

Shader "Custom/ui_default_multifunctional"
{
	Properties  
    {  
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}  
        _Color ("Tint", Color) = (1,1,1,1)  
          
        _StencilComp ("Stencil Comparison", Float) = 8  
        _Stencil ("Stencil ID", Float) = 0  
        _StencilOp ("Stencil Operation", Float) = 0  
        _StencilWriteMask ("Stencil Write Mask", Float) = 255  
        _StencilReadMask ("Stencil Read Mask", Float) = 255  
  
        _ColorMask ("Color Mask", Float) = 15
		
		[Toggle(UI_CLIP_ON)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }  
  
    SubShader  
    {  
        Tags  
        {   
            "Queue"="Transparent"   
            "IgnoreProjector"="True"   
            "RenderType"="Transparent"   
            "PreviewType"="Plane"  
            "CanUseSpriteAtlas"="True"  
        }  
          
        Stencil  
        {  
            Ref [_Stencil]  
            Comp [_StencilComp]  
            Pass [_StencilOp]   
            ReadMask [_StencilReadMask]  
            WriteMask [_StencilWriteMask]  
        }  
  
        Cull Off  
        Lighting Off  
        ZWrite Off  
        ZTest [unity_GUIZTestMode]  
        Fog { Mode Off } 
        // Blend One OneMinusSrcAlpha
		Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]  
  
        Pass  
        {  
        CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag 
			// ------ add by canyon -----
			#pragma multi_compile UI_MASK_OFF UI_MASK_ON UI_MASK_OUT
			#pragma multi_compile UI_CLIP_OFF UI_CLIP_ON
			#pragma multi_compile UI_GRAY_OFF UI_GRAY_ON
			// ------ add -----
            #include "UnityCG.cginc"  
              
            struct appdata_t  
            {  
                float4 vertex   : POSITION;  
                float4 color    : COLOR;  
                float2 texcoord : TEXCOORD0;  
            };  
  
            struct v2f  
            {  
                float4 vertex   : SV_POSITION;  
                fixed4 color    : COLOR;  
                half2 texcoord  : TEXCOORD0; 
				// ------ add by canyon -----
				float3 vpos : TEXCOORD3;
				// ------ add -----
            };  
              
            fixed4 _Color;  
			fixed4 _UIMask;
  
            v2f vert(appdata_t IN)  
            {  
                v2f OUT;  
				float4 _vertex = IN.vertex;
                OUT.vertex = UnityObjectToClipPos(_vertex);  
                OUT.texcoord = IN.texcoord;  
#ifdef UNITY_HALF_TEXEL_OFFSET  
				OUT.vertex.xy -= (_ScreenParams.zw-1.0);
#endif  
                OUT.color = IN.color * _Color;  
				
				// ------ add by canyon -----
				//OUT.vpos = _vertex.xyz; // 与下面的无区别
				OUT.vpos = mul(unity_ObjectToWorld, _vertex).xyz;
				// ------ add -----
				
                return OUT;  
            }  
  
            sampler2D _MainTex;  
  
            fixed4 frag(v2f IN) : SV_Target  
            {  
                half4 _col = tex2D(_MainTex, IN.texcoord) * IN.color;  
				
				// ------ add by canyon -----
				float _aa = 1;
				#if defined(UI_MASK_ON) || defined(UI_MASK_OUT)
				_aa *= (IN.vpos.x >= _UIMask.x);
				_aa *= (IN.vpos.y >= _UIMask.y);
				_aa *= (IN.vpos.x <= _UIMask.z);
				_aa *= (IN.vpos.y <= _UIMask.w);
				#endif
				
				// #ifdef #elif #else #endif
				#ifdef UI_MASK_OUT
				_aa = step(_aa,0.9);
				#endif
				_col.a *= _aa;
				
				#ifdef UI_GRAY_ON
				float cc = 0.299*_col.r + 0.587*_col.g + 0.184*_col.b;
				half4 finalColor = half4(cc, cc, cc, _col.a);
				_col = finalColor;
				#endif
				
				#ifdef UI_CLIP_ON
                clip (_col.a - 0.001);
				#endif
				// ------ add -----
				
                return _col;  
            }  
        ENDCG  
        }  
    }
}