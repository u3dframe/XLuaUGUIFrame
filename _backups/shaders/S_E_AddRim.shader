// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "S_E/Add/Rim" {
	Properties {
		_MainTex ("Particle Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)

		//边缘发光颜色 || Rim Color  
        _RimColor("[边缘发光颜色]Rim Color", Color) = (0.5,0.5,0.5,1)  
        //边缘发光强度 ||Rim Power  
        _RimPower("[边缘发光强度]Rim Power", Range(0.0, 36)) = 0.1  
        //边缘发光强度系数 || Rim Intensity Factor  
        _RimIntensity("[边缘发光强度系数] Rim Intensity", Range(0.0, 100)) = 3  
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha One
		//ColorMask RGB
		Cull Off Lighting Off ZWrite Off 
		
		
		SubShader {

			Pass {

				Tags { "LightMode" = "ForwardBase" }
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#pragma multi_compile UI_MASK_OFF UI_MASK_ON

				#include "UnityCG.cginc"  
                #include "AutoLight.cginc"

				sampler2D _MainTex;
				fixed4 _TintColor;
				
				//边缘光颜色  
                uniform float4 _RimColor;  
                //边缘光强度  
                uniform float _RimPower;  
                //边缘光强度系数  
                uniform float _RimIntensity;  

				fixed4 _UIMask;
				
				struct appdata_t {
					float4 vertex : POSITION; // 顶点位置
					fixed4 color : COLOR; // 颜色
					float2 texcoord : TEXCOORD0; // 一级纹理坐标
					float3 normal : NORMAL; // 法线向量坐标
				};

				struct v2f {
					float4 vertex : SV_POSITION; // 像素位置
					fixed4 color : COLOR; // 颜色
					float2 texcoord : TEXCOORD0; // 一级纹理坐标
					float3 normal : NORMAL; // 法线向量坐标

					float4 vpos : TEXCOORD1; // 世界空间中的坐标位置

					LIGHTING_COORDS(3,4) // 创建光源坐标,用于内置的光照 
				};

				float4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					float4 _vertex = v.vertex;
					o.vertex = UnityObjectToClipPos(_vertex);
					
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);

					o.normal = mul(float4(v.normal,0), unity_WorldToObject).xyz; // UnityObjectToWorldNormal(v.normal);

					//o.vpos = _vertex.xyz; // 与下面的无区别
					o.vpos = mul(unity_ObjectToWorld, _vertex);

					return o;
				}

				
				fixed4 frag (v2f i) : SV_Target
				{
					// 方向参数准备 || Direction
					//视角方向  
                    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.vpos.xyz);

					// 准备自发光参数 || Emissive  
                    //计算边缘强度  
                    half _rim = 1.0 - max(0,dot(viewDir,i.normal)); //1.0 - saturate(dot (viewDir, i.normal));
                    //计算出边缘自发光强度  
                    float3 Emissive = _RimColor.rgb * pow(_rim,_RimPower) *_RimIntensity;  

					fixed4 col = i.color * _TintColor * tex2D(_MainTex, i.texcoord);
					fixed4 finalColor = fixed4(col.rgb + Emissive,col.a);

					#ifdef UI_MASK_ON
						finalColor.a *= (i.vpos.x >= _UIMask.x);
						finalColor.a *= (i.vpos.y >= _UIMask.y);
						finalColor.a *= (i.vpos.x <= _UIMask.z);
						finalColor.a *= (i.vpos.y <= _UIMask.w);
					#endif
					return finalColor;
				}
				ENDCG
			}
		}
	}
}