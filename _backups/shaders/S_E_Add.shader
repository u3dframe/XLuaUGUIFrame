Shader "S_E/Add/Base" {
	Properties {
		_MainTex ("Particle Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha One
		//ColorMask RGB
		Cull Off Lighting Off ZWrite Off 
		
		
		SubShader {

			Pass {
				
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#pragma multi_compile UI_MASK_OFF UI_MASK_ON

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				fixed4 _TintColor;

				fixed4 _UIMask;
				
				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;

					#ifdef UI_MASK_ON
						float3 vpos : TEXCOORD3;
					#endif
				};

				float4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					float4 _vertex = v.vertex;
					o.vertex = UnityObjectToClipPos(_vertex);
					
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);

					#ifdef UI_MASK_ON
						//o.vpos = _vertex.xyz; // 与下面的无区别
						o.vpos = mul(unity_ObjectToWorld, _vertex).xyz;
					#endif

					return o;
				}

				
				fixed4 frag (v2f i) : SV_Target
				{
					fixed4 col =i.color * _TintColor * tex2D(_MainTex, i.texcoord);

					#ifdef UI_MASK_ON
						col.a *= (i.vpos.x >= _UIMask.x);
						col.a *= (i.vpos.y >= _UIMask.y);
						col.a *= (i.vpos.x <= _UIMask.z);
						col.a *= (i.vpos.y <= _UIMask.w);
					#endif
					return col;
				}
				ENDCG
			}
		}
	}
}