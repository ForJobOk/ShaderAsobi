Shader "Custom/GeometryTest"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ScaleFactor ("Scale Factor", float) = 0.5
        _RotationFactor ("Rotation Factor", float) = 0.5
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
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            float _ScaleFactor;
            float _RotationFactor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            appdata vert(appdata v)
            {
                return v;
            }

            float3 rotate(float3 p, float angle, float3 axis)
            {
                float3 a = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float r = 1.0 - c;
                float3x3 m = float3x3(
                    a.x * a.x * r + c, a.y * a.x * r + a.z * s, a.z * a.x * r - a.y * s,
                    a.x * a.y * r - a.z * s, a.y * a.y * r + c, a.z * a.y * r + a.x * s,
                    a.x * a.z * r + a.y * s, a.y * a.z * r - a.x * s, a.z * a.z * r + c
                );

                return mul(m, p);
            }

            //ランダムな値を返す
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            // ジオメトリシェーダー
            [maxvertexcount(3)]
            void geom(triangle appdata input[3], inout TriangleStream<g2f> stream)
            {
                // 法線を計算
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                float r = rand(center.xy);
                float3 r3 = float3(r,r,r);

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    // 法線ベクトルに沿って頂点を移動
                    v.vertex.xyz += normal * (_SinTime.w * 0.5 + 0.5) * _ScaleFactor;
                    v.vertex.xyz = rotate(v.vertex.xyz - center, r * _RotationFactor, r3) + center;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    stream.Append(o);
                }
                stream.RestartStrip();
            }

            fixed4 frag(g2f i) : SV_Target
            {
                fixed4 col = _Color;
                return col;
            }
            ENDCG
        }
    }
}