Shader "Custom/Glitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FrameRate ("FrameRate", Range(0.1,30)) = 15
        _Frequency  ("Frequency", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Tranparent"
        }
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FrameRate;
            float _Frequency;

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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float posterize = floor(frac(perlinNoise(frac(_Time)) * 10) / (1 / _FrameRate)) * (1 / _FrameRate);
                //uv.y方向のノイズ計算 -1 < random < 1
                float noiseY = 2.0 * rand(posterize) - 0.5;
                
                //グリッチの高さの補間値計算 どの高さに出現するかは時間変化でランダム
                float glitchLine1 = step(uv.y - noiseY, 1.0);
                float glitchLine2 = step(uv.y - noiseY, 0);
                float glitch = saturate(glitchLine1 - glitchLine2);
                //uv.x方向のノイズ計算 -0.1 < random < 0.1
                float noiseX = (2.0 * rand(posterize) - 0.5) * 0.1;
                float frequency = step(abs(noiseX),_Frequency);
                noiseX *= frequency;
                //速度調整
                uv.x = lerp(uv.x, uv.x + noiseX, glitch);
                float4 noiseColor = tex2D(_MainTex, uv);
                return noiseColor;
            }
            ENDCG
        }
    }
}