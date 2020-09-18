// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Coating" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_LightingTex ("Lighting (RGB)", 2D) = "white" {}

		_AmbientRatio ("环境光系数", Range(0,2) ) = 1

		//避免缩放对法线的影响 值为模型缩放值
		//法线乘上该系数 修正
		_NormalRevise ("法线修正", float) = 1

		_Split ("明暗分块", range(0,255) ) = 128
		_DarkColor ("暗部颜色", Color) = (0.35,0.35,0.35,1)
		_BrightnessColor ("亮部颜色", Color) = (0.5,0.5,0.5,1)
		_SkinColor ("皮肤颜色", Color) = (1,1,1,1)

		_SpecRatio ("高光系数", range(0.01,1.0)) = 1
		//先屏蔽 效果不明显
		//_SpecSplit("高光分块", range(0,1) ) = 0
		_SpecularPower ("高光亮度", float) = 1

		_Factor("描边系数", Range(0,1)) = 0.5
		_OutlineWidth ("描边宽度", Range(0.0,0.4) ) = 0.001
		_OutlineColor ("描边颜色", Color) = (0,0,0,1)		

		_ExtraColor ("Extra Color", Color) = (1,1,1,1)

		[Enum (HDR_ALL,1, HDR_RIM,2)] _HDRType ("HDR类型", int) = 1
		_RimPower("边缘HDR强度", Range(0.5,5) ) = 1
		_RimThreshold ("边缘HDR阈值", Range(0,1)) = 0.3		
		//最终颜色强度 开启HDR时生效
    	//和 Bloom结合产生glow效果
		_Intensity ("HDR强度", Range(-1.0,2.0) ) = 1.0
		_HDRColor ("HDR颜色", COLOR) = (1,1,1,1)

	   	_Alpha("Alpha", Range(0,1)) = 1
	}

	CGINCLUDE
		uniform float _Alpha;
	ENDCG

	SubShader {
		Tags { 
		"RenderType"="Opaque"
		"Queue" = "Transparent+1"		
		}
		LOD 200

		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB		

		pass
		{
			Name "OUTLINE"
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform float _NormalRevise;

			uniform float _Factor;
			uniform float _OutlineWidth;			
			uniform float4 _OutlineColor;			

			struct appdata
			{
				float4 vertex: POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 position : SV_POSITION;		
				float3 normal : TEXCOORD0;		
			};

			v2f vert(appdata v)
			{
				v2f o;

				float3 dir = normalize(v.vertex.xyz);
				float3 dir2 = v.normal;
				float D = dot(dir, dir2);
				dir = dir * sign(D);
				dir = dir * _Factor + dir2 * (1 - _Factor);
				v.vertex.xyz += dir * _OutlineWidth;
				o.position = UnityObjectToClipPos(v.vertex);

				return o;
			}

			float4 frag(v2f i) : COLOR
			{
				_OutlineColor.a = _Alpha;
				return _OutlineColor;								
			}

			ENDCG
		}

		pass
		{
			Name "COATING"

			Tags { 
				"Queue" = "Transparent+2" 
				//指明光照模式为前向渲染模式
				"LIGHTMODE"="FORWARDBASE"				
				"RenderType"="Opaque"
        	}     
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag		
			#pragma target 3.0
				
			//确保光照衰减等光照变量可以被正确赋值
			#pragma multi_compile_fwdbase		
			//自定义观察相机位置
			#pragma multi_compile UNITY_CAMERA CUSTOM_CAMERA			
			//自定义平行光方向
			#pragma multi_compile UNITY_LIGHT CUSTOM_LIGHT
			//是否接收阴影 默认关闭
			#pragma multi_compile RECEIVE_SHADOWS_OFF RECEIVE_SHADOWS_ON

			//#include "UnityCG.cginc"			
			#include "Lighting.cginc"  
			#include "AutoLight.cginc"

			uniform sampler2D _MainTex;	
			uniform float4 _MainTex_ST;	
			uniform sampler2D _LightingTex;
			uniform float4 _LightingTex_ST;	

			uniform float _AmbientRatio;			

			uniform float _Split;
			uniform float4 _DarkColor;
			uniform float4 _BrightnessColor;
			uniform float4 _SkinColor;
					
			uniform float _SpecRatio;
			//uniform float _SpecSplit;
			uniform float _SpecularPower;

			//全局光
			uniform float3 _LightDir;	
			uniform float4 _LightColor;

			uniform float4 _ExtraColor;

			//自定义摄像机位置
			//调节高光用
			uniform float4 _CameraPos;
		
			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0; 
				float3 normal : NORMAL;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;				
				float3 worldPos : TEXCOORD2;	
				#if defined (RECEIVE_SHADOWS_ON)
				//添加内置宏，声明一个用于阴影纹理采样的坐标，参数是下一个可用的插值寄存器的索引值			
				SHADOW_COORDS(3)
				#endif
			};
			
			v2f vert(appdata v)
			{
				v2f o;				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = mul(v.normal, (float3x3)unity_WorldToObject);				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				#if defined (RECEIVE_SHADOWS_ON)
				//添加另一个内置宏，用于在顶点着色器中计算上一步中声明的阴影纹理坐标
				TRANSFER_SHADOW(o);
				#endif
				
				return o;
			}

			int _HDRType;
			float _RimPower;
			float _RimThreshold;			
			int _HDR; 
			float _Intensity;
			float4 _HDRColor;
			float4 frag(v2f i) : Color
			{				
				float4 b = tex2D(_MainTex, TRANSFORM_TEX(i.uv,_MainTex));
				//return Luminance(b)*1.4;

				//光照贴图
				//.g ao吸收
				//.r 金属性
				//.b 高光反射系数
				float4 c = tex2D(_LightingTex, TRANSFORM_TEX(i.uv, _LightingTex) );
				float3 N = normalize(i.normal);		
				//return float4(N, 1);		
				#if defined (UNITY_LIGHT)
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				#else
				float3 L = normalize(_LightDir);
				#endif
				float D = max(dot(L, N),0);								
				//漫反射和ao贴图混合得到最终的明暗效果
				float4 DC = D * c.g;

				//float4 hdr = 1 + _HDR*float4(0.2125, 0.7154, 0.0721, 0)*(_Intensity+1);
				float4 hdr = 1*(1-_HDR)+_HDR*_HDRColor*(_Intensity+1);
				
				//明暗分块 <= _Split视为暗部 否则视为亮部 不产生过渡效果 产生明显的分块
				float res = step(DC.r+DC.g+DC.b,_Split*0.0117647);		// 1/255 * 3 = 0.0117647				
				DC = res*_DarkColor+(1-res)*_BrightnessColor;

				#if defined (UNITY_CAMERA)
				float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
				#else				
				float3 V = normalize(_CameraPos - i.worldPos);
				#endif				
				float3 H = normalize(L+V);
				//高光和高光贴图混合c.r
				//暗部对高光的影响为0 不产生高光
				//亮部对高光的影响为1 正常高光
				float spec =  max(dot(N,H),0)*c.r*(1-res);				
				//高光分块先去掉
				//spec = step(_SpecSplit, spec)*pow(spec, _SpecRatio * 128.0);				
				#if defined (UNITY_LIGHT)				
				spec = pow(spec, _SpecRatio * 128.0) * _SpecularPower * c.b * _LightColor0.rgb;												
				#else
				spec = pow(spec, _SpecRatio * 128.0) * _SpecularPower * c.b * _LightColor;								
				#endif						
				b = b * UNITY_LIGHTMODEL_AMBIENT*_AmbientRatio + b * DC *_SkinColor*1.8 + spec;
				#if defined (RECEIVE_SHADOWS_ON)
				//使用内置宏计算阴影值
				fixed shadow = SHADOW_ATTENUATION(i);
				b *= _ExtraColor*shadow;
				#else
				b *= _ExtraColor;
				#endif
				
				float4 col = b;
				float rim = pow(1-max(dot(V, N),0), _RimPower);
				if(1 == _HDRType)
					col = b*hdr;
				else if(2 == _HDRType)															
					col =  _HDR*max(rim-_RimThreshold, 0)*b*hdr + b;
				
				col.a = _Alpha;
				return col;
			}
			ENDCG
		}		
	}
	 
	//for Unity Shadow Depth
	FallBack "Diffuse"
}
