// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "S_E/DistortedMask"
{
	Properties 
	{
		_MainTex("Distortion",2D) = "black"{}
		_Intensity("Intensity",Range(0,0.5)) = 0
	}
	
	SubShader {
		Tags { "Post"="Distortion"  }
		Pass
		{
			LOD 100			
			ZWrite Off 
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 uv : TEXCOORD0;
				fixed4 color : COLOR;
				UNITY_FOG_COORDS(1)				
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Intensity;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color;
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv) * _Intensity ;
				col *= i.color.a;
				return col;
			}			
			ENDCG
		}
	}
	
	Fallback "Custom/Unlit/Opaque"
}
