Shader "Custom/Glitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LineColor ("LineColor", Color) = (0,0,0,0)
        _LineSpeed("LineSpeed",Range(0,10)) = 5
        _LineSize("LineSize",Range(0,10)) = 0.01
        _GlitchLineSize("GlitchLineSize",Range(0,1)) = 0.5
        _GlitchNoiseValue("GlitchNoiseValue",Range(0,1)) = 0.5
        _ColorGap("ColorGap",Range(0,0.05)) = 0.01
        _Alpha ("Alpha", Range(0,1)) = 0.5
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
                float2 line_uv : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 line_uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _LineColor;
            float _LineSpeed;
            float _LineSize;
            float _ColorGap;
            float _GlitchLineSize;
            float _GlitchNoiseValue;
            float _Alpha;

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
                //UVスクロール
                o.line_uv.y = v.line_uv.y - _Time.z * _LineSpeed;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                //RGBずらしてホログラムっぽく
                float r = tex2D(_MainTex, uv + _ColorGap * perlinNoise(_Time.z)).r;
                float b = tex2D(_MainTex, uv - _ColorGap * perlinNoise(_Time.z)).b;
                float2 ga = tex2D(_MainTex, uv).ga;
                float4 gap_color = fixed4(r, ga.x, b, ga.y);
                //ノイズラインの補間値計算
                float interpolation = step(frac(i.line_uv.y * 15), _LineSize);
                //ノイズラインを含むピクセルカラー
                float4 noise_line_color = lerp(gap_color, gap_color * _LineColor, interpolation);
                //グリッチのラインの補間値計算
                //どの高さに出現するかは時間変化でランダム
                float frequency = step(frac(rand(_SinTime)),0.01);
                float random = 2.0 * rand(_Time) - 0.5;

                float glitchLine1 = step(uv.y - random , 1.0);
                float glitchLine2 = step(uv.y - random , 0);
                float glitch = glitchLine1 - glitchLine2;
                //ノイズ計算
                uv.x = lerp(uv.x, uv.x + random * 0.5 * frequency, glitch);
                float4 noise_color = tex2D(_MainTex, uv);
                float4 final_color = lerp(noise_line_color, noise_color, glitch);
                final_color.a = _Alpha;
                return final_color;
            }
            ENDCG
        }
    }
}