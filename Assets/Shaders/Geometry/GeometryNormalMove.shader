Shader "Custom/GeometryNormalMove"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ScaleFactor ("Scale Factor", float) = 0.5
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

            //頂点シェーダーに渡ってくる頂点データ
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            //ジオメトリシェーダーからフラグメントシェーダーに渡すデータ
            struct g2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            //頂点シェーダー
            appdata vert(appdata v)
            {
                return v;
            }

            //ジオメトリシェーダー
            //引数のinputは文字通り頂点シェーダーからの入力
            //streamは参照渡しで次の処理に値を受け渡ししている　TriangleStream<>で三角面を出力する
            [maxvertexcount(3)] //出力する頂点の最大数
            void geom(triangle appdata input[3], inout LineStream<g2f> stream)
            {
                // 法線を計算
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    //法線ベクトルに沿って頂点を移動
                    v.vertex.xyz += normal * (sin(_Time.w) + 0.5) * _ScaleFactor;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
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