Shader "S_E/Fluid"
{
	Properties
	{
		_Color ("Color", Color) =(1,1,1,1)	
		_MainTex ("Texture", 2D) = "white" {}	
		_MaskTex ("Mask", 2D) = "white" {}		
		_LightTex ("Fluid (UV0)", 2D) = "black" {}
		_LightTex2 ("Fluid (UV1)", 2D) = "black" {}
	}
	
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 100
		Cull Off
		ZWrite Off
		Blend SrcAlpha One 
		Pass		
		{
			CGPROGRAM		
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			
			struct appdata_v {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;//第二纹理坐标
				float4 texcoord2 : TEXCOORD2;//第三纹理坐标
				float4 texcoord3 : TEXCOORD3;//第四纹理坐标
				fixed4 color : COLOR;//顶点颜色
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f 
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;			
				UNITY_FOG_COORDS(1)
			};

				
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
		
				
			v2f vert (appdata_v v )
			{	
				v2f o;	
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.color = v.color;				
				return o; 			
			}
			
			fixed4 frag (v2f i):COLOR
			{
				fixed4 col = tex2D(_MainTex, i.texcoord) * i.color * _Color;			

				return col;
			}	
			
			ENDCG
		}
		
		Pass 
		{  						
			CGPROGRAM
			#pragma target 2.0				
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			
			
			struct v2f 
			{
				float4 vertex : SV_POSITION;
				half2 uv_MaskTex : TEXCOORD1;
				half4 LT_UV : TEXCOORD2;		
				UNITY_FOG_COORDS(3)
			};
				
			sampler2D _LightTex;
			sampler2D _LightTex2;
			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			float4 _LightTex_ST;
			float4 _LightTex2_ST;
		
				
			v2f vert (appdata_full v )
			{	
				v2f o;	
				o.vertex = UnityObjectToClipPos(v.vertex);
	
				o.uv_MaskTex = TRANSFORM_TEX(v.texcoord, _MaskTex);
				float4 offset;
				offset.xy = _Time.x * _LightTex_ST.zw;
				offset.wz = _Time.x *_LightTex2_ST.zw;
				o.LT_UV.xy = v.texcoord.xy * _LightTex_ST.xy + offset.xy;
				o.LT_UV.wz = v.texcoord1.xy * _LightTex2_ST.xy + offset.wz;
			
				return o; 			
			}
			
			fixed4 frag (v2f i):COLOR
			{
				fixed4 col = 1;
				fixed mask = tex2D(_MaskTex, i.uv_MaskTex).r;
				fixed3 light = tex2D(_LightTex, i.LT_UV.xy).rgb;
				light += tex2D(_LightTex2, i.LT_UV.wz).rgb;
				col.rgb =  mask * light ;
			
				return col;
			}	

			ENDCG
		}
	}
}
