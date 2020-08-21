// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "S_E/VolumeFog" {
	Properties
	{
		_FogColor("Fog Color", Color) = (1,1,1,1)
	}
	
	
	SubShader
	{
		LOD 300
		//Tags{ "Queue" = "Transparent+99" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Tags {"Queue" = "Overlay" "IgnoreProjector" = "True" "RenderType" = "FogVolume" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off
		ZTest Always

		Pass 
		{
			CGPROGRAM
			#pragma target 3.0    
			#pragma vertex vert    
			#pragma fragment frag    
			#include "UnityCG.cginc"
			float CalcVolumeFogIntensity(float3 sphereCenter, float sphereRadius,float3 cameraPosition,
				float3 viewDirection, float backDepth, float maxDistance, float density)
			{
				float3 local = cameraPosition - sphereCenter;
				float  fA = dot(viewDirection, viewDirection);
				float  fB = 2 * dot(viewDirection, local);
				float  fC = dot(local, local) - sphereRadius * sphereRadius;
				float  fD = fB * fB - 4 * fA * fC;
				if (fD < 0.0f)
					return 0;

				float recpTwoA = 0.5 / fA;

				float dist;
				if (fD == 0.0f)
				{
					dist = backDepth;
				}
				else
				{
					float DSqrt = sqrt(fD);
					dist = (-fB - DSqrt) * recpTwoA;
				}

				dist = min(dist, maxDistance);
				backDepth = min(backDepth, maxDistance);

				float sample = dist;
				float fog = 0;
				float step_distance = (backDepth - dist) / 10;
				for (int seg = 0; seg < 10; seg++)
				{
					float3 position = cameraPosition + viewDirection * sample;
					fog += 1 - saturate(length(sphereCenter - position) / sphereRadius);
					sample += step_distance;
				}
				fog /= 10;
				fog = saturate(fog * density);
				return fog;
			}

			fixed4 _FogColor;
			sampler2D _CameraDepthTexture;
			uniform float4 FogParam;
			struct v2f 
			{
				float4 pos : SV_POSITION;
				float3 view : TEXCOORD0;
				float4 projPos : TEXCOORD1;
			};
			v2f vert(appdata_base v)
			{
				v2f o;
				float4 wPos = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.view = wPos.xyz - _WorldSpaceCameraPos;
				o.projPos = ComputeScreenPos(o.pos);
				// move projected z to near plane if point is behind near plane   
				float inFrontOf = (o.pos.z / o.pos.w) > 0;
				o.pos.z *= inFrontOf;
				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				half4 color = half4(1,1,1,1);
				float depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos))));
				float backDist = length(i.view);
				float3 viewDir = normalize(i.view);

				float fog = CalcVolumeFogIntensity(FogParam.xyz, FogParam.w,
				_WorldSpaceCameraPos, viewDir, backDist, depth,_FogColor.a);

				color.rgb = _FogColor.rgb;
				color.a = fog;
				return color;
			}
			ENDCG
		}
	}
	
	
	SubShader
	{
		LOD 150
		Tags {"Queue" = "Overlay" "IgnoreProjector" = "True" "RenderType" = "FogVolume" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Front
		Lighting Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			Fog {Mode Off }
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0			
			#include "UnityCG.cginc" 
			
			sampler2D _CameraDepthTexture;
			float4 _FogColor, _BoxMin, _BoxMax; // w :float Exposure ,_Visibility;
			

			float hitbox(float3 startpoint, float3 direction, float3 m1, float3 m2, inout float tmin, inout float tmax)
			{
				float tymin, tymax, tzmin, tzmax;
				float flag = 1.0;
				if (direction.x > 0)
				{
					tmin = (m1.x - startpoint.x) / direction.x;
					tmax = (m2.x - startpoint.x) / direction.x;
				}
				else
				{
					tmin = (m2.x - startpoint.x) / direction.x;
					tmax = (m1.x - startpoint.x) / direction.x;
				}

				if (direction.y > 0)
				{
					tymin = (m1.y - startpoint.y) / direction.y;
					tymax = (m2.y - startpoint.y) / direction.y;
				}
				else
				{
					tymin = (m2.y - startpoint.y) / direction.y;
					tymax = (m1.y - startpoint.y) / direction.y;
				}

				if ((tmin > tymax) || (tymin > tmax)) flag = -1.0;
				if (tymin > tmin) tmin = tymin;
				if (tymax < tmax) tmax = tymax;
				if (direction.z > 0)
				{
					tzmin = (m1.z - startpoint.z) / direction.z;
					tzmax = (m2.z - startpoint.z) / direction.z;
				}
				else
				{
					tzmin = (m2.z - startpoint.z) / direction.z;
					tzmax = (m1.z - startpoint.z) / direction.z;
				}

				if ((tmin > tzmax) || (tzmin > tmax)) flag = -1.0;
				if (tzmin > tmin) tmin = tzmin;
				if (tzmax < tmax) tmax = tzmax;
				return (flag > 0.0);
			}

			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 ScreenUVs		: TEXCOORD0;
				float3 LocalPos			: TEXCOORD1;
				float3 LocalEyePos		: TEXCOORD2;
			};


			v2f vert(appdata_full i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.ScreenUVs = ComputeScreenPos(o.pos);
				float3 size = _BoxMax.xyz * 2;
				o.LocalPos = i.vertex.xyz * size;
				o.LocalEyePos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)).xyz * size;

				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				float3 direction = normalize(i.LocalPos - i.LocalEyePos);
				float tmin, tmax;
				float volume = hitbox(i.LocalEyePos, direction, _BoxMin.xyz, _BoxMax.xyz, tmin, tmax);
				// tmin must be 0 when inside the volume

				float3 Inside = step(0.0, abs(i.LocalEyePos) - _BoxMax.xyz);
				float3 bOutside = min(1.0,(Inside.x + Inside.y + Inside.z));
				tmin *= bOutside;

				float depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.ScreenUVs))));

				float dmax = max(tmin, tmax);
				float dmin = min(tmin, tmax);

				float thickness = min(dmax, depth) - min(dmin, depth);

				float fog = thickness / _BoxMax.w;
				fog = 1.0 - exp2(-fog);
				fog *= volume;

				half4 col = _FogColor;
				col.rgb *= _BoxMin.w;
				col.a *= fog * _FogColor.a;
				return col;
			}
			ENDCG
			
		}
	}

	Fallback "VertexLit"
}