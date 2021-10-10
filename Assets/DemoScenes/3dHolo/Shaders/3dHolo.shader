// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
// Edited by MinionsArt for hologram effect

Shader "Custom/3dHolo"
{
    Properties
    {
        _TintColor("Tint Color", Color) = (0,0.5,1,1)
        _RimColor("Rim Color", Color) = (0,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _GlitchTime("Glitches Over Time", Range(0.01,3.0)) = 1.0
        _WorldScale("Line Amount", Range(1,200)) = 20
        _Alpha("Alpha", Range(0,1)) = 1
        _FrameRate ("FrameRate", Range(0,30)) = 15
        _Frequency ("Frequency", Range(0,1)) = 0.1
        _GlitchScale ("GlitchScale", Range(1,10)) = 1
    }

    Category
    {
        Tags
        {
            "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Sphere"
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

                sampler2D _MainTex;
                fixed4 _TintColor;
                fixed4 _RimColor;
                float _Alpha;
                float _FrameRate;
                float _Frequency;
                float _GlitchScale;


                struct appdata_t
                {
                    float4 vertex : POSITION;
                    fixed4 color : COLOR;

                    float2 texcoord : TEXCOORD0;
                    float3 normal : NORMAL; // vertex normal
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord : TEXCOORD0;
                    float3 wpos : TEXCOORD1; // worldposition
                    float3 normalDir : TEXCOORD2; // normal direction for rimlighting
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

                float4 _MainTex_ST;
                float _GlitchTime;
                float _WorldScale;
                float _OptTime = 0;

                v2f vert(appdata_t v)
                {
                    v2f o;

                    o.vertex = UnityObjectToClipPos(v.vertex);

                    // Vertex glitching
                    _OptTime = _OptTime == 0 ? sin(_Time.w * _GlitchTime) : _OptTime; // optimisation
                    float glitchtime = step(0.99, _OptTime); // returns 1 when sine is near top, otherwise returns 0;
                    float glitchPos = v.vertex.y + _SinTime.y; // position on model
                    float glitchPosClamped = step(0, glitchPos) * step(glitchPos, 0.2); // clamped segment of model
                    o.vertex.xz += glitchPosClamped * 0.1 * glitchtime * _SinTime.y;
                    // moving the vertices when glitchtime returns 1;


                    o.color = v.color;
                    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                    // world position and normal direction
                    o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);

                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    float2 uv = i.texcoord;
                    float posterize = floor(frac(perlinNoise(frac(_Time)) * 10) / (1 / _FrameRate)) * (1 / _FrameRate);
                    //uv.y方向のノイズ計算 -1 < random < 1
                    float noiseY = 2.0 * rand(posterize) - 0.5;
                    //グリッチの高さの補間値計算 どの高さに出現するかは時間変化でランダム
                    float glitchLine1 = step(uv.y - noiseY, rand(uv));
                    float glitchLine2 = step(uv.y - noiseY, 0);
                    float glitch = saturate(glitchLine1 - glitchLine2);
                    //uv.x方向のノイズ計算 -0.1 < random < 0.1
                    float noiseX = (2.0 * rand(posterize) - 0.5) * 0.1;
                    float frequency = step(abs(noiseX), _Frequency);
                    noiseX *= frequency;
                    //グリッチ適用
                    uv.x = lerp(uv.x, uv.x + noiseX * _GlitchScale, glitch);
                    float4 noiseColor = tex2D(_MainTex, uv) * _TintColor;
                    //float4 text = tex2D(_MainTex, i.texcoord) * _TintColor; // texture

                    // rim lighting
                    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.wpos.xyz);
                    half rim = 1.0 - saturate(dot(viewDirection, i.normalDir)); // rimlight based on view and normal

                    // small scanlines down
                    float fraclines = frac((i.wpos.y * _WorldScale) + _Time.y); //small lines
                    float scanlines = step(fraclines, 0.5); // cut off based on 0.5
                    // big scanline up
                    float bigfracline = frac((i.wpos.y) - _Time.x * 4); // big gradient line

                    fixed4 col = noiseColor + (bigfracline * 0.4 * _TintColor) + (rim * _RimColor); // end result color

                    col.a = _Alpha * 0.8 * (scanlines + rim + bigfracline); // alpha based on scanlines and rim

                    return col;
                }
                ENDCG
            }
        }
    }
}