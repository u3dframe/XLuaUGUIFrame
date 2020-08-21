// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "S_E/CenterBlur" 
{
	Properties 
	{
		_MainTex ("Font Texture", 2D) = "white" {}
		_Offset("Offset", Range(0, 0.02)) = 0.01
		_Threshold("Threshold",Range(0, 0.5)) = 0
	}

	SubShader 
	{
		Pass
		{
			ZTest Always
			Cull Off 
			ZWrite Off
			Fog { Mode off }      

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag2
			ENDCG
		}
	}
	Fallback off

	CGINCLUDE
	#include "UnityCG.cginc"
	struct v2f 
	{
		float4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;
	};

	sampler2D _MainTex;
	half _Offset;
	half _Threshold;
	static half2 _center = half2(0.5,0.5);
	
	v2f vert( appdata_img v ) 
	{
		v2f o; 
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;		 
		return o;
	}
	
	fixed4 frag2(v2f i) : COLOR  
	{  	
		half2 offset = i.uv - _center ;
		half len = length(offset);	
		offset *= _Offset;		
		
		fixed4 color = tex2D(_MainTex, i.uv);
		fixed4 col = color;		
		color += tex2D(_MainTex, i.uv + offset);  
		color += tex2D(_MainTex, i.uv + offset * 2); 
		color += tex2D(_MainTex, i.uv + offset * 3); 		
		color *= 0.25;
		
		half t = smoothstep(_Threshold,0.5,len);
		return lerp(col, color , t);		
	}  
	ENDCG
}