Shader "S_E/CameraGray"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Scale("Gray Scale",Range(0,1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			ZTest Always Cull Off ZWrite Off
			Fog { Mode off }    
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed _Scale;
	
	v2f vert (appdata_img v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}
	
	fixed4 frag (v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
		fixed3 gray= Luminance(col);
		col.rgb = lerp(col.rgb, gray ,_Scale);
		return col;
	}
	ENDCG
}
