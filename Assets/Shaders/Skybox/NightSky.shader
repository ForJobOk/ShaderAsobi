Shader "Custom/NightSky"
{
     Properties 
    {
        _LightStrength("LightStrength", Range(0, 200)) = 30
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Background" //最背面に描画するのでBackground
            "Queue"="Background" //最背面に描画するのでBackground
            "PreviewType"="SkyBox" //設定すればマテリアルのプレビューがスカイボックスになるらしい
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _LightStrength;

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

            float2 random2(in float3 uv)
            {
                return float2(frac(sin(dot(uv.xyz, float3(21, 31, 45))) * 7315), frac(cos(dot(uv.xyz, float3(43, 29, 53))) * 6325));
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

                // Cubic Hermine Curve.  Same as SmoothStep()
                float2 u = f * f * (3.0 - 2.0 * f);

                // lerp 4 coorners percentages
                return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 st = random2(i.uv.xyz);
                float color = pow(noise(st), _LightStrength) * 10.0;
                float r = rand(i.uv.xy);
                float g = rand(i.uv.xz);
                float b = rand(i.uv.yz);
                
                return float4(float3(color * r, color * g, color * b), 1.0);
            }
            ENDCG

        }
    }
}