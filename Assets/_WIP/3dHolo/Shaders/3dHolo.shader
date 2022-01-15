Shader "Custom/3dHolo"
{
    Properties
    {
        _MainColor("Main Color", Color) = (0,0.0,1)
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _Alpha("Alpha", Range(0,1)) = 1
        _FrameRate ("FrameRate", Range(0,30)) = 15
        _Frequency ("Frequency", Range(0,1)) = 0.1
        _GlitchScale ("GlitchScale", Range(0,10)) = 1
        _LineSpeed("Line Speed",Range(1,5)) = 1
    }

    Category
    {
        Tags
        {
            "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB
        Cull Back

        SubShader
        {
            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0

                #include "UnityCG.cginc"

                struct appdata_t
                {
                    float4 vertex : POSITION;
                    fixed4 color : COLOR;
                    float2 uv : TEXCOORD0;
                    float3 normal : NORMAL; // vertex normal
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    fixed4 color : COLOR;
                    float2 uv : TEXCOORD0;
                    float3 worldPos : TEXCOORD1;
                    float3 normalDir : TEXCOORD2;
                };

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

                float4 _MainColor;
                float4 _RimColor;
                sampler2D _MainTex;
                float _Alpha;
                float _FrameRate;
                float _Frequency;
                float _GlitchScale;
                float _LineSpeed;

                //グリッチ用にノイズを計算
                float2 glitch_noise_calculate(float2 uv)
                {
                    float posterize = floor(frac(perlinNoise(frac(_Time)) * 10) / (1 / _FrameRate)) * (1 / _FrameRate);
                    //uv.y方向のノイズ計算 -1 < random < 1
                    float noiseY = 2.0 * rand(posterize) - 0.5;
                    //グリッチの高さの補間値計算 どの高さに出現するかは時間変化でランダム
                    float glitchLine1 = step(uv.y - noiseY, rand(uv));
                    float glitchLine2 = step(uv.y - noiseY, 0);
                    noiseY = saturate(glitchLine1 - glitchLine2);
                    //uv.x方向のノイズ計算 -0.1 < random < 0.1
                    float noiseX = (2.0 * rand(posterize) - 0.5) * 0.1;
                    float frequency = step(abs(noiseX), _Frequency);
                    noiseX *= frequency;
                    return float2(noiseX, noiseY);
                }

                v2f vert(appdata_t v)
                {
                    v2f o;

                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    float2 noise = glitch_noise_calculate(o.uv);
                    o.vertex.x = lerp(o.vertex.x, o.vertex.x + noise.x * _GlitchScale, noise.y);
                    o.color = v.color;
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    float2 uv = i.uv;
                    float2 noise = glitch_noise_calculate(uv);
                    //グリッチ適用
                    uv.x = lerp(uv.x, uv.x + noise.x * _GlitchScale, noise.y);
                    //ノイズカラー
                    float4 noiseColor = tex2D(_MainTex, uv) * _MainColor;
                    //リムライト
                    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                    half rim = 1.0 - saturate(dot(viewDirection, i.normalDir));
                    //スキャンライン　小さいサイズ
                    float fraclines = frac(i.worldPos.y + _Time.y * _LineSpeed);
                    float scanlines = step(fraclines, 0.5);
                    //スキャンライン　大きいサイズ
                    float big_scanlines = frac((i.worldPos.y) - _Time.x * 4.0 *  _LineSpeed);
                    //最終の色を計算
                    fixed4 col = noiseColor + (big_scanlines * 0.4 * _MainColor) + (rim * _RimColor);
                    //アルファを計算
                    col.a = _Alpha * (scanlines + rim + big_scanlines);
                    return col;
                }
                ENDCG
            }
        }
    }
}