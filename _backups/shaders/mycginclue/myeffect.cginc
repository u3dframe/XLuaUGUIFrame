#ifndef MY_EFFECT_INCLUDED
    #define MY_EFFECT_INCLUDED

    #include "UnityCG.cginc"

    // 流光效果
    uniform sampler2D _FlowTex;
    uniform float4    _FlowTex_ST;
    uniform fixed4    _FlowColor;
    uniform fixed4    _FlowDir;
    uniform fixed     _FlowClampMin;
    uniform fixed     _FlowClampMax;
    uniform fixed     _FlowSpeed;
    uniform fixed     _IsSimpleFlow;

    inline fixed3 computeFlowEffect(half2 flowUV, fixed3 view, fixed3 normal)
    {
        // Flow Light
        fixed3 finalColor;
        fixed speed = _Time.y * _FlowSpeed;
        if (_IsSimpleFlow < 1.0f)
        {
            fixed value = clamp(dot(view, normal), _FlowClampMin, _FlowClampMax);
            fixed2 uv = fixed2(value, value) + (flowUV + speed * _FlowDir.xy);
            fixed4 color = tex2D(_FlowTex, TRANSFORM_TEX(uv, _FlowTex));
            finalColor = color.rgb * _FlowColor.rgb * (_FlowColor.a * 10);
        }
        else
        {
            float2 timeuv = flowUV + speed * _FlowDir.xy;
            fixed4 color = tex2D(_FlowTex, TRANSFORM_TEX(timeuv, _FlowTex));
            finalColor = color.rgb * _FlowColor.rgb * (_FlowColor.a * 10);
        }

        return finalColor;
    }

    #define UV_COORDS(idx1) half2 _FlowTexcoord : TEXCOORD##idx1;
    #define UV_OUT(idx1) half2 _FlowUV : TEXCOORD##idx1;
    #define GET_UV(a, i) a._FlowUV = i._FlowTexcoord;
    #define SHOW_FLOW(i, view, normal) computeFlowEffect(i._FlowUV, view, normal);


    // 边缘光效果
    uniform sampler2D _RimTex;
    uniform float4    _RimTex_ST;
    uniform half4     _RimLightColor;

    inline fixed3 computeRimLightingEffect(fixed3 view, fixed3 normal, fixed3 up)
    {
        fixed VdotN = saturate(dot(view, normal)) ;
        fixed rimMask = tex2D( _RimTex, TRANSFORM_TEX(float2( VdotN, 0.5f ), _RimTex)).r;
        return _RimLightColor.rgb * saturate(dot(normal, up)) * rimMask * (_RimLightColor.a * 4);
    }

    #define SHOW_RIMLIGHTING(view, normal, up) computeRimLightingEffect(view, normal, up);

#endif
