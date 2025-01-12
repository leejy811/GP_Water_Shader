Shader "Custom/WaterMat"
{
    Properties
    {
        _BumpMap("BumpMap", 2D) = "Bump"{}
        _WaveSpeed("Wave Speed", float) = 0.05
        _WavePower("Wave Power", float) = 0.2
        _WaveTilling("Wave Tilling", float) = 25
        _RefracPower("Refraction Power", float) = 0.03

        _CubeMap("CubeMap", Cube) = ""{}

        _TransTint("Transparent Tint", float) = 1.5
        _SpecTint("Spacular Tint", float) = 20
        _SpacPow("Spacular Power", float) = 2

        _MainTex("Texture", 2D) = "white" {}
        _DepthPower("Depth Power", Range(0, 1)) = 1
    }

        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200

            GrabPass{}

            cull off
            CGPROGRAM
            #pragma surface surf WLight vertex:vert
            #pragma target 3.0

            sampler2D _BumpMap;
            float _WaveSpeed;
            float _WavePower;
            float _WaveTilling;
            float _RefracPower;

            samplerCUBE _CubeMap;

            sampler2D _GrabTexture;
            float _TransTint;
            float _SpecTint;
            float _SpacPow;

            sampler2D _CameraDepthTexture;

            struct Input
            {
                float2 uv_BumpMap;
                float3 worldRefl;
                float4 screenPos;
                float3 viewDir;
                INTERNAL_DATA
            };

            void vert(inout appdata_full v)
            {
                v.vertex.y = sin(abs(v.texcoord.x * 2 - 1) * _WaveTilling + _Time.y) * _WavePower;
            }

            void surf(Input IN, inout SurfaceOutput o)
            {
                float4 nor1 = tex2D(_BumpMap, IN.uv_BumpMap + float2(_Time.y * _WaveSpeed, 0));
                float4 nor2 = tex2D(_BumpMap, IN.uv_BumpMap - float2(_Time.y * _WaveSpeed, 0));
                o.Normal = UnpackNormal((nor1 + nor2) * 0.5);

                float4 sky = texCUBE(_CubeMap, WorldReflectionVector(IN, o.Normal));
                float4 refraction = tex2D(_GrabTexture, (IN.screenPos / IN.screenPos.a).xy + o.Normal.xy * _RefracPower);

                float rim = pow(saturate(1 - dot(o.Normal, IN.viewDir)), _TransTint);
                float3 water = lerp(refraction, sky, rim).rgb;
                
                o.Albedo =  water;
            }

            float4 LightingWLight(SurfaceOutput s, float3 lightDIr, float3 viewDir, float atten)
            {
                float3 halfVec = lightDIr + viewDir;
                halfVec = normalize(halfVec);

                float rim = pow(saturate(1 - dot(s.Normal, viewDir)), _SpecTint);
                float spcr = lerp(0, pow(saturate(dot(halfVec, s.Normal)),16), rim) * _SpacPow;

                return float4(s.Albedo + spcr.rrr,1);
            }
            ENDCG
        }
        FallBack "Diffuse"
}
