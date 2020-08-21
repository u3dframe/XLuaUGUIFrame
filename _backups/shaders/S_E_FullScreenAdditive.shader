Shader "S_E/FullScreenAdditive" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
		_Brightness ("Brightness", Range(0,5)) = 1.0
		_Size ("Size", Range(0,5)) = 1.0
	}

	SubShader 
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

		ZWrite Off
		Cull Off
		Blend SrcAlpha One, Zero One
		
		Pass 
		{  
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata_t 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};

        	fixed4 _Color;
			fixed _Brightness;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Size;
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex.xy = v.vertex.xy * _Size;
				o.vertex.z = 0.0;
				o.vertex.w = 1.0;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = v.color * _Color * _Brightness;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = i.color * tex2D(_MainTex, i.texcoord) ;
				
				return col;
			}
			ENDCG
		}
	}

}
