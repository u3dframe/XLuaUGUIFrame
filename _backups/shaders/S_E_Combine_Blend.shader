Shader "S_E/EffectCombine(Blend)"
{
	Properties
	{
		[HideInInspector] _TwoSide("Two Side", Float) = 2
		[Header(Main Maps)] [Space(2)]
		_EmissiveColor ("Emission Color", Color) = (0,0,0,0)
		_MainTex("Albedo", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,1)
		_Brightness("Brightness", Range(0,5)) = 1.0
		
		[Header(Extended Properties)] [Space(2)]
		_TintingStrength("Tinting Strength", Range(0,1)) = 1
		
		[Space(10)][Toggle(USE_FLUID_LIGHT)] _UseFluidLight ("Use Fluid Light", Float) = 0
		_LightTex ("Fluid", 2D) = "black" {}
		[Toggle(USE_FLUID_MASK )] _UseFluidMask ("Use Fluid Mask", Float) = 0
		_FluidMask("Fluid Mask(G)", 2D) = "white" {}
		_LightColor("Light Color",Color) = (1,1,1,1)	
		_LightStrength ("Light Strength", Range(0, 2)) = 1
		
		[Space(10)][Toggle(USE_EDGE_LIGHT)] _UseEdgeLight ("Use Edge Light", Float) = 0
		_Power ("Power Factor", Range(0, 8)) = 4
		_Multiple("Multiple Factor", Range(0, 10)) = 1	
        _EdgeBaseColor ("Base", Color) = (0.17,0.36,0.81,1.0)
		
		[Space(10)][Toggle(USE_Dissolve)] _USEDissolve ("Use Dissolve", Float) = 0
		_Amount("Amount",Range(0,1)) = 0
		_EdgeWidth("Edge Width",Range(0,1)) = 0.1
		_ColorStrength("Edge Strength",Range(0,3)) = 1
		_EdgeColor("Edge Color",Color) = (1,0,0,1)
		_DissolveMask("Dissolve Mask (R)", 2D) = "white" {}
	    _Ramp ("Ramp (RGB)", 2D) = "black" {}
	}

	SubShader
	{
		Tags{ "RenderType"="Transparent" "Queue" = "Transparent"}

		Cull[_TwoSide]
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha 
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
            #pragma target 2.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature UNITY_ALPHACLIP
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase noshadow

			#include "UnityCG.cginc"
			
			struct appdata_t 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
				UNITY_FOG_COORDS(1)
			};

        	fixed4 _Color;
			fixed4 _EmissiveColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Brightness;
			fixed _TintingStrength;
			uniform fixed4 g_NTintingColor;

			#ifdef UNITY_ALPHACLIP 			
				uniform half _Cutout;
			#endif

			v2f vert (appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = v.color;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col =  tex2D(_MainTex, i.texcoord);
				
				#ifdef UNITY_ALPHACLIP 	
					clip(col.a - _Cutout);
				#endif

				col = i.color * col * _Color * _Brightness+ _EmissiveColor;
				col.rgb *= lerp(fixed3(1,1,1), 1 - g_NTintingColor.rgb, _TintingStrength);

				UNITY_APPLY_FOG_COLOR(i.fogCoord, col, unity_FogColor);
				return col;
			}

			ENDCG
		}
		
		Pass
		{
			Blend SrcAlpha One, Zero One
			CGPROGRAM
            #pragma target 2.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ USE_Dissolve
			#pragma multi_compile _ USE_FLUID_LIGHT		
			#pragma multi_compile _ USE_EDGE_LIGHT
			#pragma multi_compile _ USE_FLUID_MASK
			#pragma multi_compile_fog
			#pragma multi_compile_fwdbase noshadow

			#include "UnityCG.cginc"
			
			struct appdata_t 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			#ifdef USE_FLUID_LIGHT	
				half2 lightUV:TEXCOORD1;
			#endif	
			
			#ifdef USE_EDGE_LIGHT 
				float4 posWorld : POSITION1;
                float3 normalDir : NORMAL;
			#endif	
			
				fixed4 color : COLOR;
				UNITY_FOG_COORDS(2)
			};

 
			float4 _MainTex_ST;

			#ifdef USE_FLUID_LIGHT
				uniform sampler2D _LightTex;
				uniform sampler2D _FluidMask;
				uniform float4 _LightTex_ST;
				uniform fixed _LightStrength;
				uniform fixed4 _LightColor;
			#endif
		
			#ifdef USE_Dissolve
				uniform sampler2D _DissolveMask;
				uniform sampler2D _Ramp;
				uniform fixed4 _EdgeColor;
				uniform fixed _ColorStrength;
				uniform fixed _Amount;
				uniform fixed _EdgeWidth;
			#endif	
			
			
			#ifdef USE_EDGE_LIGHT 
				uniform fixed _Power;
				uniform fixed _Multiple;
				uniform fixed4 _EdgeBaseColor;
			#endif
			
			v2f vert (appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex);

			#ifdef USE_FLUID_LIGHT				
				float4 offset;
				offset.xy = _Time.x * _LightTex_ST.zw;				
				o.lightUV = v.texcoord.xy * _LightTex_ST.xy + offset.xy;
			#endif	
			
			#ifdef USE_EDGE_LIGHT 
				o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
			#endif	
				o.color = v.color; 
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half2 uv_MainTex = i.texcoord;
				fixed4 col = fixed4(0.0,0.0,0.0,1.0);
	
			#ifdef USE_FLUID_LIGHT								
				fixed3 light = tex2D(_LightTex, i.lightUV).rgb * _LightStrength;
				light *= _LightColor;
				#ifdef USE_FLUID_MASK
					fixed mask =  tex2D(_FluidMask, uv_MainTex).g; 
					col.rgb += mask * light ;
				#else
					col.rgb = light;
				#endif
			#endif	
			
			#ifdef USE_EDGE_LIGHT 
				half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
				half rim = 1.0 - saturate(dot (viewDir, i.normalDir));
				half factor = pow(rim , _Power) * _Multiple;
				col.rgb += _EdgeBaseColor.rgb * factor;
			#endif	
			
			#ifdef USE_Dissolve			
				if(_Amount > 0)
				{
					fixed4 mask = tex2D(_DissolveMask, i.texcoord).r;
					fixed not = 1 - step(mask.r , _Amount);
					col.a *= not;	
					fixed a = mask.r - _Amount;			
					not = 1 - step(_EdgeWidth , a);
					fixed2 uv = fixed2(1 - a /_EdgeWidth,0);
					fixed3 edgeCol = tex2D(_Ramp, uv).rgb ;
					col.rgb += (_EdgeColor.rgb * uv.x  + edgeCol ) * _ColorStrength * not;
				}
			#endif	
			
				UNITY_APPLY_FOG_COLOR(i.fogCoord, col,  fixed4(0,0,0,0));
				return col;
			}

			ENDCG
		}
	}
	
	CustomEditor "CoreEditor.Drawer.EffectBlendCombineShaderGUI"
}
