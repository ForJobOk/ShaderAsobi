Shader "Custom/GeometryRotation"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
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
            float _RotationFactor;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            appdata vert(appdata v)
            {
                return v;
            }

            struct g2f
            {
                float4 vertex : SV_POSITION;
            };

            //回転させる
            //pは回転させたい座標　angleは回転させる角度　axisはどの軸を元に回転させるか　
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

            //ジオメトリシェーダー
            //pidは各ポリゴンのID　それぞれのポリゴンに異なる処理を行うために活用
            [maxvertexcount(3)]
            void geom(triangle appdata input[3], uint pid : SV_PrimitiveID,inout TriangleStream<g2f> stream)
            {
                //1枚のポリゴンの中心
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                //-1 < r < 1
                float r = 2.0 * rand(center.xy) - 0.5;
                float3 r3 = r.xxx; //こういう書き方もできるらしい　xyzに全部同じ値を入れる

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    //中心を起点に回転させる ここの処理、どうしてそうなるか深く理解できてない
                    v.vertex.xyz = center + rotate(v.vertex.xyz - center, (pid + _Time.y) * _RotationFactor, r3);
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    stream.Append(o);
                }
                stream.RestartStrip();
            }

            fixed4 frag(g2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}