// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "S_E/OpaqueEdgeLight(Cutout)" {
    Properties 
	{
		_MainTex("Base", 2D) = "white" {}
		_CutOut("Aplha CutOut",Range(0,1)) = 0.15
		_Threshold("Texture Ratio",Range(0,1)) = 1
		_Multiple("Multiple Factor", Range(0, 10)) = 1	
		_AlphaPower ("Alpha Power", Range(0, 8)) = 4
        _Alpha ("Alpha Multiple", Range(0, 1)) = 1
        _EdgeBaseColor ("Base", Color) = (0.17,0.36,0.81,1.0)
		_EdgeBaseColorWeight("Base Weight",Range(0, 5)) = 2.5
		_EdgeInnerColor("Inner", Color) = (0.5,0.5,0.5,1.0)
		_EdgeInnerColorWeight ("Inner Weight", Range(0, 1)) = 0.5
    }
    SubShader 
	{
		Tags 
		{
			"RenderType"="TransparentCutout"
			"Queue"="AlphaTest"
		}
		
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fog
            #include "UnityCG.cginc"
			
			float4 _MainTex_ST;
			uniform sampler2D _MainTex;			
            uniform fixed4 _EdgeBaseColor;
			uniform fixed4 _EdgeInnerColor;
            uniform fixed _Threshold;
            uniform fixed _EdgeInnerColorWeight;
            uniform half _EdgeBaseColorWeight;
            uniform half _AlphaPower;
			uniform fixed _Alpha;
            uniform half _Multiple;
			uniform half _CutOut;
            struct appdata
			{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
            };
			
            struct v2f 
			{
				UNITY_FOG_COORDS(1)	
                float4 vertex : POSITION;
                float4 posWorld : POSITION1;
                float3 normalDir : NORMAL;
				float2 uv : TEXCOORD0;			
            };
			
            v2f vert (appdata v) 
			{
                v2f o;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex );
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
			
            fixed4 frag(v2f i) : COLOR 
			{
				fixed4 diffuse = tex2D(_MainTex,i.uv);
				clip(diffuse.a - _CutOut);
				half3 normal = normalize(i.normalDir);
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
				
				half rim = 1.0 - saturate(dot (viewDir, normal));
				
				fixed4 col = 1;
				half factor = pow(rim , _EdgeBaseColorWeight) * _Multiple;
				col.rgb = _EdgeBaseColor.rgb * factor + _EdgeInnerColor.rgb * _EdgeInnerColorWeight * 2.0;
                fixed a = _Alpha * pow(rim , _AlphaPower)*_Multiple;
				
				diffuse.rgb *=  _Threshold;	
				col.rgb = col.rgb * a + diffuse ;			
				UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
    Fallback "Custom/Unlit/Opaque"
}
