#ifndef MY_SHADOW_INCLUDED
	#define MY_SHADOW_INCLUDED

	#include "UnityCG.cginc"

	// 人物实时阴影
	#define USE_STANDARD_SM
	#ifdef USE_STANDARD_SM
		uniform fixed _ShadowIntensity;
		uniform sampler2D _ShadowMap;
		uniform float4x4 _World2ShadowProj;
		uniform float _ShadowMapSizeW, _ShadowMapSizeH;

		fixed calcShadowFactor(float4 uvShadow)
		{
			uvShadow.xy = 0.5 * uvShadow.xy / uvShadow.w  + float2(0.5, 0.5);

			float xOffset = 1.0 / _ShadowMapSizeW;
			float yOffset = 1.0 / _ShadowMapSizeH;

			half value = tex2D(_ShadowMap, float2(uvShadow.x - xOffset, uvShadow.y - yOffset)).r;
			value += tex2D(_ShadowMap, float2(uvShadow.x, uvShadow.y - yOffset)).r;
			value += tex2D(_ShadowMap, float2(uvShadow.x + xOffset, uvShadow.y - yOffset)).r;
			value += tex2D(_ShadowMap, float2(uvShadow.x - xOffset, uvShadow.y)).r;
			value += tex2D(_ShadowMap, float2(uvShadow.x, uvShadow.y)).r;
			value += tex2D(_ShadowMap, float2(uvShadow.x + xOffset, uvShadow.y)).r;
			value += tex2D(_ShadowMap, float2(uvShadow.x - xOffset, uvShadow.y + yOffset)).r;
			value += tex2D(_ShadowMap, float2(uvShadow.x, uvShadow.y + yOffset)).r;
			value += tex2D(_ShadowMap, float2(uvShadow.x + xOffset, uvShadow.y + yOffset)).r;

			return (value / 9);
		}

		fixed3 computeShadowColor(float4 uvShadow)
		{
			fixed shadow = saturate(calcShadowFactor(uvShadow) + _ShadowIntensity);
			return fixed3(shadow, shadow, shadow);
		}

		#define SHADOW_COORDS(idx1) float4 _ShadowCoord : TEXCOORD##idx1;
		#define TRANSFER_SHADOW(a) a._ShadowCoord = mul(_World2ShadowProj, mul( unity_ObjectToWorld, v.vertex ));
		#define SHADOW_ATTENUATION(a) computeShadowColor(a._ShadowCoord);
	#else

	#endif

	// 静态光照贴图
	//#ifndef LIGHTMAP_OFF
	half3 computeLightMapColor(float2 uvLM)
	{
		return DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uvLM));
	}

	#define LIGHTMAP_COORDS(idx1) float2 _uvLM : TEXCOORD##idx1;
	#define TRANSFER_LIGHTMAP(a) a._uvLM = v._uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	#define LIGHTMAP_ATTENUATION(a) computeLightMapColor(a._uvLM);
	//#endif

#endif
