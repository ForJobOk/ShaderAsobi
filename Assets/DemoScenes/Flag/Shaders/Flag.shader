Shader "Custom/Flag"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "grey" {}
        _MainColor("MainColor", Color) = (1,1,1,1)
        _Frequency("Frequency ", Range(0, 3)) = 1 //周波
        _Amplitude("Amplitude", Range(0, 1)) = 0.5 //振幅
        _WaveSpeed("WaveSpeed",Range(0, 20)) = 10
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" "RenderType" = "Transparent"
        }

        //両面描画
        Cull off
        //透過対応
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

            //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            //パーリンノイズ
            float perlinNoise(fixed2 st)
            {
                fixed2 p = floor(st);
                fixed2 f = frac(st);
                fixed2 u = f * f * (3.0 - 2.0 * f);

                float v00 = rand(p + fixed2(0, 0));
                float v10 = rand(p + fixed2(1, 0));
                float v01 = rand(p + fixed2(0, 1));
                float v11 = rand(p + fixed2(1, 1));

                return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x),
                            lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x),
                            u.y) + 0.5f;
            }

            v2f vert(appdata v)
            {
                v2f o;

                float2 factors = _Time.w * _WaveSpeed + v.uv.xy * _Frequency;
                float2 offsetFactor = sin(factors) * _Amplitude * (1 - v.uv.y) * perlinNoise(_Time);
                v.vertex.y += offsetFactor.x + offsetFactor.y;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 texColor = tex2D(_MainTex, i.uv);
                float4 finalColor = texColor * _MainColor;
                return finalColor;
            }
            ENDCG
        }
    }
}