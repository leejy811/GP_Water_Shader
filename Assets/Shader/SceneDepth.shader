Shader "Unlit/SceneDepth"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _RefractionTex("Refraction Texture", 2D) = "Bump" {}
        _RefractionSpeed("Refraction Speed", Range(0, 1)) = 0.05
        _RefractionPower ("Refraction Power", Range(0, 1)) = 0.01
        _DepthPower("Depth Power", Range(0, 1)) = 1
        _WaterColor("Water Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _RefractionTex;
            float4 _MainTex_ST;
            fixed _RefractionSpeed;
            fixed _RefractionPower;
            fixed _DepthPower;
            fixed4 _WaterColor;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f_img i) : COLOR{
                float4 nor1 = tex2D(_RefractionTex, i.uv + float2(_Time.y * _RefractionSpeed, 0));
                float4 nor2 = tex2D(_RefractionTex, i.uv - float2(_Time.y * _RefractionSpeed, 0));
                float3 normal = UnpackNormal((nor1 + nor2) * 0.5);

                fixed4 renderTex = tex2D(_MainTex, i.uv + normal.xy * _RefractionPower);
                float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv.xy));
                depth = saturate(pow(Linear01Depth(depth), _DepthPower)) > 0.8 ? 0 : saturate(pow(Linear01Depth(depth), _DepthPower));
                fixed4 final = lerp(renderTex, _WaterColor, depth);
                return final;
            }
            ENDCG
        }
    }
}
