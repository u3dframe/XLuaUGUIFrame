Shader "S_E/Add/MaskFlow" {
	Properties {
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0

		_FlowTex("Flow Text", 2D) = "white" {}
		_FlowColor("Flow Color", Color) = (1, 1, 1, 0.2)
		_FlowDir("Flow Dir", Vector) = (1, 0, 0, 0)
		_FlowClampMin("Flow Clamp Min", Range(0, 1)) = 0
		_FlowClampMax("Flow Clamp Max", Range(0, 1)) = 0.8
		_FlowSpeed("Flow Speed", Float) = 0.4
		_FlowFactorTex("Flow Factor Text", 2D) = "white" {}
		[ToggleOff] _IsSimpleFlow("Use Simple Flow", Float) = 1
	}

	Category {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
		Blend SrcAlpha One
		//ColorMask RGB
		Cull Off Lighting Off ZWrite Off

		SubShader {
			Pass {

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
				#pragma multi_compile_particles
				#pragma multi_compile_fog

				#pragma multi_compile UI_MASK_OFF UI_MASK_ON

				#include "../mycginclue/mylighting.cginc"
				#include "../mycginclue/myeffect.cginc"

				sampler2D _MainTex;
				fixed4 _TintColor;

				fixed4 _UIMask;

				uniform float _IsUseFlow;
				uniform sampler2D _FlowFactorTex;
				uniform float4	  _FlowFactorTex_ST;

				struct appdata_t {
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float3 normal : NORMAL;
					float2 texcoord : TEXCOORD0;
					UV_COORDS(1)
				};

				struct v2f {
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					NORMAL_COORDS(1)
					UV_OUT(2)
					UNITY_FOG_COORDS(3)

					//#ifdef UI_MASK_ON
					float3 vpos : TEXCOORD4;
					//#endif

					#ifdef SOFTPARTICLES_ON
						float4 projPos : TEXCOORD5;
					#endif
				};

				float4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					float4 _vertex = v.vertex;
					o.vertex = UnityObjectToClipPos(_vertex);
					#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					UNITY_TRANSFER_FOG(o,o.vertex);

					//#ifdef UI_MASK_ON
					o.vpos = mul(unity_ObjectToWorld,v.vertex).xyz;
					//#endif

					TRANSFER_NORMAL(o)
					GET_UV(o, v)

					return o;
				}

				sampler2D_float _CameraDepthTexture;
				float _InvFade;

				fixed4 frag (v2f i) : SV_Target
				{
					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						float partZ = i.projPos.z;
						float fade = saturate (_InvFade * (sceneZ-partZ));
						i.color.a *= fade;
					#endif

					fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
					UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode

					#ifdef UI_MASK_ON
						col.a *= (i.vpos.x >= _UIMask.x);
						col.a *= (i.vpos.y >= _UIMask.y);
						col.a *= (i.vpos.x <= _UIMask.z);
						col.a *= (i.vpos.y <= _UIMask.w);
					#endif

					// Flow Light
					fixed3 viewDir = normalize(_WorldSpaceCameraPos - i.vpos);
					fixed3 flow = SHOW_FLOW(i, viewDir, i._Normal)
					fixed flowFactor = tex2D(_FlowFactorTex, TRANSFORM_TEX(i.texcoord, _FlowFactorTex)).r ;
					col.rgb += flow * pow(flowFactor, 2);

					return col;
				}
				ENDCG
			}
		}
	}
}
