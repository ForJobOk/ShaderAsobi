Shader "Custom/Electrification"
{
    Properties
    {
        //メインテクスチャー
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _NoiseColor("Color",Color) = (0,0,0,0)
        _NoiseTilling("Tilling",Range(0,50)) = 10
        _NoiseSpeed("Speed",Range(0,50)) = 10
        _NoiseSize("Size",Range(-100,100)) = 50
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float unity_noise_randomValue(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float unity_noise_interpolate(float a, float b, float t)
            {
                return (1.0 - t) * a + (t * b);
            }

            float unity_valueNoise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);

                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = unity_noise_randomValue(c0);
                float r1 = unity_noise_randomValue(c1);
                float r2 = unity_noise_randomValue(c2);
                float r3 = unity_noise_randomValue(c3);

                float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
                float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
                float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
                return t;
            }

            float Unity_SimpleNoise_float(float2 UV, float Scale)
            {
                float t = 0.0;

                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3 - 0));
                t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3 - 1));
                t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3 - 2));
                t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                return t;
            }

            sampler2D _MainTex;
            float _NoiseTilling;
            float4 _NoiseColor;
            float _NoiseSpeed;
            float _NoiseSize;

            float4 Unity_Remap_float4(float4 In, float Min, float Max)
            {
                //-50 + {50 -(-50)} * value
                return Min + (Max - Min) * In;
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv: TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                //方向の異なるノイズの流れをそれぞれ求める
                float4 noiseA = Unity_SimpleNoise_float(i.uv -_Time.x * _NoiseSpeed, _NoiseTilling);
                float4 noiseB = Unity_SimpleNoise_float(i.uv +_Time.x * _NoiseSpeed, _NoiseTilling);
                //ノイズの値の範囲を変換
                float mixNoise = (noiseA + noiseB) * 100 - _NoiseSize;
                //絶対値を求めて縁取りを行う
                mixNoise = abs(mixNoise);
                //白黒を反転して値をまるめる
                mixNoise = saturate(1 - mixNoise);

                //テクスチャーのサンプリング
                float4 texColor = tex2D(_MainTex, i.uv);
                //塗分け
                return lerp(mixNoise + texColor, _NoiseColor, mixNoise);;
            }
            ENDCG
        }
    }
}