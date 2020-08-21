#ifndef MY_LIGHTING_INCLUDED
    #define MY_LIGHTING_INCLUDED

    #include "UnityCG.cginc"
    #include "Lighting.cginc"

    uniform fixed4 _Ambient;
    uniform fixed4 _BaseColor;
    uniform float  _IsInUI;
    // 漫反射光照模型（半兰伯特）
    inline fixed3 computeDiffuseColor(half3 lightDir, half3 normal, float lightScale)
    {
        fixed3 lightColor = lerp(_LightColor0.rgb, fixed3(1, 1, 1), _IsInUI);
        fixed3 l = normalize(lightDir);
        fixed3 n = normalize(normal);
        //float diffuse = saturate(dot(n, l));
        float diffuse = 0.5 * dot(n, l) + 0.5;

        //return fixed3(_Ambient.rgb + _LightColor0.rgb * lightScale * diffuse);
        //return UNITY_LIGHTMODEL_AMBIENT;
        return fixed3(_Ambient.rgb + lerp(_BaseColor.rgb, lightColor * lightScale, diffuse));
    }

    #define LIGHTDIR_COORDS(idx1) half3 _LightDir : TEXCOORD##idx1;
    #define NORMAL_COORDS(idx1) half3 _Normal : TEXCOORD##idx1;
    #define GET_LIGHTDIR(a) a._LightDir = WorldSpaceLightDir(v.vertex);
    #define TRANSFER_NORMAL(a) a._Normal = UnityObjectToWorldNormal(v.normal);
    #define DIFFUSE_ATTENUATION(a, LightScale) computeDiffuseColor(a._LightDir, a._Normal, LightScale);

#endif
