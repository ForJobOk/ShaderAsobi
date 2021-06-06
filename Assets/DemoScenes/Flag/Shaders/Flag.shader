Shader "Custom/Flag"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "grey" {}
        _MainColor("MainColor", Color) = (1,1,1,1)
        _Frequency("Frequency ", Range(0, 3)) = 1
        _Amplitude("Amplitude", Range(0, 1)) = 0.5
        _WaveSpeed("WaveSpeed",Range(0, 20)) = 10
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "RenderType" = "Transparent"
        }

        Cull off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainColor;
            float _Frequency;
            float _Amplitude;
            float _WaveSpeed;

            v2f vert(appdata v)
            {
                v2f o;

                //float2 factors = _Time.w * _WaveSpeed + v.uv.xy * _Frequency;
                float2 factors = _Time.w * _WaveSpeed + v.vertex.xz * _Frequency;
                float2 offsetYFactors = sin(factors) * _Amplitude * (1-v.uv.y);
                v.vertex.y += offsetYFactors.x + offsetYFactors.y;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 texColor = tex2D(_MainTex, i.uv);
                texColor *= _MainColor;
                return texColor;
            }
            ENDCG
        }
    }
}