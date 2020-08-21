// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "S_E/Occlusion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_OcclusionAlpha ("Occlusion Alpha", Range(0, 1)) = 1
		_Cutout ("Alpha Cutout", Range(0,1)) = 0.5
	}
	SubShader
	{	
		Tags 
		{
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
		
		pass 
		{		
			Blend Zero One, One Zero
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma shader_feature UNITY_ALPHACLIP
			
			#ifdef UNITY_ALPHACLIP 	
				uniform float _Cutout;
				uniform	float4 _MainTex_ST;
				uniform sampler2D _MainTex;
			#endif
			
			struct appdata
			{
				float4 vertex : POSITION;
				#ifdef UNITY_ALPHACLIP 	
					float2 uv : TEXCOORD0;
				#endif	
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				
				#ifdef UNITY_ALPHACLIP 	
					float2 uv : TEXCOORD0;
				#endif				
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				#ifdef UNITY_ALPHACLIP 	
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				#endif
					
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = 0;	
				#ifdef UNITY_ALPHACLIP 	
					col = tex2D(_MainTex,i.uv).rgba;	
					clip(col.a - _Cutout);
				#endif
											
				return col;
			}
			ENDCG		
		}
		
        Pass 
		{
            Blend SrcAlpha OneMinusSrcAlpha		
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF
			#pragma multi_compile _ AMBIENT_COLOR
			
			#ifdef AMBIENT_COLOR
				fixed4 _AmbientFilter;
				uniform fixed4 g_AmbientColor;
			#endif

			float4 _MainTex_ST;
			uniform fixed _OcclusionAlpha;
			uniform sampler2D _MainTex;

            struct appdata
			{
                float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 texcoord1 :TEXCOORD1;
            };
			
            struct v2f 
			{
                float4 vertex : POSITION;
				float2 uv : TEXCOORD0;	
				#ifdef LIGHTMAP_ON
					float2 lmap : TEXCOORD1;
				#endif				
            };
			
            v2f vert (appdata v) 
			{
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex );
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				#ifdef LIGHTMAP_ON
					o.lmap = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				
                return o;
            }
			
            fixed4 frag(v2f i) : COLOR 
			{
				fixed4 col = tex2D(_MainTex,i.uv).rgba;	
				#ifdef LIGHTMAP_ON
					fixed4 light = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap);
					light.rgb = DecodeLightmap(light);
					col.rgb *= light;
				#endif
				#ifdef AMBIENT_COLOR
					col.rgb *= lerp(g_AmbientColor.rgb, 1, _AmbientFilter.rgb);
				#endif
				
				col.a *= _OcclusionAlpha;
                return col;
            }
            ENDCG
        }
	}
}
