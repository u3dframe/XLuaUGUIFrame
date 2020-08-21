// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "S_E/Dissolve"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Amount("Amount",Range(0,1)) = 0
		_EdgeWidth("Edge Width",Range(0,1)) = 0.1
		_ColorStrength("Edge Strength",Range(0,3)) = 1
		_EdgeColor("Edge Color",Color) = (1,0,0,1)
		_MaskTex("Mask (R)", 2D) = "white" {}
	    _Ramp ("Ramp (RGB)", 2D) = "black" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent" "IgnoreProjector"="True"  "Queue" = "Transparent" }
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{				
				UNITY_FOG_COORDS(2)
				float4 vertex : SV_POSITION;
				half2 uv_MainTex : TEXCOORD0;
				half2 uv_MaskTex : TEXCOORD1;
			};

			uniform sampler2D _MainTex;
			uniform sampler2D _MaskTex;
			uniform sampler2D _Ramp;
			uniform fixed4 _EdgeColor;
			uniform fixed4 _Color;
			uniform fixed _ColorStrength;
			uniform fixed _Amount;
			uniform fixed _EdgeWidth;
			float4 _MainTex_ST;
			float4 _MaskTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv_MaskTex = TRANSFORM_TEX(v.uv, _MaskTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv_MainTex) * _Color;
				if(_Amount > 0)
				{
					fixed4 mask = tex2D(_MaskTex, i.uv_MaskTex).a;
					fixed not = 1 - step(mask.r , _Amount);
					col.a *= not;
		
					fixed a = mask.r - _Amount;
					
					not = 1 - step(_EdgeWidth , a);
					fixed2 uv = fixed2(1 - a /_EdgeWidth,0);
					fixed3 edgeCol = tex2D(_Ramp, uv).rgb ;
					col.rgb += (_EdgeColor.rgb * uv.x  + edgeCol ) * _ColorStrength * not;
				}
					
				UNITY_APPLY_FOG(i.fogCoord, col);				
				return col;
			}
			ENDCG
		}
	}

	Fallback Off
}
