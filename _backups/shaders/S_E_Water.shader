Shader "S_E/Water"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_WaterColorShallow("Water Color Shallow", Color) = (1.0, 1.0, 1.0, 0.0)
		_WaterColorDeep("Water Color Deep", Color) = (0.1, 0.45, 0.6, 0.9)
		_MaxVisibleDepth("Max Visible Depth", Float) = 5.0
	}
	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent-1" }
		LOD 100

		Pass
		{
			Cull off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog	
			#include "UnityCG.cginc"
			
			uniform float _MaxVisibleDepth;
			uniform fixed4 _WaterColorShallow;
			uniform fixed4 _WaterColorDeep;
			uniform float _DepthOffset;
			struct appdata
			{
				float4 vertex : POSITION;
				float3 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				fixed4 color:COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_VP , v.vertex);
				float depth = v.uv.z + _DepthOffset;
				float  factor = depth / _MaxVisibleDepth;
				factor  = clamp( factor, 0.0, 1.0);
				fixed4 waterColor = lerp(_WaterColorShallow, _WaterColorDeep, factor);				
				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);;
				o.color = waterColor;
				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{				
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb = lerp(i.color.rgb ,col.rgb,0.8);
				col.a = smoothstep(0.0 , 1.0, i.color.a);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
