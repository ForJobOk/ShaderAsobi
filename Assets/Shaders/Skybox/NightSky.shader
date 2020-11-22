Shader "Custom/NightSky"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


            //ランダムな値を返す
            float rand(float2 co) //引数はシード値と呼ばれる　同じ値を渡せば同じものを返す
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            float noise(in float2 st)
            {
                float2 i = floor(st);
                float2 f = frac(st);

                // Four corners in 2D of a tile
                float a = rand(i);
                float b = rand(i + float2(1.0, 0.0));
                float c = rand(i + float2(0.0, 1.0));
                float d = rand(i + float2(1.0, 1.0));

                // Smooth Interpolation

                // Cubic Hermine Curve.  Same as SmoothStep()
                float2 u = f * f * (3.0 - 2.0 * f);
                // u = smoothstep(0.,1.,f);

                // lerp 4 coorners percentages
                return lerp(a, b, u.x) +
                    (c - a) * u.y * (1.0 - u.x) +
                    (d - b) * u.x * u.y;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                float4 fragColor;

                float3 pos = i.uv;
                float2 st = rand(pos);

                float color = pow(noise(st), 40.0) * 8.0;

                float r1 = noise(st * noise(float2(1., 1.)));

                fragColor = float4(float3(color * r1, color * r1, color * r1), 1.0);

                //fragColor = float4(vec.x,0,0,1);
                return fragColor;
            }
            ENDCG

        }
    }
}